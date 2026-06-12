import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/shared/widgets/loading_view.dart';

void main() {
  group('LoadingView', () {
    testWidgets('displays CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('centers the indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
