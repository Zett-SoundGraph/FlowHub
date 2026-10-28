import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Shared chrome for the drawer's sub-screens (figmaImage/10_Device
/// Management.png, figmaImage/11_Caye Machine Control.png) — same app bar,
/// same icon+title header, only the body content underneath differs.
class FlowHubSubScreenScaffold extends StatelessWidget {
  final double scale;
  final String title;
  final String headerIconAsset;
  final double headerIconWidth;
  final double headerIconHeight;
  final double headerIconLeft;
  final double headerTitleGap;
  final Widget body;

  const FlowHubSubScreenScaffold({
    super.key,
    required this.scale,
    required this.title,
    required this.headerIconAsset,
    required this.headerIconWidth,
    required this.headerIconHeight,
    required this.headerIconLeft,
    required this.headerTitleGap,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFAF5ED),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        // The Android gesture-nav strip is drawn by the OS on top of the
        // app, same issue as the main screen's calibration overlay — needs
        // to be told explicitly, or it keeps whatever flat color a *previous*
        // screen (e.g. the main screen's cream) last set it to instead of
        // matching this screen's own page background.
        systemNavigationBarColor: Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            // Without this, the Column gives its Expanded body only a LOOSE
            // width constraint, so body shrink-wraps to its own content's
            // intrinsic width and then gets horizontally CENTERED as a whole
            // block — on Caye Machine Control (content much narrower than
            // the full 1280) that reads as "the buttons are centered"
            // instead of left-aligned at the page margin.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AppBar(scale: scale, onBack: () => Navigator.of(context).pop()),
              Container(
                width: double.infinity,
                height: 130 * scale,
                // Symmetric top/bottom 40 padding per spec — the container
                // is 130 tall and the icon/title content is 50 tall (the
                // title's own line-height), so 40/40 centers it exactly.
                padding: EdgeInsets.symmetric(vertical: 40 * scale),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0x421A1C1E),
                      width: 1 * scale,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: headerIconLeft * scale),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        headerIconAsset,
                        width: headerIconWidth * scale,
                        height: headerIconHeight * scale,
                        color: const Color(0xFF1A1C1E),
                      ),
                      SizedBox(width: headerTitleGap * scale),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: flowhubFontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 36 * scale,
                          height: 50 / 36,
                          letterSpacing: -0.36 * scale,
                          color: const Color(0xFF1A1C1E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48 * scale),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back-chevron + date/time app bar (figmaImage/10_Device Management.png /
/// 11_Caye Machine Control.png) — same date/time construction as
/// [FlowHubTopBar] on the main screen.
class _AppBar extends StatelessWidget {
  final double scale;
  final VoidCallback onBack;

  const _AppBar({required this.scale, required this.onBack});

  static const _weekdayNames = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final dateText =
            '${_monthNames[now.month - 1]} ${now.day}, ${now.year} (${_weekdayNames[now.weekday - 1]})';
        final timeText =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

        return Container(
          width: double.infinity,
          height: 88 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5ED),
            border: Border(
              bottom: BorderSide(color: const Color(0x0F1A1C1E), width: 2 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F1A1C1E),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 32 * scale,
                  color: const Color(0xFF33383C),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateText,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: flowhubFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 28 * scale,
                      height: 36 / 28,
                      letterSpacing: -0.28 * scale,
                      color: FlowHubColors.textPrimary87,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(width: 22.24 * scale),
                  Container(
                    width: 5.52 * scale,
                    height: 5.52 * scale,
                    margin: EdgeInsets.only(bottom: 4 * scale),
                    decoration: const BoxDecoration(
                      color: FlowHubColors.textPrimary87,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 22.24 * scale),
                  _TabularClockText(
                    text: timeText,
                    style: TextStyle(
                      fontFamily: flowhubFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 36 * scale,
                      height: 50 / 36,
                      letterSpacing: -0.36 * scale,
                      color: FlowHubColors.textPrimary87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Same fixed-digit-width rendering as [FlowHubTopBar]'s clock — keeps the
/// HH:MM:SS block from jittering as narrow/wide digits swap each second.
class _TabularClockText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _TabularClockText({required this.text, required this.style});

  double _measure(String s) {
    final painter = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final digitWidth = [
      for (var i = 0; i < 10; i++) _measure('$i'),
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final char in text.split(''))
          SizedBox(
            width: RegExp(r'[0-9]').hasMatch(char) ? digitWidth : _measure(char),
            child: Text(
              char,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: style,
            ),
          ),
      ],
    );
  }
}
