import 'dart:convert';
import 'dart:io';

import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/models/order_store/order_record_raw.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Where [IOrderLocalDataSource.changedSince] continues from.
typedef OrderCursor = ({DateTime updatedAt, int id});

/// The leader's local order table (SQLite): every order with its sync
/// state, plus a small key/value table for the sync's own state.
///
/// A row is one order: an orderNo can have several rows, one per day it
/// was used (kiosk numbers restart every day), told apart by orderedAt.
abstract interface class IOrderLocalDataSource {
  /// Every stored row of [orderNos], grouped by orderNo.
  Future<Map<String, List<OrderRecordRaw>>> findByOrderNos(
    Iterable<String> orderNos,
  );

  /// Writes [records] as the live orders, in one transaction.
  /// 1. Every order is taken off the board first (`live = 0`).
  /// 2. A record with an id updates that row, one without is inserted;
  ///    both with `live = 1`.
  ///    The synced / rejected versions are never written here, so an ack
  ///    that lands meanwhile is kept.
  Future<void> saveLive(List<OrderRecordRaw> records);

  /// `order_json` of every live order.
  Future<List<String>> loadLiveOrderJson();

  /// Takes every order off the board.
  Future<void> clearLive();

  /// Pending orders (latest version neither synced nor rejected), oldest
  /// change first, at most [limit].
  Future<List<OrderRecordRaw>> pending({required int limit});

  /// Orders changed at or after [since], oldest change first, at most
  /// [limit], after [after] when given. The latest version of a rejected
  /// order is left out.
  Future<List<OrderRecordRaw>> changedSince(
    DateTime since, {
    OrderCursor? after,
    required int limit,
  });

  /// synced_version = max(synced_version, [version]) on row [id], or, for
  /// an MQTT ack (orderNo + version only), on the oldest row of [orderNo]
  /// still waiting for that version.
  Future<void> markSynced(String orderNo, int version, {int? id});

  /// rejected_version = max(rejected_version, [version]); the row is found
  /// like [markSynced].
  Future<void> markRejected(String orderNo, int version, {int? id});

  /// Deletes orders that are off the board, not pending and unchanged
  /// since [cutoff]. Returns how many.
  Future<int> deleteDoneBefore(DateTime cutoff);

  Future<String?> readState(String key);

  Future<void> writeState(String key, String value);
}

@Singleton(as: IOrderLocalDataSource)
class OrderLocalDataSource implements IOrderLocalDataSource {
  OrderLocalDataSource() : _openDatabase = _openDefault, _legacyDir = null;

  /// [open] gives the database (e.g. in memory); [legacyDir] holds the
  /// JSON files to import, if any.
  @visibleForTesting
  OrderLocalDataSource.withDatabase(
    Future<Database> Function() open, {
    Directory? legacyDir,
  }) : _openDatabase = open,
       _legacyDir = legacyDir;

  static const String _tag = 'OrderStore';
  static const String _fileName = 'flowhub_orders.db';
  static const int _schemaVersion = 2;

  /// Files of the two JSON stores this table replaces.
  static const String _legacySnapshotFile = 'live_orders_snapshot.json';
  static const String _legacyOutboxFile = 'order_sync_outbox.json';

  /// SQLite's default limit on `?` parameters in one statement.
  static const int _maxParameters = 900;

  final Future<Database> Function() _openDatabase;
  final Directory? _legacyDir;
  Future<Database>? _database;

  Future<Database> get _db => _database ??= _open();

  static Future<Database> _openDefault() async {
    final Directory dir = await getApplicationSupportDirectory();
    return openDatabase(
      '${dir.path}${Platform.pathSeparator}$_fileName',
      version: _schemaVersion,
      onCreate: (Database db, int version) => createSchema(db),
      onUpgrade: (Database db, int from, int to) => upgradeSchema(db, from),
    );
  }

  /// Creates the tables (schema version 2).
  @visibleForTesting
  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_no TEXT NOT NULL,
        order_json TEXT NOT NULL,
        sync_json TEXT NOT NULL,
        ordered_at TEXT NOT NULL,
        version INTEGER NOT NULL,
        synced_version INTEGER NOT NULL DEFAULT 0,
        rejected_version INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL,
        live INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_updated '
      'ON orders (updated_at, id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_no ON orders (order_no)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_live ON orders (live)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )''');
  }

  /// Version 1 keyed the table by orderNo alone, which merged an order with
  /// the same number from an earlier day. Moves the rows into the version 2
  /// table (row ID key) unchanged.
  @visibleForTesting
  static Future<void> upgradeSchema(Database db, int from) async {
    if (from >= 2) return;
    await db.transaction((Transaction txn) async {
      await txn.execute('ALTER TABLE orders RENAME TO orders_v1');
      await txn.execute('DROP INDEX IF EXISTS idx_orders_updated');
      await txn.execute('DROP INDEX IF EXISTS idx_orders_live');
      await createSchema(txn);
      await txn.execute('''
        INSERT INTO orders (order_no, order_json, sync_json, ordered_at,
          version, synced_version, rejected_version, updated_at, live)
        SELECT order_no, order_json, sync_json, ordered_at, version,
          synced_version, rejected_version, updated_at, live
        FROM orders_v1''');
      await txn.execute('DROP TABLE orders_v1');
    });
    Log.i(_tag, 'Order table upgraded to schema 2 (one row per order)');
  }

  /// Opens the database, then imports the old JSON files once.
  Future<Database> _open() async {
    final Database db = await _openDatabase();
    try {
      await _importLegacyFiles(db);
    } catch (e) {
      Log.e(_tag, 'Legacy import failed: $e');
    }
    return db;
  }

  /// Imports the JSON files this table replaces, then deletes them.
  /// 1. `order_sync_outbox.json`: each entry's sync state (version, synced
  ///    version, snapshot), off the board.
  /// 2. `live_orders_snapshot.json`: each order as live. An order with no
  ///    sync state gets version 0 and an empty snapshot, so the next save
  ///    gives it version 1.
  Future<void> _importLegacyFiles(Database db) async {
    final Directory dir = _legacyDir ?? await getApplicationSupportDirectory();
    final File outbox = File(
      '${dir.path}${Platform.pathSeparator}$_legacyOutboxFile',
    );
    final File snapshot = File(
      '${dir.path}${Platform.pathSeparator}$_legacySnapshotFile',
    );
    final bool hasOutbox = await outbox.exists();
    final bool hasSnapshot = await snapshot.exists();
    if (!hasOutbox && !hasSnapshot) return;
    final List<Object?> entries = hasOutbox ? _readList(outbox) : <Object?>[];
    final List<Object?> orders = hasSnapshot
        ? _readList(snapshot)
        : <Object?>[];
    final int now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((Transaction txn) async {
      for (final Object? item in entries) {
        if (item is! Map<String, dynamic>) continue;
        final String orderNo = item['orderNo'] as String? ?? '';
        if (orderNo.isEmpty) continue;
        await txn.insert('orders', <String, Object?>{
          'order_no': orderNo,
          'order_json': '',
          'sync_json': jsonEncode(item['order'] ?? <String, dynamic>{}),
          'ordered_at': item['orderedAt'] as String? ?? '',
          'version': (item['version'] as num?)?.toInt() ?? 0,
          'synced_version': (item['syncedVersion'] as num?)?.toInt() ?? 0,
          'updated_at':
              DateTime.tryParse(
                item['updatedAt'] as String? ?? '',
              )?.millisecondsSinceEpoch ??
              now,
          'live': 0,
        });
      }
      for (final Object? item in orders) {
        if (item is! Map<String, dynamic>) continue;
        final String orderNo = item['orderNo'] as String? ?? '';
        if (orderNo.isEmpty) continue;
        final String orderJson = jsonEncode(item);
        final int updated = await txn.update(
          'orders',
          <String, Object?>{'order_json': orderJson, 'live': 1},
          where: 'order_no = ?',
          whereArgs: <Object?>[orderNo],
        );
        if (updated == 0) {
          await txn.insert('orders', <String, Object?>{
            'order_no': orderNo,
            'order_json': orderJson,
            'sync_json': '',
            'ordered_at': '',
            'version': 0,
            'updated_at': now,
            'live': 1,
          });
        }
      }
    });
    if (hasOutbox) await outbox.delete();
    if (hasSnapshot) await snapshot.delete();
    Log.i(
      _tag,
      'Imported ${entries.length} sync entr(ies) and ${orders.length} live '
      'order(s) from the JSON files',
    );
  }

  static List<Object?> _readList(File file) {
    try {
      final Object? decoded = jsonDecode(file.readAsStringSync());
      return decoded is List ? decoded : <Object?>[];
    } catch (e) {
      Log.e(_tag, 'Unreadable ${file.path}: $e');
      return <Object?>[];
    }
  }

  @override
  Future<Map<String, List<OrderRecordRaw>>> findByOrderNos(
    Iterable<String> orderNos,
  ) async {
    final Database db = await _db;
    final List<String> all = orderNos.toSet().toList();
    final Map<String, List<OrderRecordRaw>> found =
        <String, List<OrderRecordRaw>>{};
    for (int i = 0; i < all.length; i += _maxParameters) {
      final List<String> chunk = all.sublist(
        i,
        i + _maxParameters > all.length ? all.length : i + _maxParameters,
      );
      final List<Map<String, Object?>> rows = await db.query(
        'orders',
        where:
            'order_no IN (${List<String>.filled(chunk.length, '?').join(',')})',
        whereArgs: chunk,
        orderBy: 'id',
      );
      for (final Map<String, Object?> row in rows) {
        final OrderRecordRaw record = OrderRecordRaw.fromRow(row);
        (found[record.orderNo] ??= <OrderRecordRaw>[]).add(record);
      }
    }
    return found;
  }

  @override
  Future<void> saveLive(List<OrderRecordRaw> records) async {
    final Database db = await _db;
    await db.transaction((Transaction txn) async {
      await txn.update('orders', <String, Object?>{
        'live': 0,
      }, where: 'live = 1');
      for (final OrderRecordRaw record in records) {
        final int? id = record.id;
        if (id == null) {
          await txn.insert('orders', record.toRow());
          continue;
        }
        await txn.update(
          'orders',
          <String, Object?>{
            'order_json': record.orderJson,
            'sync_json': record.syncJson,
            'ordered_at': record.orderedAt,
            'version': record.version,
            'updated_at': record.updatedAt.millisecondsSinceEpoch,
            'live': 1,
          },
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      }
    });
  }

  @override
  Future<List<String>> loadLiveOrderJson() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      'orders',
      columns: <String>['order_json'],
      where: "live = 1 AND order_json != ''",
      orderBy: 'id',
    );
    return <String>[
      for (final Map<String, Object?> row in rows) row['order_json']! as String,
    ];
  }

  @override
  Future<void> clearLive() async {
    final Database db = await _db;
    await db.update('orders', <String, Object?>{'live': 0}, where: 'live = 1');
  }

  @override
  Future<List<OrderRecordRaw>> pending({required int limit}) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      'orders',
      where: 'version > synced_version AND version > rejected_version',
      orderBy: 'updated_at, id',
      limit: limit,
    );
    return rows.map(OrderRecordRaw.fromRow).toList();
  }

  @override
  Future<List<OrderRecordRaw>> changedSince(
    DateTime since, {
    OrderCursor? after,
    required int limit,
  }) async {
    final Database db = await _db;
    final int sinceMs = since.millisecondsSinceEpoch;
    final List<Map<String, Object?>> rows = await db.query(
      'orders',
      where: after == null
          ? 'updated_at >= ? AND version > 0 AND version > rejected_version'
          : 'updated_at >= ? AND version > 0 AND version > rejected_version '
                'AND (updated_at > ? OR (updated_at = ? AND id > ?))',
      whereArgs: after == null
          ? <Object?>[sinceMs]
          : <Object?>[
              sinceMs,
              after.updatedAt.millisecondsSinceEpoch,
              after.updatedAt.millisecondsSinceEpoch,
              after.id,
            ],
      orderBy: 'updated_at, id',
      limit: limit,
    );
    return rows.map(OrderRecordRaw.fromRow).toList();
  }

  @override
  Future<void> markSynced(String orderNo, int version, {int? id}) =>
      _mark('synced_version', orderNo, version, id);

  @override
  Future<void> markRejected(String orderNo, int version, {int? id}) =>
      _mark('rejected_version', orderNo, version, id);

  /// Raises [column] to [version] on row [id], or else on the oldest row of
  /// [orderNo] (by orderedAt) that holds [version] or newer and has neither
  /// synced nor rejected it yet.
  Future<void> _mark(
    String column,
    String orderNo,
    int version,
    int? id,
  ) async {
    final Database db = await _db;
    if (id != null) {
      await db.rawUpdate(
        'UPDATE orders SET $column = MAX($column, ?) WHERE id = ?',
        <Object?>[version, id],
      );
      return;
    }
    await db.rawUpdate(
      'UPDATE orders SET $column = MAX($column, ?) WHERE id = ('
      'SELECT id FROM orders WHERE order_no = ? AND version >= ? '
      'AND synced_version < ? AND rejected_version < ? '
      'ORDER BY ordered_at, id LIMIT 1)',
      <Object?>[version, orderNo, version, version, version],
    );
  }

  @override
  Future<int> deleteDoneBefore(DateTime cutoff) async {
    final Database db = await _db;
    return db.delete(
      'orders',
      where:
          'live = 0 AND version <= MAX(synced_version, rejected_version) '
          'AND updated_at < ?',
      whereArgs: <Object?>[cutoff.millisecondsSinceEpoch],
    );
  }

  @override
  Future<String?> readState(String key) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      'sync_state',
      where: 'key = ?',
      whereArgs: <Object?>[key],
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  @override
  Future<void> writeState(String key, String value) async {
    final Database db = await _db;
    await db.insert('sync_state', <String, Object?>{
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
