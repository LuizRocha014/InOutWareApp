import 'package:componentes_lr/componentes_lr.dart';
import 'package:in_out_ware_app/core/auth/auth_login_service.dart';
import 'package:in_out_ware_app/core/auth/auth_prefs_keys.dart';
import 'package:in_out_ware_app/core/session/auth_user_snapshot.dart';
import 'package:in_out_ware_app/core/session/user_session.dart';
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
  String? _selectedBranchId;
  String? _selectedBranchName;

  /// Rota inicial após [initialize] (`/` ou `/login`).
  String initialRoute = '/login';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await UserSession.I.restoreFromPrefsInstance(_prefs!);
    _cachedToken = _prefs!.getString(AuthPrefsKeys.accessToken);
    _cachedBaseUrl =
        _prefs!.getString(AuthPrefsKeys.apiBaseUrl) ?? defaultBaseUrl;
    _savePassword = _prefs!.getBool(AuthPrefsKeys.savePassword) ?? false;
    _savedUsername = _prefs!.getString(AuthPrefsKeys.savedUsername);
    _savedPassword = _prefs!.getString(AuthPrefsKeys.savedPassword);
    _selectedBranchId = _prefs!.getString(AuthPrefsKeys.selectedBranchId);
    _selectedBranchName = _prefs!.getString(AuthPrefsKeys.selectedBranchName);

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
    if (result.user != null && result.user!.hasIdentity) {
      UserSession.I.applySnapshot(result.user!);
    } else if (_savedUsername != null && _savedUsername!.isNotEmpty) {
      UserSession.I.applySnapshot(AuthUserSnapshot(username: _savedUsername));
    }
    _syncStockModuleSettings();
    return true;
  }

  /// Token atual (memória + prefs). Use [getToken] para acesso global.
  String? get accessToken => _cachedToken;

  String get apiBaseUrl => _cachedBaseUrl;

  bool get savePasswordEnabled => _savePassword;

  /// Filial escolhida para operações de estoque/vendas (persistida entre sessões até logout).
  String? get selectedBranchId => _selectedBranchId;

  String? get selectedBranchName => _selectedBranchName;

  Future<void> setSelectedBranch({
    required String id,
    required String name,
  }) async {
    _selectedBranchId = id;
    _selectedBranchName = name;
    await _prefs?.setString(AuthPrefsKeys.selectedBranchId, id);
    await _prefs?.setString(AuthPrefsKeys.selectedBranchName, name);
  }

  Future<void> _clearSelectedBranch() async {
    _selectedBranchId = null;
    _selectedBranchName = null;
    await _prefs?.remove(AuthPrefsKeys.selectedBranchId);
    await _prefs?.remove(AuthPrefsKeys.selectedBranchName);
  }

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
    AuthUserSnapshot? user,
  }) async {
    await _writeToken(token);
    final snapshot =
        (user != null && user.hasIdentity) ? user : AuthUserSnapshot(username: username);
    UserSession.I.applySnapshot(snapshot);
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
    await UserSession.I.clear();
    await _clearSelectedBranch();
    _syncStockModuleSettings();
  }

  /// Logout completo: token, credenciais e flag.
  Future<void> signOut() async {
    _cachedToken = null;
    _savePassword = false;
    _savedUsername = null;
    _savedPassword = null;
    await UserSession.I.clear();
    await _prefs?.remove(AuthPrefsKeys.accessToken);
    await _prefs?.setBool(AuthPrefsKeys.savePassword, false);
    await _prefs?.remove(AuthPrefsKeys.savedUsername);
    await _prefs?.remove(AuthPrefsKeys.savedPassword);
    await _clearSelectedBranch();
    _syncStockModuleSettings();
  }

  String? get savedUsernameForForm => _savedUsername;
  String? get savedPasswordForForm => _savePassword ? _savedPassword : null;
}
