import 'package:flutter_test/flutter_test.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App carrega tela inicial', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppAuth.I.initialize();

    await tester.pumpWidget(MyApp(initialRoute: AppAuth.I.initialRoute));
    await tester.pumpAndSettle();
    expect(find.textContaining('InOutWare'), findsWidgets);
  });
}
