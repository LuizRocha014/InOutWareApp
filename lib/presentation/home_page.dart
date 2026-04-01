import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/presentation/controllers/home_controller.dart';
import 'package:in_out_ware_app/presentation/widgets/module_item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller = Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InOutWareApp'),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
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
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemCount: controller.menuitems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = controller.menuitems[index];
                    return ModuleItemWidget(
                      icon: item.icon,
                      title: item.title,
                      subTitle: item.subTitle,
                      route: item.route,
                      onTap: () => controller.navigateTo(item.route),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
