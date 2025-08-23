import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/models/settings.dart';

void main() {
  group('Settings Model Tests', () {
    late Settings settings;

    setUp(() {
      settings = Settings();
    });

    test('should create settings with default values', () {
      expect(settings.isDarkMode, isFalse);
      expect(settings.isPrivacyModeEnabled, isFalse);
      expect(settings.isClickThroughEnabled, isFalse);
      expect(settings.isAlwaysOnTop, isTrue);
      expect(settings.isBlurEnabled, isTrue);
      expect(settings.windowOpacity, equals(0.95));
      expect(settings.showGrid, isFalse);
      expect(settings.gridSize, equals(20.0));
      expect(settings.snapToGrid, isTrue);
      expect(settings.showStatusHUD, isTrue);
      expect(settings.hotkeyShowHide, equals('cmd+shift+space'));
      expect(settings.hotkeyPrivacyMode, equals('cmd+shift+p'));
      expect(settings.hotkeyClickThrough, equals('cmd+shift+c'));
      expect(settings.hotkeyNewSticky, equals('cmd+shift+n'));
      expect(settings.hotkeyPanicHide, equals('cmd+shift+h'));
      expect(settings.enablePanicHide, isTrue);
    });

    test('should toggle dark mode', () {
      expect(settings.isDarkMode, isFalse);
      
      settings.toggleDarkMode();
      expect(settings.isDarkMode, isTrue);
      
      settings.toggleDarkMode();
      expect(settings.isDarkMode, isFalse);
    });

    test('should toggle privacy mode', () {
      expect(settings.isPrivacyModeEnabled, isFalse);
      
      settings.togglePrivacyMode();
      expect(settings.isPrivacyModeEnabled, isTrue);
      
      settings.togglePrivacyMode();
      expect(settings.isPrivacyModeEnabled, isFalse);
    });

    test('should toggle click through', () {
      expect(settings.isClickThroughEnabled, isFalse);
      
      settings.toggleClickThrough();
      expect(settings.isClickThroughEnabled, isTrue);
      
      settings.toggleClickThrough();
      expect(settings.isClickThroughEnabled, isFalse);
    });

    test('should toggle always on top', () {
      expect(settings.isAlwaysOnTop, isTrue);
      
      settings.toggleAlwaysOnTop();
      expect(settings.isAlwaysOnTop, isFalse);
      
      settings.toggleAlwaysOnTop();
      expect(settings.isAlwaysOnTop, isTrue);
    });

    test('should toggle blur', () {
      expect(settings.isBlurEnabled, isTrue);
      
      settings.toggleBlur();
      expect(settings.isBlurEnabled, isFalse);
      
      settings.toggleBlur();
      expect(settings.isBlurEnabled, isTrue);
    });

    test('should clamp window opacity', () {
      settings.updateWindowOpacity(0.05); // Below minimum
      expect(settings.windowOpacity, equals(0.1));
      
      settings.updateWindowOpacity(1.5); // Above maximum
      expect(settings.windowOpacity, equals(1.0));
      
      settings.updateWindowOpacity(0.7);
      expect(settings.windowOpacity, equals(0.7));
    });

    test('should toggle grid visibility', () {
      expect(settings.showGrid, isFalse);
      
      settings.toggleGrid();
      expect(settings.showGrid, isTrue);
      
      settings.toggleGrid();
      expect(settings.showGrid, isFalse);
    });

    test('should clamp grid size', () {
      settings.updateGridSize(5.0); // Below minimum
      expect(settings.gridSize, equals(10.0));
      
      settings.updateGridSize(100.0); // Above maximum
      expect(settings.gridSize, equals(50.0));
      
      settings.updateGridSize(25.0);
      expect(settings.gridSize, equals(25.0));
    });

    test('should toggle snap to grid', () {
      expect(settings.snapToGrid, isTrue);
      
      settings.toggleSnapToGrid();
      expect(settings.snapToGrid, isFalse);
      
      settings.toggleSnapToGrid();
      expect(settings.snapToGrid, isTrue);
    });

    test('should toggle status HUD', () {
      expect(settings.showStatusHUD, isTrue);
      
      settings.toggleStatusHUD();
      expect(settings.showStatusHUD, isFalse);
      
      settings.toggleStatusHUD();
      expect(settings.showStatusHUD, isTrue);
    });

    test('should update window position', () {
      settings.updateWindowPosition(150.0, 250.0);
      
      expect(settings.lastWindowX, equals(150.0));
      expect(settings.lastWindowY, equals(250.0));
    });

    test('should update window size', () {
      settings.updateWindowSize(800.0, 600.0);
      
      expect(settings.lastWindowWidth, equals(800.0));
      expect(settings.lastWindowHeight, equals(600.0));
    });

    test('should update hotkeys correctly', () {
      settings.updateHotkey('showHide', 'cmd+alt+space');
      expect(settings.hotkeyShowHide, equals('cmd+alt+space'));
      
      settings.updateHotkey('privacyMode', 'cmd+alt+p');
      expect(settings.hotkeyPrivacyMode, equals('cmd+alt+p'));
      
      settings.updateHotkey('clickThrough', 'cmd+alt+c');
      expect(settings.hotkeyClickThrough, equals('cmd+alt+c'));
      
      settings.updateHotkey('newSticky', 'cmd+alt+n');
      expect(settings.hotkeyNewSticky, equals('cmd+alt+n'));
      
      settings.updateHotkey('panicHide', 'cmd+alt+h');
      expect(settings.hotkeyPanicHide, equals('cmd+alt+h'));
    });

    test('should ignore invalid hotkey types', () {
      final originalShowHide = settings.hotkeyShowHide;
      settings.updateHotkey('invalidType', 'cmd+alt+x');
      
      // Should remain unchanged
      expect(settings.hotkeyShowHide, equals(originalShowHide));
    });

    test('should update lastUpdated timestamp on changes', () {
      final originalTimestamp = settings.lastUpdated;
      
      Future.delayed(const Duration(milliseconds: 1), () {
        settings.toggleDarkMode();
        expect(settings.lastUpdated.isAfter(originalTimestamp), isTrue);
      });
    });

    test('should create copy with modified values', () {
      final copy = settings.copyWith(
        isDarkMode: true,
        windowOpacity: 0.8,
        gridSize: 30.0,
      );
      
      expect(copy.isDarkMode, isTrue);
      expect(copy.windowOpacity, equals(0.8));
      expect(copy.gridSize, equals(30.0));
      
      // Unchanged values should remain the same
      expect(copy.isPrivacyModeEnabled, equals(settings.isPrivacyModeEnabled));
      expect(copy.isAlwaysOnTop, equals(settings.isAlwaysOnTop));
      expect(copy.showGrid, equals(settings.showGrid));
    });

    test('should have meaningful toString representation', () {
      final stringRepresentation = settings.toString();
      
      expect(stringRepresentation, contains('darkMode'));
      expect(stringRepresentation, contains('privacyMode'));
      expect(stringRepresentation, contains('clickThrough'));
      expect(stringRepresentation, contains('alwaysOnTop'));
    });
  });
}
