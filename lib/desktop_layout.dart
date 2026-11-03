import 'package:flutter/material.dart';

import 'app_build.dart';

abstract final class DesktopLayout {
  static const breakpoint = 840.0;
  static const expandedBreakpoint = 1100.0;
  static const contentWidth = 1440.0;
}

class DesktopContent extends StatelessWidget {
  const DesktopContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DesktopLayout.contentWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    required this.canDownload,
    required this.onSettings,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final bool canDownload;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: extended ? 208 : 88,
      child: Material(
        color: colors.surfaceContainerLow,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 20 : 12,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_rounded,
                    size: 32,
                    color: colors.primary,
                  ),
                  if (extended) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: NavigationRail(
                extended: extended,
                minWidth: 88,
                minExtendedWidth: 208,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                backgroundColor: colors.surfaceContainerLow,
                useIndicator: true,
                indicatorColor: colors.primaryContainer,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                groupAlignment: -1,
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore_rounded),
                    label: Text('发现'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.bookmark_border_rounded),
                    selectedIcon: Icon(Icons.bookmark_rounded),
                    label: Text('追剧'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.history_rounded),
                    label: Text('最近观看'),
                  ),
                  if (canDownload)
                    const NavigationRailDestination(
                      icon: Icon(Icons.download_outlined),
                      selectedIcon: Icon(Icons.download_rounded),
                      label: Text('下载'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: extended
                  ? TextButton.icon(
                      onPressed: onSettings,
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('设置与备份'),
                    )
                  : IconButton(
                      tooltip: '设置与备份',
                      onPressed: onSettings,
                      icon: const Icon(Icons.settings_outlined),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopPlaybackLayout extends StatelessWidget {
  const DesktopPlaybackLayout({
    super.key,
    required this.video,
    required this.information,
    required this.episodes,
    required this.description,
  });
  final Widget video;
  final Widget information;
  final Widget episodes;
  final Widget description;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final colors = Theme.of(context).colorScheme;
      final spacing = constraints.maxWidth >= 1100 ? 24.0 : 16.0;
      return Padding(
        padding: EdgeInsets.fromLTRB(spacing, 8, spacing, spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColoredBox(color: Colors.black, child: video),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: information,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: (constraints.maxWidth * .25).clamp(280.0, 360.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: '选集'),
                            Tab(text: '简介'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(children: [episodes, description]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
