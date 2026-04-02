import 'package:componentes_lr/componentes_lr.dart';
import 'package:in_out_ware_app/core/auth/auth_login_service.dart';
import 'package:in_out_ware_app/core/auth/auth_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_module/modules/data/stock_api_settings.dart';

/// Estado global de autenticação + persistência ([SharedPreferences]).
class AppAuth {
  AppAuth._();

  static final AppAuth I = AppAuth._();

  static const String defaultBaseUrl = 'https://localhost:7001';

  SharedPreferences? _prefs;
  String? _cachedToken;
  String _cachedBaseUrl = defaultBaseUrl;
  bool _savePassword = false;
  String? _savedUsername;
  String? _savedPassword;

  /// Rota inicial após [initialize] (`/` ou `/login`).
  String initialRoute = '/login';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = _prefs!.getString(AuthPrefsKeys.accessToken);
    _cachedBaseUrl =
        _prefs!.getString(AuthPrefsKeys.apiBaseUrl) ?? defaultBaseUrl;
    _savePassword = _prefs!.getBool(AuthPrefsKeys.savePassword) ?? false;
    _savedUsername = _prefs!.getString(AuthPrefsKeys.savedUsername);
    _savedPassword = _prefs!.getString(AuthPrefsKeys.savedPassword);

    _syncStockModuleSettings();

    if (!_savePassword) {
      await clearSessionToken();
      initialRoute = '/login';
      return;
    }

    if (_savedUsername == null ||
        _savedUsername!.isEmpty ||
        _savedPassword == null ||
        _savedPassword!.isEmpty) {
      initialRoute = '/login';
      return;
    }

    final renewed = await _silentLogin();
    initialRoute = renewed ? '/' : '/login';
  }

  Future<bool> _silentLogin() async {
    final result = await AuthLoginService.login(
      baseUrl: _cachedBaseUrl,
      username: _savedUsername!,
      password: _savedPassword!,
    );
    if (!result.isSuccess || result.accessToken == null) {
      await clearSessionToken();
      return false;
    }
    await _writeToken(result.accessToken!);
    _syncStockModuleSettings();
    return true;
  }

  /// Token atual (memória + prefs). Use [getToken] para acesso global.
  String? get accessToken => _cachedToken;

  String get apiBaseUrl => _cachedBaseUrl;

  bool get savePasswordEnabled => _savePassword;

  void _syncStockModuleSettings() {
    try {
      final s = instanceManager.get<StockApiSettings>();
      s.baseUrl = _cachedBaseUrl;
      s.accessToken = _cachedToken;
    } catch (_) {}
  }

  Future<void> setApiBaseUrl(String url) async {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    final value = trimmed.isEmpty ? defaultBaseUrl : trimmed;
    _cachedBaseUrl = value;
    await _prefs?.setString(AuthPrefsKeys.apiBaseUrl, value);
    _syncStockModuleSettings();
  }

  Future<void> applyLoginSuccess({
    required String token,
    required bool rememberCredentials,
    required String username,
    required String password,
  }) async {
    await _writeToken(token);
    await _prefs?.setBool(AuthPrefsKeys.savePassword, rememberCredentials);
    if (rememberCredentials) {
      await _prefs?.setString(AuthPrefsKeys.savedUsername, username);
      await _prefs?.setString(AuthPrefsKeys.savedPassword, password);
      _savePassword = true;
      _savedUsername = username;
      _savedPassword = password;
    } else {
      await _prefs?.remove(AuthPrefsKeys.savedUsername);
      await _prefs?.remove(AuthPrefsKeys.savedPassword);
      _savePassword = false;
      _savedUsername = null;
      _savedPassword = null;
    }
    _syncStockModuleSettings();
  }

  Future<void> _writeToken(String token) async {
    _cachedToken = token;
    await _prefs?.setString(AuthPrefsKeys.accessToken, token);
  }

  /// Remove só o token (mantém URL e opção “salvar senha” / credenciais).
  Future<void> clearSessionToken() async {
    _cachedToken = null;
    await _prefs?.remove(AuthPrefsKeys.accessToken);
    _syncStockModuleSettings();
  }

  /// Logout completo: token, credenciais e flag.
  Future<void> signOut() async {
    _cachedToken = null;
    _savePassword = false;
    _savedUsername = null;
    _savedPassword = null;
    await _prefs?.remove(AuthPrefsKeys.accessToken);
    await _prefs?.setBool(AuthPrefsKeys.savePassword, false);
    await _prefs?.remove(AuthPrefsKeys.savedUsername);
    await _prefs?.remove(AuthPrefsKeys.savedPassword);
    _syncStockModuleSettings();
  }

  String? get savedUsernameForForm => _savedUsername;
  String? get savedPasswordForForm => _savePassword ? _savedPassword : null;
}
