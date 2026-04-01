# InOutWareApp

Aplicativo Flutter de entrada (**WMS / logística**) que agrega módulos de negócio em um único host. A base de componentes e utilitários vem do pacote **`componentes_lr`** ([Flutter_X_Components_Flutter](../../Flutter_X_Components_Flutter)), em substituição ao `core_module` dos templates internos.

## Requisitos

- Flutter compatível com o `sdk` declarado em [`pubspec.yaml`](pubspec.yaml) (atualmente `^3.5.3`).
- O repositório **`Flutter_X_Components_Flutter`** deve existir **no mesmo nível** desta pasta `InOutWareApp` no disco, pois a dependência `componentes_lr` usa path relativo.

## Estrutura principal

| Pasta / arquivo | Função |
|-----------------|--------|
| `lib/main.dart` | `WidgetsFlutterBinding`, `initAppInfos`, inicialização de contexto/DI dos módulos, `GetMaterialApp`. |
| `lib/core/infra/` | Hooks de persistência (`init.dart`, `datasource.dart`, etc.); banco ainda a ser modelado. |
| `lib/config/app_routes.dart` | Rotas GetX (`/`, `/home`, `/sale`, `/stock`, `/transfer`). |
| `lib/presentation/` | Home e itens de menu que navegam para os pacotes. |

## Módulos (pacotes locais)

Dependências em `pubspec.yaml`:

- `sale_module` → `../packages/sale_module`
- `stock_module` → `../packages/stock_module`
- `transfer_module` → `../packages/transfer_module`

Cada módulo expõe `init*Instances()` registrado em `lib/core/infra/init.dart` e chamado no `main`.

## Executar

Na raiz do app:

```bash
cd in_out_ware_app
flutter pub get
flutter run
```

Plataformas geradas pelo template: Android, iOS e Windows.

## Notas de dependências

- **`dependency_overrides: intl: 0.20.2`**: alinha `intl` com `flutter_localizations` do SDK; o `componentes_lr` ainda declara `intl ^0.19.0`, e o override evita conflito de resolução.

## Testes

```bash
cd in_out_ware_app
flutter test
```

## Documentação dos módulos

Cada pacote possui o próprio README em `packages/<nome_do_modulo>/README.md`.
