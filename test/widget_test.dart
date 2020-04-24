import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uppo/main.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group("Welcome Screen", () {
    testWidgets('Can not start game without name', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(800, 800));

      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(Key("Button_StartGame")));

      await tester.pump();
      expect(find.byKey(Key("Button_Cancel")), findsNothing);
    });

    testWidgets('Can start game with name', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(800, 800));

      await tester.pumpWidget(MyApp());
      await tester.enterText(find.byKey(Key("TextField_Nickname")), 'abe');
      await tester.tap(find.byKey(Key("Button_StartGame")));

      await tester.pump();
      expect(find.byKey(Key("Button_Cancel")), findsOneWidget);
    });
  });
}
