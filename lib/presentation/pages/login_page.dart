import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/presentation/controllers/login_controller.dart';
import 'package:in_out_ware_app/presentation/theme/iw_design.dart';
import 'package:in_out_ware_app/presentation/widgets/iw_brand.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller =
      Get.put(LoginController(), tag: 'login_page');

  String _versionLabel = '…';
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  void dispose() {
    Get.delete<LoginController>(tag: 'login_page');
    super.dispose();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _versionLabel = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _versionLabel = '—');
    }
  }

  void _onVersionTap() {
    final now = DateTime.now();
    if (_lastVersionTap == null ||
        now.difference(_lastVersionTap!) > const Duration(seconds: 2)) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      _openUrlSheet();
    }
  }

  Future<void> _openUrlSheet() async {
    final urlCtrl = TextEditingController(text: AppAuth.I.apiBaseUrl);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: 20 + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'URL da API',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: IwColors.onSurface,
                  letterSpacing: -0.11,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Base sem barra final (ex.: https://localhost:7001)',
                style: TextStyle(
                  fontSize: 13,
                  color: IwColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await AppAuth.I.setApiBaseUrl(urlCtrl.text);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL da API salva.')),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IwColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: IwSizing.loginMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                  const _BrandBlock(),
                  const SizedBox(height: 32),
                  const Text(
                    'Entre com sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w600,
                      color: IwColors.onSurface,
                      letterSpacing: -0.11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Acesse o sistema com suas credenciais da API',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: IwColors.onSurfaceVariant,
                      height: 18 / 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: controller.usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller.passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => controller.submit(),
                    autofillHints: const [AutofillHints.password],
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => _SavePasswordTile(
                      value: controller.savePassword.value,
                      onChanged: (v) =>
                          controller.savePassword.value = v ?? false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submit,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onVersionTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Versão $_versionLabel · 5 toques para configurar URL da API',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11.5,
                          letterSpacing: 0.46,
                          color: IwColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        IwBrandLogo(size: 72),
        SizedBox(height: 14),
        IwWordmark(size: 26),
        SizedBox(height: 6),
        Text(
          'WAREHOUSE MANAGEMENT',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: IwColors.onSurfaceVariant,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SavePasswordTile extends StatelessWidget {
  const _SavePasswordTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(IwRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salvar senha',
                    style: TextStyle(
                      fontSize: 14,
                      color: IwColors.onSurface,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Entrar automaticamente e renovar o token ao abrir o app',
                    style: TextStyle(
                      fontSize: 12,
                      color: IwColors.onSurfaceVariant,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
