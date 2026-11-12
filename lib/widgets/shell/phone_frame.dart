import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  static const width = 440.0;
  static const height = 956.0;
  static const _breakpoint = 600.0;

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth <= _breakpoint) return child;
      final frameHeight = math.min(constraints.maxHeight - 32, height);
      final media = MediaQuery.of(context);
      return ColoredBox(
        color: AppColors.frameBackground,
        child: Center(
          child: Container(
            width: width,
            height: frameHeight,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [BoxShadow(color: Color(0x33102F62), blurRadius: 40, offset: Offset(0, 16))],
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              data: media.copyWith(size: Size(width, frameHeight), padding: EdgeInsets.zero),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
