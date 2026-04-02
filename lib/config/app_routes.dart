import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/auth_middleware.dart';
import 'package:in_out_ware_app/presentation/home_page.dart';
import 'package:in_out_ware_app/presentation/pages/login_page.dart';
import 'package:sale_module/presentation_export.dart';
import 'package:stock_module/presentation_export.dart';
import 'package:transfer_module/presentation_export.dart';

class AppRoutes {
  AppRoutes._init({required BuildContext context});

  static AppRoutes? _instance;

  factory AppRoutes({required BuildContext context}) {
    return _instance ??= AppRoutes._init(context: context);
  }

  static final List<GetPage> routes = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(
      name: '/',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/sale',
      page: () => const SaleHomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/stock',
      page: () => const StockHomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/transfer',
      page: () => const TransferHomePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
