import 'package:componentes_lr/componentes_lr.dart';

/// Contexto SQLCipher/sqflite do app, espelhando a ideia de `HostContext` do template.
/// Quando o banco existir, use [Context.nonFactoryConstructor] e registre em [instanceManager]
/// como [IContext] (via `package:componentes_lr/.../utils_exports.dart`).
class HostContextPlaceholder {
  static const nameDatabase = 'in_out_ware_main';
  static const version = 1;
  static final List<InfosTableDatabase> tables = [];
}
