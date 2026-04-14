import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/presentation/controllers/home_controller.dart';
import 'package:in_out_ware_app/presentation/widgets/branch_selection_dialog.dart';
import 'package:in_out_ware_app/presentation/widgets/module_item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller = Get.put(HomeController(), permanent: true);

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
    final missing =
        AppAuth.I.selectedBranchId == null || AppAuth.I.selectedBranchId!.isEmpty;
    if (!fromLogin && !missing) return;
    await showBranchSelectionDialog(
      context,
      preselectedBranchId: AppAuth.I.selectedBranchId,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktopFormFactor) {
      return _DesktopHome(controller: controller, branchName: AppAuth.I.selectedBranchName);
    }
    return _MobileHome(controller: controller, branchName: AppAuth.I.selectedBranchName);
  }
}

class _MobileHome extends StatelessWidget {
  const _MobileHome({required this.controller, this.branchName});

  final HomeController controller;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InOutWareApp'),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await AppAuth.I.clearSessionToken();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              'Início',
              textColor: scheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            if (branchName != null && branchName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Filial: $branchName',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final items = controller.menuitems.toList();
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ModuleItemWidget(
                      icon: item.icon,
                      title: item.title,
                      subTitle: item.subTitle,
                      route: item.route,
                      onTap: () => controller.navigateTo(item.route),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopHome extends StatelessWidget {
  const _DesktopHome({required this.controller, this.branchName});

  final HomeController controller;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            elevation: 1,
            color: scheme.surface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                    children: [
                      Icon(Icons.warehouse_outlined, color: scheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'InOutWareApp',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (branchName != null && branchName!.isNotEmpty)
                            Text(
                              'Filial: $branchName',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Sair',
                        onPressed: () async {
                          await AppAuth.I.clearSessionToken();
                          Get.offAllNamed('/login');
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        'Início',
                        textColor: scheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      if (branchName != null && branchName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Filial: $branchName',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Selecione um módulo para continuar.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Expanded(
                        child: Obx(() {
                          final items = controller.menuitems.toList();
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final colCount = w >= 900 ? 3 : w >= 600 ? 2 : 1;
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: colCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 152,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ModuleItemWidget(
                                    icon: item.icon,
                                    title: item.title,
                                    subTitle: item.subTitle,
                                    route: item.route,
                                    compact: true,
                                    onTap: () => controller.navigateTo(item.route),
                                  );
                                },
                              );
                            },
                          );
                        }),
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
  }
}
