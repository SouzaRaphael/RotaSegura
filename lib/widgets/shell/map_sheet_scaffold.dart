import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_header.dart';
import 'page_scaffold.dart';

class MapSheetScaffold extends StatefulWidget {
  const MapSheetScaffold({
    super.key,
    required this.section,
    required this.map,
    required this.panelChildren,
    this.mapTopOverlay,
    this.mapActions,
  });

  final String section;
  final Widget map;
  final List<Widget> panelChildren;

  final Widget? mapTopOverlay;

  final Widget? mapActions;

  static const _headerHeight = 62.0;

  static double openSheetHeight(double bodyHeight) => math.min(bodyHeight * 0.64, 540.0);

  static EdgeInsets visibleMapPadding(BuildContext context) {
    final bodyHeight = MediaQuery.sizeOf(context).height - _headerHeight;
    return EdgeInsets.fromLTRB(36, 64, 36, openSheetHeight(bodyHeight) + 24);
  }

  @override
  State<MapSheetScaffold> createState() => _MapSheetScaffoldState();
}

class _MapSheetScaffoldState extends State<MapSheetScaffold> {
  static const _closedHeight = 64.0;
  static const _duration = Duration(milliseconds: 260);
  bool _open = true;

  void _setOpen(bool open) {
    if (open != _open) setState(() => _open = open);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppHeader(section: widget.section),
    backgroundColor: AppColors.mapBackground,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final openHeight = MapSheetScaffold.openSheetHeight(constraints.maxHeight);
        final sheetHeight = _open ? openHeight : _closedHeight;
        return Stack(
          children: [
            Positioned.fill(child: widget.map),
            if (widget.mapTopOverlay != null)
              Positioned(top: 12, left: 12, right: 12, child: widget.mapTopOverlay!),
            if (widget.mapActions != null)
              AnimatedPositioned(
                duration: _duration,
                curve: Curves.easeOut,
                right: 12,
                bottom: sheetHeight + 12,
                child: widget.mapActions!,
              ),
            AnimatedPositioned(
              duration: _duration,
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetHeight,
              child: _Sheet(
                open: _open,
                onToggle: () => _setOpen(!_open),
                onDrag: (velocity) => _setOpen(velocity < 0),
                children: widget.panelChildren,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.open, required this.onToggle, required this.onDrag, required this.children});

  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<double> onDrag;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    elevation: 12,
    shadowColor: const Color(0x40102F62),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Semantics(
          button: true,
          expanded: open,
          label: open ? 'Recolher painel' : 'Abrir painel',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 80) onDrag(velocity);
            },
            child: SizedBox(
              height: 30,
              width: double.infinity,
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.handle, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            children: [...children, const AppFooter()],
          ),
        ),
      ],
    ),
  );
}
