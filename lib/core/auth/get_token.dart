import 'package:in_out_ware_app/core/auth/app_auth.dart';

/// Token JWT atual (memória sincronizada com [SharedPreferences] após login).
String? getToken() => AppAuth.I.accessToken;
