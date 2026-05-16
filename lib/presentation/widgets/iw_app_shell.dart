import 'package:componentes_lr/componentes_lr.dart' show isDesktopFormFactor;
import 'package:flutter/material.dart';
import 'package:in_out_ware_app/presentation/theme/iw_design.dart';
import 'package:in_out_ware_app/presentation/widgets/iw_brand.dart';

/// Modelo simples para o slot de breadcrumb do AppBar.
class IwBreadcrumbData {
  const IwBreadcrumbData({this.icon, required this.label, this.sub});
  final IconData? icon;
  final String label;
  final String? sub;
}

/// AppBar unificado (mobile + desktop) com fita superior de marca.
///
/// - Mobile: brand logo + barra de busca compacta + ações.
/// - Desktop: brand logo + wordmark + breadcrumb + busca larga + sync pill + alertas + avatar.
class IwAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IwAppBar({
    super.key,
    this.breadcrumb,
    this.showSearch = true,
    this.searchHint,
    this.alerts = 0,
    this.onSearchTap,
    this.onLogout,
    this.onBack,
    this.userInitials = 'LR',
  });

  final IwBreadcrumbData? breadcrumb;
  final bool showSearch;
  final String? searchHint;
  final int alerts;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLogout;
  final VoidCallback? onBack;
  final String userInitials;

  @override
  Size get preferredSize => const Size.fromHeight(63);

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktopFormFactor;
    return Material(
      color: IwColors.surface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IwBrandRibbon(),
          SizedBox(
            height: IwSizing.appBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    _IwCircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: onBack!,
                      tooltip: 'Voltar',
                    ),
                    const SizedBox(width: 6),
                  ],
                  const IwBrandLogo(size: 34),
                  if (desktop) ...[
                    const SizedBox(width: 10),
                    const IwWordmark(size: 15),
                  ],
                  if (desktop && breadcrumb != null) ...[
                    const SizedBox(width: 10),
                    IwBreadcrumb(
                      icon: breadcrumb!.icon,
                      label: breadcrumb!.label,
                      sub: breadcrumb!.sub,
                    ),
                  ],
                  if (showSearch) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: _IwSearchPill(
                          desktop: desktop,
                          hint: searchHint,
                          onTap: onSearchTap,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  const SizedBox(width: 10),
                  if (desktop) ...[
                    const IwSyncPill(),
                    const SizedBox(width: 6),
                  ],
                  _AlertsBell(count: alerts),
                  if (onLogout != null) ...[
                    const SizedBox(width: 2),
                    _IwCircleIconButton(
                      icon: Icons.logout,
                      onTap: onLogout!,
                      tooltip: 'Sair',
                    ),
                  ],
                  const SizedBox(width: 6),
                  IwAvatar(initials: userInitials, size: desktop ? 34 : 30),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: IwColors.outlineVariant),
        ],
      ),
    );
  }
}

class _IwCircleIconButton extends StatelessWidget {
  const _IwCircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double iconSize;
  static const double size = 38;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        icon: Icon(icon),
        color: IwColors.onSurfaceVariant,
        onPressed: onTap,
      ),
    );
  }
}

class _IwSearchPill extends StatelessWidget {
  const _IwSearchPill({required this.desktop, this.hint, this.onTap});

  final bool desktop;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final h = hint ??
        (desktop
            ? 'Buscar produto, lote ou SKU…'
            : 'Buscar…');
    final radius =
        BorderRadius.circular(desktop ? IwRadius.sm + 2 : 999);
    return Material(
      color: IwColors.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: desktop ? 380 : double.infinity,
            minHeight: desktop ? 38 : 36,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search,
                    size: 18, color: IwColors.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    h,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: IwColors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (desktop)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: IwColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: IwColors.outlineVariant),
                    ),
                    child: const Text(
                      '⌘ K',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: IwColors.onSurfaceVariant,
                      ),
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

class _AlertsBell extends StatelessWidget {
  const _AlertsBell({this.count = 0});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IwCircleIconButton(
          icon: Icons.notifications_outlined,
          onTap: () {},
          tooltip: 'Alertas',
          iconSize: 22,
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: IwColors.error,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: IwColors.surface, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: IwColors.onError,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shell padrão de página: IwAppBar + corpo centralizado com max 1200 no desktop.
class IwModulePage extends StatelessWidget {
  const IwModulePage({
    super.key,
    required this.body,
    this.breadcrumb,
    this.onBack,
    this.onLogout,
    this.onSearchTap,
    this.alerts = 0,
    this.userInitials = 'LR',
    this.padding,
  });

  final Widget body;
  final IwBreadcrumbData? breadcrumb;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;
  final VoidCallback? onSearchTap;
  final int alerts;
  final String userInitials;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktopFormFactor;
    return Scaffold(
      backgroundColor: IwColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IwAppBar(
              breadcrumb: breadcrumb,
              onBack: onBack,
              onLogout: onLogout,
              onSearchTap: onSearchTap,
              alerts: alerts,
              userInitials: userInitials,
            ),
            Expanded(
              child: Padding(
                padding: padding ??
                    EdgeInsets.symmetric(
                      horizontal: desktop ? IwSpacing.s8 : IwSpacing.s4,
                      vertical: desktop ? IwSpacing.s6 : IwSpacing.s4,
                    ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
