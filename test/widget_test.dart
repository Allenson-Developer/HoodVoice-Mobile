
import 'package:flutter_test/flutter_test.dart';
import 'package:hoodvoice_mobile/app.dart';

void main() {
  testWidgets('HoodVoice Cartagena muestra su portada', (tester) async {
    await tester.pumpWidget(const HoodVoiceApp());
    expect(find.text('HOODVOICE'), findsOneWidget);
    expect(find.text('CREAR CUENTA'), findsOneWidget);
    expect(find.text('YA TENGO UNA CUENTA'), findsOneWidget);
  });
}
