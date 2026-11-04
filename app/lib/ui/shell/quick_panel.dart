// 快捷入口: the panel a left swipe over the chat pulls in from the right, the
// sessions drawer's mirror. It lists destinations the drawer already has and
// opens them the way the drawer does; what each page requires stays with the
// page. Which ones and in what order: 设置 › 界面 (quick_panel_items_sheet.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../state/quick_panel_state.dart';
import '../theme/app_icons.dart';
import '../theme/theme.dart';
import 'drawer/drawer_destination.dart';

/// A destination as 快捷入口 and its settings show it, by the name and the
/// glyph its other ways in use.
extension DrawerDestinationLook on DrawerDestination {
  IconData get icon => switch (this) {
    DrawerDestination.web => AppIcons.webApp,
    DrawerDestination.remote => AppIcons.remoteHosts,
    DrawerDestination.plugins => AppIcons.plugin,
    DrawerDestination.engine => AppIcons.engine,
    DrawerDestination.settings => AppIcons.settings,
    DrawerDestination.settingsSearch => AppIcons.search,
    DrawerDestination.features => AppIcons.allFeatures,
  };

  String label(L10n l10n) => switch (this) {
    DrawerDestination.web => l10n.commonWeb,
    DrawerDestination.remote => l10n.commonRemoteHost,
    DrawerDestination.plugins => l10n.hubPlugins,
    DrawerDestination.engine => l10n.hubSettingsEngine,
    DrawerDestination.settings => l10n.commonSettings,
    DrawerDestination.settingsSearch => l10n.searchSettingsHint,
    DrawerDestination.features => l10n.hubSettingsAllFeatures,
  };
}

class QuickPanel extends ConsumerWidget {
  const QuickPanel({super.key, required this.motion, required this.onOpen});

  /// The panel's 0 → 1 animation: while it moves the glass drops its blur,
  /// like the pulled-over drawer's.
  final Animation<double> motion;
  final ValueChanged<DrawerDestination> onOpen;

  /// Short labels need less than the drawer's 320.
  static const width = 260.0;

  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(AppShape.xl),
    bottomLeft: Radius.circular(AppShape.xl),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = ref.watch(quickPanelProvider.select((p) => p.items));
    final content = Material(
      type: MaterialType.transparency,
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.shellQuickPanel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final destination in items) _Row(destination: destination, onTap: () => onOpen(destination)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 13),
              child: Text(
                l10n.shellQuickPanelHint('${l10n.commonSettings} › ${l10n.hubSettingsInterface}'),
                style: theme.textTheme.bodySmall?.copyWith(color: DshColors.of(context).textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
    // 拖出来就是毛玻璃。比抽屉再透一档，并且不带外投影：面板贴着屏幕
    // 右边时，那圈阴影在背后发亮的内容上看起来就是一块灰。
    final surfaces = DshSurfaces.of(context);
    // 面板宽度固定 260，右侧系统安全区留在玻璃外面：之前整块玻璃撑满
    // 「260 + 安全区」，右边就多出一条没有内容的灰边。
    return Padding(
      padding: EdgeInsets.only(right: MediaQuery.paddingOf(context).right),
      child: SizedBox(
        width: QuickPanel.width,
        child: GlassSurface(
          tier: GlassTier.sheet,
          borderRadius: _radius,
          // 只去掉外投影（贴右边缘时像一块灰），填充保持作者的原样。
          style: surfaces.sheet.copyWith(shadows: const []),
          child: content,
        ),
      ),
    );
  }
}

/// A row on the drawer's grid: the highlight's edge at 10, the glyph at 20.
class _Row extends StatelessWidget {
  const _Row({required this.destination, required this.onTap});

  final DrawerDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = destination.label(context.l10n);
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('quick-panel-${destination.name}'),
        onTap: onTap,
        customBorder: Squircle.border(AppShape.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Icon(destination.icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
