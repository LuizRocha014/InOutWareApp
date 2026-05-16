import 'package:componentes_lr/componentes_lr.dart' show isDesktopFormFactor;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/core/session/user_session.dart';
import 'package:in_out_ware_app/presentation/controllers/home_controller.dart';
import 'package:in_out_ware_app/presentation/theme/iw_design.dart';
import 'package:in_out_ware_app/presentation/widgets/branch_selection_dialog.dart';
import 'package:in_out_ware_app/presentation/widgets/iw_app_shell.dart';
import 'package:in_out_ware_app/presentation/widgets/module_item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller =
      Get.put(HomeController(), permanent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBranchPickerIfNeeded();
    });
  }

  Future<void> _openBranchPickerIfNeeded() async {
    if (!mounted) return;
    final args = Get.arguments;
    final fromLogin = args is Map && args['requireBranchPicker'] == true;
    final missing = AppAuth.I.selectedBranchId == null ||
        AppAuth.I.selectedBranchId!.isEmpty;
    if (!fromLogin && !missing) return;
    await showBranchSelectionDialog(
      context,
      preselectedBranchId: AppAuth.I.selectedBranchId,
    );
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    await AppAuth.I.clearSessionToken();
    Get.offAllNamed('/login');
  }

  String _greeting() {
    final label = UserSession.I.displayLabel.trim();
    if (label.isEmpty) return 'Olá';
    final first = label.split(RegExp(r'[ .]')).first;
    if (first.isEmpty) return 'Olá';
    return 'Olá, ${first[0].toUpperCase()}${first.substring(1)}';
  }

  String _initials() {
    final label = UserSession.I.displayLabel.trim();
    if (label.isEmpty) return 'IW';
    final parts = label.split(RegExp(r'[ .]')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'IW';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _todayLabel() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    return 'Hoje · $dd/$mm';
  }

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktopFormFactor;
    final branchName = AppAuth.I.selectedBranchName;

    return IwModulePage(
      onLogout: _logout,
      userInitials: _initials(),
      breadcrumb: desktop
          ? const IwBreadcrumbData(icon: Icons.home_outlined, label: 'Início')
          : null,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: desktop ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              greeting: _greeting(),
              branchName: branchName,
              today: _todayLabel(),
              desktop: desktop,
            ),
            SizedBox(height: desktop ? IwSpacing.s6 : IwSpacing.s4),
            Obx(() {
              final items = controller.menuitems.toList();
              return LayoutBuilder(
                builder: (context, c) {
                  final cols = desktop
                      ? (c.maxWidth >= 1400
                          ? 3
                          : c.maxWidth >= 760
                              ? 2
                              : 1)
                      : 1;
                  if (cols == 1) {
                    return Column(
                      children: [
                        for (final item in items) ...[
                          ModuleItemWidget(
                            icon: item.icon,
                            title: item.title,
                            subTitle: item.subTitle,
                            route: item.route,
                            palette: item.palette,
                            kpis: item.kpis,
                            status: item.status,
                            onTap: () => controller.navigateTo(item.route),
                          ),
                          const SizedBox(height: IwSpacing.s3),
                        ],
                      ],
                    );
                  }
                  return _Grid(
                    items: items,
                    controller: controller,
                    columns: cols,
                  );
                },
              );
            }),
            SizedBox(height: desktop ? IwSpacing.s7 : IwSpacing.s5),
            _QuickActions(desktop: desktop, controller: controller),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.branchName,
    required this.today,
    required this.desktop,
  });

  final String greeting;
  final String? branchName;
  final String today;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: desktop ? 28 : 22,
                  height: desktop ? 36 / 28 : 28 / 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.28,
                  color: IwColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                branchName != null && branchName!.isNotEmpty
                    ? 'Filial: $branchName · selecione um módulo para continuar.'
                    : 'Selecione um módulo para continuar.',
                style: const TextStyle(
                  fontSize: 14,
                  color: IwColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (desktop)
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: IwColors.onSecondaryContainer,
              backgroundColor: IwColors.secondaryContainer,
              side: BorderSide.none,
            ),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(today),
          ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.items,
    required this.controller,
    required this.columns,
  });

  final List<MenuModuleItemEntity> items;
  final HomeController controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: IwSpacing.s3,
        mainAxisSpacing: IwSpacing.s3,
        mainAxisExtent: 164,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ModuleItemWidget(
          icon: item.icon,
          title: item.title,
          subTitle: item.subTitle,
          route: item.route,
          palette: item.palette,
          kpis: item.kpis,
          status: item.status,
          compact: true,
          onTap: () => controller.navigateTo(item.route),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.desktop, required this.controller});

  final bool desktop;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionEntry(
        icon: Icons.qr_code_scanner,
        label: 'Ler código',
        onTap: () => controller.navigateTo('/stock'),
      ),
      _ActionEntry(
        icon: Icons.add_circle_outline,
        label: 'Nova entrada',
        onTap: () => controller.navigateTo('/stock'),
      ),
      _ActionEntry(
        icon: Icons.point_of_sale_outlined,
        label: 'Abrir caixa',
        onTap: () => controller.navigateTo('/sale'),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(desktop ? IwSpacing.s5 : IwSpacing.s4),
      decoration: BoxDecoration(
        color: IwColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(IwRadius.lg),
        border: Border.all(color: IwColors.outlineVariant),
      ),
      child: desktop
          ? Row(
              children: [
                const Expanded(child: _QuickHeadline()),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in actions)
                      OutlinedButton.icon(
                        onPressed: a.onTap,
                        icon: Icon(a.icon, size: 18),
                        label: Text(a.label),
                      ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _QuickHeadline(),
                const SizedBox(height: IwSpacing.s3),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in actions)
                      OutlinedButton.icon(
                        onPressed: a.onTap,
                        icon: Icon(a.icon, size: 18),
                        label: Text(a.label),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ActionEntry {
  const _ActionEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickHeadline extends StatelessWidget {
  const _QuickHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Atalhos rápidos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: IwColors.onSurface,
            height: 1.3,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Ações que você usa todos os dias.',
          style: TextStyle(
            fontSize: 13,
            color: IwColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
