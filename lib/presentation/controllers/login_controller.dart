import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/core/auth/auth_login_service.dart';

class LoginController extends GetxController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final savePassword = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    usernameCtrl.text = AppAuth.I.savedUsernameForForm ?? '';
    passwordCtrl.text = AppAuth.I.savedPasswordForForm ?? '';
    savePassword.value = AppAuth.I.savePasswordEnabled;
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final user = usernameCtrl.text.trim();
    final pass = passwordCtrl.text;
    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar('Login', 'Preencha usuário e senha.');
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthLoginService.login(
        baseUrl: AppAuth.I.apiBaseUrl,
        username: user,
        password: pass,
      );
      if (!result.isSuccess || result.accessToken == null) {
        Get.snackbar('Login', result.errorMessage ?? 'Falha na autenticação.');
        return;
      }
      await AppAuth.I.applyLoginSuccess(
        token: result.accessToken!,
        rememberCredentials: savePassword.value,
        username: user,
        password: pass,
      );
      Get.offAllNamed('/');
    } finally {
      isLoading.value = false;
    }
  }
}
