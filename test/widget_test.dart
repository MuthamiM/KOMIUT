import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komiut_app/main.dart';
import 'package:komiut_app/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows branding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KomiutApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('KOMIUT'), findsOneWidget);
    expect(find.text('Moving Africa Forward'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
