import 'dart:convert';

/// Dados do usuário devolvidos por `POST /api/auth/login` (DocumentaçãoAPI).
class AuthUserSnapshot {
  const AuthUserSnapshot({
    this.userId,
    this.username,
    this.email,
    this.displayName,
    this.tokenType,
    this.expiresInMinutes,
  });

  final String? userId;
  final String? username;
  final String? email;
  final String? displayName;
  final String? tokenType;
  final int? expiresInMinutes;

  /// True se há algum dado de perfil vindo da API (não só metadados do token).
  bool get hasIdentity =>
      _nonEmpty(userId) ||
      _nonEmpty(username) ||
      _nonEmpty(email) ||
      _nonEmpty(displayName);

  static bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;

  factory AuthUserSnapshot.fromLoginJson(Map<String, dynamic> m) {
    return AuthUserSnapshot(
      userId: _string(m, const ['userId', 'UserId']),
      username: _string(m, const ['username', 'Username']),
      email: _string(m, const ['email', 'Email']),
      displayName: _string(m, const ['name', 'Name', 'displayName', 'DisplayName']),
      tokenType: _string(m, const ['tokenType', 'TokenType']),
      expiresInMinutes: _int(m, const ['expiresInMinutes', 'ExpiresInMinutes']),
    );
  }

  factory AuthUserSnapshot.fromJson(Map<String, dynamic> m) =>
      AuthUserSnapshot.fromLoginJson(m);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'email': email,
        'name': displayName,
        'tokenType': tokenType,
        'expiresInMinutes': expiresInMinutes,
      };

  String toJsonString() => jsonEncode(toJson());

  static AuthUserSnapshot? tryParseJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final d = jsonDecode(raw);
      if (d is Map<String, dynamic>) {
        return AuthUserSnapshot.fromJson(d);
      }
    } catch (_) {}
    return null;
  }

  static String? _string(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static int? _int(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is int) return v;
      if (v is num) return v.round();
      if (v is String) return int.tryParse(v.trim());
    }
    return null;
  }
}
