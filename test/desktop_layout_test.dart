import 'package:duanju_app/app_bottom_navigation.dart';
import 'package:duanju_app/app_theme.dart';
import 'package:duanju_app/desktop_layout.dart';
import 'package:duanju_app/detail_screen.dart';
import 'package:duanju_app/local_store.dart';
import 'package:duanju_app/main.dart';
import 'package:duanju_app/search_input.dart';
import 'package:duanju_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';
import 'interface_fixtures.dart';

void main() {
  Future<LocalStore> store() async {
    SharedPreferences.setMockInitialValues({});
    final result = LocalStore(await SharedPreferences.getInstance());
    addTearDown(result.dispose);
    return result;
  }

  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final size in [
    const Size(840, 560),
    const Size(1280, 800),
    const Size(1920, 1080),
  ]) {
    testWidgets('desktop browsing, search and navigation at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await tester.pumpWidget(
        DuanjuApp(repository: InterfaceRepository(), store: await store()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(find.byType(SearchInput), findsOneWidget);
      final cover = tester.getSize(find.byType(DramaCover).first);
      expect(cover.width, lessThanOrEqualTo(220));
      final sidebar = tester.getSize(find.byType(DesktopSidebar));
      expect(sidebar.width, size.width >= 1100 ? 208 : 88);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('最近观看'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(SearchInput),
          matching: find.byType(TextField),
        ),
      );
      expect(field.focusNode!.hasFocus, isTrue);
      await tester.enterText(find.byType(TextField), '合成查询');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('搜索结果'), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.byType(DesktopSidebar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop playback keeps tabs beside the video at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: DesktopPlaybackLayout(
              video: SizedBox(key: ValueKey('video')),
              information: Text('合成短剧 · 第 1 集'),
              episodes: Center(child: Text('合成选集')),
              description: Center(child: Text('合成简介')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const ValueKey('video'))).right,
        lessThan(tester.getRect(find.byType(TabBar)).left),
      );
      await tester.tap(find.text('简介'));
      await tester.pumpAndSettle();
      expect(find.text('合成简介'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'desktop detail exposes overview and episodes in separate columns',
    (tester) async {
      viewport(tester, const Size(840, 640));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: DetailScreen(
            drama: FixtureRepository.free,
            repository: FixtureRepository(),
            store: await store(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(DramaCover)).width, 172);
      expect(
        tester.getRect(find.byType(DramaCover)).right,
        lessThan(tester.getRect(find.text('选集 · 2 集')).left),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
