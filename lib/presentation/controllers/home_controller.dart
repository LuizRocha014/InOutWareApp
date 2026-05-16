import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/presentation/widgets/module_item_widget.dart';

class MenuModuleItemEntity {
  final String title;
  final String? subTitle;
  final String route;
  final IconData icon;
  final IwModulePalette palette;
  final List<IwKpi> kpis;
  final IwModuleStatus? status;

  MenuModuleItemEntity({
    required this.title,
    this.subTitle,
    required this.route,
    required this.icon,
    required this.palette,
    this.kpis = const [],
    this.status,
  });
}

class HomeController extends GetxController {
  HomeController();

  final RxList<MenuModuleItemEntity> menuitems = <MenuModuleItemEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    menuitems.assignAll([
      MenuModuleItemEntity(
        title: 'Vendas',
        subTitle: 'Caixa, baixa de estoque e tickets do dia',
        route: '/sale',
        icon: Icons.point_of_sale_outlined,
        palette: IwModulePalette.sales,
      ),
      MenuModuleItemEntity(
        title: 'Estoque',
        subTitle: 'Produtos, lotes e entradas — multi-filial',
        route: '/stock',
        icon: Icons.inventory_2_outlined,
        palette: IwModulePalette.stock,
      ),
      MenuModuleItemEntity(
        title: 'Transferências',
        subTitle: 'Movimentações entre filiais',
        route: '/transfer',
        icon: Icons.swap_horiz_outlined,
        palette: IwModulePalette.transfer,
      ),
    ]);
  }

  void navigateTo(String route) {
    Get.toNamed(route);
  }
}
