import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kds/core/constants/network.dart';
import 'package:kds/presentation/cubit/caye/caye_management_cubit.dart';
import 'package:kds/presentation/cubit/caye/caye_management_state.dart';

class CayeManagementScreen extends StatelessWidget {
  final String? activeProductKey;
  final String? activeOrderNo;

  const CayeManagementScreen({
    super.key,
    this.activeProductKey,
    this.activeOrderNo,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CayeManagementCubit>();
    const machineIp = NetworkConstants.cayeMachineIp;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CAYE MACHINE DASHBOARD'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search),
            tooltip: 'Query Status',
            onPressed: () => cubit.sendQueryStatus(machineIp),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            BlocBuilder<CayeManagementCubit, CayeManagementState>(
              builder: (context, state) => _StatusCard(
                machineIp: machineIp,
                isConnected: state.isConnected,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _ControlBtn(
                    label: 'Rinse',
                    icon: Icons.water_drop,
                    color: Colors.cyan,
                    onTap: () => cubit.sendRinsingCommand(machineIp),
                  ),
                  _ControlBtn(
                    label: 'Clean',
                    icon: Icons.cleaning_services,
                    color: Colors.orange,
                    onTap: () => _showCleaningDialog(context, cubit, machineIp),
                  ),
                  _ControlBtn(
                    label: 'Status',
                    icon: Icons.manage_search,
                    color: Colors.purple,
                    onTap: () => cubit.sendQueryStatus(machineIp),
                  ),
                  _ControlBtn(
                    label: 'Sync Time',
                    icon: Icons.sync,
                    color: Colors.teal,
                    onTap: () => cubit.sendTimeSync(machineIp),
                  ),
                  _ControlBtn(
                    label: "Today's Data",
                    icon: Icons.insert_chart_outlined,
                    color: Colors.pinkAccent,
                    onTap: () {
                      cubit.sendTodayExtractionHistory(machineIp);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('오늘치 기록 요청. Logcat을 확인하세요.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (activeProductKey != null && activeOrderNo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    cubit.sendCancelCommand(machineIp, activeProductKey!, activeOrderNo!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency Stop command sent!')),
                    );
                  },
                  icon: const Icon(Icons.stop_circle, size: 30),
                  label: const Text(
                    'Emergency Stop',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCleaningDialog(
      BuildContext context, CayeManagementCubit cubit, String machineIp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Select Cleaning Mode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CleaningTile(
              title: 'End of Day Cleaning (All)',
              subtitle: 'Cleans all internal systems.',
              mode: 0,
              cubit: cubit,
              machineIp: machineIp,
            ),
            const Divider(color: Colors.white10),
            _CleaningTile(
              title: 'Coffee System Cleaning',
              subtitle: 'Cleans the coffee extraction lines.',
              mode: 1,
              cubit: cubit,
              machineIp: machineIp,
            ),
            const Divider(color: Colors.white10),
            _CleaningTile(
              title: 'Milk System Cleaning',
              subtitle: 'Cleans milk nozzles and pipes.',
              mode: 2,
              cubit: cubit,
              machineIp: machineIp,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String machineIp;
  final bool isConnected;

  const _StatusCard({required this.machineIp, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.coffee_maker,
              size: 50,
              color: isConnected ? Colors.blueAccent : Colors.white30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IP: $machineIp',
                  style: const TextStyle(color: Colors.white70)),
              Text(
                isConnected ? 'Connected - Standby' : 'Disconnected',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.white : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CleaningTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int mode;
  final CayeManagementCubit cubit;
  final String machineIp;

  const _CleaningTile({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.cubit,
    required this.machineIp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      title: Text(title,
          style: const TextStyle(
              color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.orangeAccent),
      onTap: () {
        cubit.sendCleaningCommand(machineIp, mode: mode);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting $title!')),
        );
      },
    );
  }
}
