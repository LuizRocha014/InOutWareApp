import 'package:in_out_ware_app/core/auth/auth_prefs_keys.dart';
import 'package:in_out_ware_app/core/session/auth_user_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sessão do usuário atual: identidade vinda do login, acessível em qualquer lugar via [UserSession.I].
///
/// É persistida em [SharedPreferences] para sobreviver a reinícios do app (com token válido).
/// Limpa junto com [AppAuth] no logout.
class UserSession {
  UserSession._();

  static final UserSession I = UserSession._();

  AuthUserSnapshot? _snapshot;

  /// Snapshot completo (pode ser null antes do login ou após logout).
  AuthUserSnapshot? get snapshot => _snapshot;

  String? get userId => _snapshot?.userId;

  String? get username => _snapshot?.username;

  String? get email => _snapshot?.email;

  /// Nome amigável (`name` na API).
  String? get displayName => _snapshot?.displayName;

  String? get tokenType => _snapshot?.tokenType;

  int? get expiresInMinutes => _snapshot?.expiresInMinutes;

  bool get hasUser => _snapshot != null && (_snapshot!.userId != null || _snapshot!.username != null);

  /// Texto curto para UI (nome ou usuário).
  String get displayLabel {
    final s = _snapshot;
    if (s == null) return '';
    final n = s.displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final u = s.username?.trim();
    if (u != null && u.isNotEmpty) return u;
    return s.email ?? '';
  }

  void applySnapshot(AuthUserSnapshot snapshot) {
    _snapshot = snapshot;
    _persistAsync();
  }

  /// Remove dados do usuário (memória + prefs). Chamado no logout.
  Future<void> clear() async {
    _snapshot = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(AuthPrefsKeys.userSnapshotJson);
  }

  /// Sincrono: limpa só memória (prefs via [clear]).
  void clearMemory() {
    _snapshot = null;
  }

  /// Carrega snapshot salvo (ex.: após cold start com sessão restaurada).
  Future<void> restoreFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    await _restoreFrom(p);
  }

  /// Usado quando [SharedPreferences] já está aberto (ex.: dentro de [AppAuth.initialize]).
  Future<void> restoreFromPrefsInstance(SharedPreferences prefs) async {
    await _restoreFrom(prefs);
  }

  Future<void> _restoreFrom(SharedPreferences prefs) async {
    final raw = prefs.getString(AuthPrefsKeys.userSnapshotJson);
    final s = AuthUserSnapshot.tryParseJsonString(raw);
    _snapshot = s;
  }

  Future<void> _persistAsync() async {
    final s = _snapshot;
    if (s == null) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(AuthPrefsKeys.userSnapshotJson, s.toJsonString());
  }
}
