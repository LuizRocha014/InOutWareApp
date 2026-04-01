import 'package:flutter_test/flutter_test.dart';
import 'package:in_out_ware_app/main.dart';

void main() {
  testWidgets('App carrega tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('InOutWare'), findsWidgets);
  });
}
