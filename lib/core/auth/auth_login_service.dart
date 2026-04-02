import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthLoginResult {
  AuthLoginResult.ok(this.accessToken)
      : isSuccess = true,
        errorMessage = null;

  AuthLoginResult.fail(this.errorMessage)
      : isSuccess = false,
        accessToken = null;

  final bool isSuccess;
  final String? accessToken;
  final String? errorMessage;
}

/// POST {base}/api/auth/login — DocumentaçãoAPI.
class AuthLoginService {
  AuthLoginService._();

  static Future<AuthLoginResult> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/api/auth/login');
    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);
        if (map is! Map<String, dynamic>) {
          return AuthLoginResult.fail('Resposta inválida da API.');
        }
        final token = _readToken(map);
        if (token == null || token.isEmpty) {
          return AuthLoginResult.fail('Token não encontrado na resposta.');
        }
        return AuthLoginResult.ok(token);
      }

      if (response.statusCode == 401 || response.statusCode == 400) {
        String? msg;
        try {
          final m = jsonDecode(response.body);
          if (m is Map && m['error'] != null) msg = m['error'].toString();
        } catch (_) {}
        return AuthLoginResult.fail(msg ?? 'Usuário ou senha inválidos.');
      }

      return AuthLoginResult.fail('Erro HTTP ${response.statusCode}.');
    } catch (e) {
      return AuthLoginResult.fail(e.toString());
    }
  }

  static String? _readToken(Map<String, dynamic> map) {
    final keys = ['accessToken', 'AccessToken', 'token', 'Token'];
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }
}
