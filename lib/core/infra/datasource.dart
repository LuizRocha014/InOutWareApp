import 'package:flutter/foundation.dart';

/// Ponto único para registrar [IContext], [DatabaseConfig] ou serviços de dados do app.
/// Implementação completa fica para quando o schema do banco for definido.
Future<void> initAppDatasourceInstances() async {
  debugPrint('initAppDatasourceInstances: banco ainda não configurado.');
}
