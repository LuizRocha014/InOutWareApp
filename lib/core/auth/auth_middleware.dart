import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/get_token.dart';

/// Exige token para rotas protegidas.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final t = getToken();
    if (t != null && t.isNotEmpty) return null;
    return const RouteSettings(name: '/login');
  }
}
