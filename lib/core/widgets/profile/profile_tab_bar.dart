import 'package:flutter/material.dart';

class ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  ProfileTabBarDelegate({required this.tabController});

  final TabController tabController;

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFDBDBDB),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFDBDBDB),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: theme.colorScheme.onSurface,
        indicatorWeight: 1.5,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on, size: 24)),
          Tab(icon: Icon(Icons.person_pin_outlined, size: 26)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(ProfileTabBarDelegate oldDelegate) =>
      oldDelegate.tabController != tabController;
}
