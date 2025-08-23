import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';

import '../../../lib/core/services/window_service.dart';
import '../../../lib/core/services/storage_service.dart';
import '../../../lib/core/models/settings.dart';
import '../../../lib/ui/widgets/status_hud/status_hud.dart';

void main() {
  group('StatusHUD Golden Tests', () {
    late WindowService mockWindowService;
    late StorageService mockStorageService;
    late Settings mockSettings;

    setUp(() {
      mockWindowService = WindowService();
      mockStorageService = StorageService();
      mockSettings = Settings();
    });

    testGoldens('StatusHUD renders correctly with default state', (tester) async {
      await tester.pumpWidgetBuilder(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WindowService>.value(value: mockWindowService),
            ChangeNotifierProvider<StorageService>.value(value: mockStorageService),
          ],
          child: const StatusHUD(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      await screenMatchesGolden(tester, 'status_hud_default');
    });

    testGoldens('StatusHUD renders correctly with dark theme', (tester) async {
      mockSettings.isDarkMode = true;
      
      await tester.pumpWidgetBuilder(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WindowService>.value(value: mockWindowService),
            ChangeNotifierProvider<StorageService>.value(value: mockStorageService),
          ],
          child: const StatusHUD(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
      );

      await screenMatchesGolden(tester, 'status_hud_dark');
    });

    testGoldens('StatusHUD renders correctly with all features enabled', (tester) async {
      // Mock enabled states
      mockWindowService.setAlwaysOnTop(true);
      mockWindowService.setPrivacyMode(true);
      mockWindowService.setClickThrough(true);
      mockWindowService.setBlur(true);
      mockWindowService.setWindowOpacity(0.7);
      
      await tester.pumpWidgetBuilder(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WindowService>.value(value: mockWindowService),
            ChangeNotifierProvider<StorageService>.value(value: mockStorageService),
          ],
          child: const StatusHUD(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      await screenMatchesGolden(tester, 'status_hud_all_enabled');
    });

    testGoldens('StatusHUD renders correctly with mixed states', (tester) async {
      // Mock mixed states
      mockWindowService.setAlwaysOnTop(true);
      mockWindowService.setPrivacyMode(false);
      mockWindowService.setClickThrough(true);
      mockWindowService.setBlur(false);
      mockWindowService.setWindowOpacity(0.9);
      
      await tester.pumpWidgetBuilder(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WindowService>.value(value: mockWindowService),
            ChangeNotifierProvider<StorageService>.value(value: mockStorageService),
          ],
          child: const StatusHUD(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      await screenMatchesGolden(tester, 'status_hud_mixed_states');
    });
  });
}
