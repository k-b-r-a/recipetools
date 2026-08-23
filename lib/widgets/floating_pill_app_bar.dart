import 'dart:ui';
import 'package:flutter/material.dart';

Widget buildFloatingPillAppBar({
  required BuildContext context,
  required String title,
  required ScrollController controller,
  Widget? titleWidget,
  Widget? trailing,
  Widget? underTitle,
  PreferredSizeWidget? bottom,
  List<Widget>? actions,
}) {
  final theme = Theme.of(context);
  final double extraHeight = (bottom?.preferredSize.height ?? 0.0) + (underTitle != null ? 30.0 : 0.0);
  return SliverAppBar(
    pinned: true,
    expandedHeight: 120 + extraHeight,
    collapsedHeight: 70 + (underTitle != null ? 18.0 : 0.0) + (bottom?.preferredSize.height ?? 0.0),
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    actions: actions,
    bottom: bottom,
    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveMaxHeight = constraints.maxHeight - (bottom?.preferredSize.height ?? 0.0);
        final double percentage =
            (effectiveMaxHeight - kToolbarHeight) / (120 + (underTitle != null ? 30.0 : 0.0) - kToolbarHeight);
        final bool isCollapsed = effectiveMaxHeight <= kToolbarHeight + 20;

        return GestureDetector(
          onTap: () {
            controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                bottom: isCollapsed ? 12 : 16,
                left: isCollapsed ? 30 : 0,
                right: isCollapsed ? 30 : 0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(
                  alpha: isCollapsed ? 0.3 : 0.0,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isCollapsed ? 0.2 : 0.0,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isCollapsed)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: titleWidget ??
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16 + (4 * percentage.clamp(0, 1)),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (trailing != null) ...[
                                      const SizedBox(width: 8),
                                      trailing,
                                    ],
                                  ],
                                ),
                                if (underTitle != null) ...[
                                  const SizedBox(height: 6),
                                  underTitle,
                                ],
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
