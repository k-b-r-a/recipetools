import 'dart:ui';
import 'package:flutter/material.dart';

Widget buildFloatingPillAppBar({
  required BuildContext context,
  required String title,
  required ScrollController controller,
}) {
  final theme = Theme.of(context);
  return SliverAppBar(
    pinned: true,
    expandedHeight: 120,
    collapsedHeight: 70,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final double percentage =
            (constraints.maxHeight - kToolbarHeight) / (120 - kToolbarHeight);
        final bool isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;

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
                left: isCollapsed ? 60 : 0,
                right: isCollapsed ? 60 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isCollapsed ? 5 : 0,
                    sigmaY: isCollapsed ? 5 : 0,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w900,
                      fontSize: 16 + (4 * percentage.clamp(0, 1)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
