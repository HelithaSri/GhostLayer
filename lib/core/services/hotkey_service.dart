import 'package:flutter/foundation.dart';

import 'window_service.dart';
import 'storage_service.dart';

class HotkeyService extends ChangeNotifier {
  bool _isInitialized = false;
  
  WindowService? _windowService;
  StorageService? _storageService;
  
  bool get isInitialized => _isInitialized;
  
  void setServices(WindowService windowService, StorageService storageService) {
    _windowService = windowService;
    _storageService = storageService;
  }
  
  Future<void> initialize(WindowService windowService, StorageService storageService) async {
    if (_isInitialized) return;
    
    setServices(windowService, storageService);
    
    try {
      _isInitialized = true;
      notifyListeners();
      debugPrint('Hotkey service initialized (disabled)');
    } catch (e) {
      debugPrint('Error initializing hotkey service: $e');
    }
  }
  
  // Placeholder methods for UI compatibility
  Future<void> updateHotkey(String id, String newHotkeyString) async {
    debugPrint('Hotkey update disabled: $id -> $newHotkeyString');
  }
  
  Future<void> unregisterHotkey(String id) async {
    debugPrint('Hotkey unregistration disabled: $id');
  }
  
  Future<void> unregisterAll() async {
    debugPrint('All hotkeys unregistration disabled');
  }
  
  Future<bool> isHotkeyAvailable(String hotkeyString) async {
    debugPrint('Hotkey availability check disabled: $hotkeyString');
    return true;
  }
  
  String getHotkeyString(String id) {
    final settings = _storageService?.settings;
    if (settings == null) return '';
    
    switch (id) {
      case 'showHide':
        return settings.hotkeyShowHide;
      case 'privacyMode':
        return settings.hotkeyPrivacyMode;
      case 'clickThrough':
        return settings.hotkeyClickThrough;
      case 'newSticky':
        return settings.hotkeyNewSticky;
      case 'panicHide':
        return settings.hotkeyPanicHide;
      default:
        return '';
    }
  }
  
  @override
  void dispose() {
    // No cleanup needed for disabled hotkeys
    super.dispose();
  }
}