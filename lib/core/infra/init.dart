import 'package:in_out_ware_app/core/infra/datasource.dart';
import 'package:sale_module/config/di/init_instances.dart';
import 'package:stock_module/config/di/init_instances.dart';
import 'package:transfer_module/config/di/init_instances.dart';

/// Inicialização do contexto de persistência (sqflite/cipher via [componentes_lr]).
/// Tabelas e migrations serão registradas quando o banco for definido.
Future<void> initContext({String? password}) async {
  await initAppDatasourceInstances();
}

/// Registra instâncias de datasources, repositories, use cases e stores do [sale_module].
void initSaleAppInstances() {
  initSaleInstances();
}

/// Registra instâncias do [stock_module].
void initStockAppInstances() {
  initStockInstances();
}

/// Registra instâncias do [transfer_module].
void initTransferAppInstances() {
  initTransferInstances();
}
