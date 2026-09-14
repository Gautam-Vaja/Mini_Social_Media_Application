import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onAddPressed;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          height: 68,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(38),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                icon: Icons.home_rounded,
                index: 0,
                route: '/home',
              ),
              _navItem(
                context,
                icon: Icons.search_rounded,
                index: 1,
                route: '/search',
              ),
              _addButton(context),
              _navItem(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                index: 2,
                route: '/chat',
              ),
              _navItem(
                context,
                icon: Icons.person_outline_rounded,
                index: 3,
                route: '/profile',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSelected = currentIndex == index;

    return IconButton(
      onPressed: () {
        if (currentIndex != index) {
          context.go(route);
        }
      },
      splashRadius: 25,
      tooltip: _getTooltip(index),
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 27,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, size: 30, color: colorScheme.onPrimary),
      ),
    );
  }

  String _getTooltip(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Chat';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }
}
