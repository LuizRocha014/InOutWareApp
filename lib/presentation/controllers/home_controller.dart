import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuModuleItemEntity {
  final String title;
  final String? subTitle;
  final String route;
  final IconData icon;

  MenuModuleItemEntity({
    required this.title,
    this.subTitle,
    required this.route,
    required this.icon,
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
        subTitle: 'Módulo sale_module',
        route: '/sale',
        icon: Icons.point_of_sale_outlined,
      ),
      MenuModuleItemEntity(
        title: 'Estoque',
        subTitle: 'Módulo stock_module',
        route: '/stock',
        icon: Icons.inventory_2_outlined,
      ),
      MenuModuleItemEntity(
        title: 'Transferências',
        subTitle: 'Módulo transfer_module',
        route: '/transfer',
        icon: Icons.swap_horiz_outlined,
      ),
    ]);
  }

  void navigateTo(String route) {
    Get.toNamed(route);
  }
}
