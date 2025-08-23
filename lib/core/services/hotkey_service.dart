import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'window_service.dart';
import 'storage_service.dart';

class HotkeyService extends ChangeNotifier {
  WindowService? _windowService;
  StorageService? _storageService;
  bool _isInitialized = false;
  
  // Map to store registered hotkeys
  final Map<String, HotKey> _registeredHotkeys = {};
  
  HotkeyService() {
    debugPrint('Hotkey service initialized');
  }
  
  bool get isInitialized => _isInitialized;
  
  void setServices(WindowService windowService, StorageService storageService) {
    _windowService = windowService;
    _storageService = storageService;
  }
  
  Future<void> initialize(WindowService windowService, StorageService storageService) async {
    if (_isInitialized) return;
    
    setServices(windowService, storageService);
    
    try {
      // Register default hotkeys
      await _registerDefaultHotkeys();
      _isInitialized = true;
      notifyListeners();
      debugPrint('Hotkey service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing hotkeys: $e');
      // Don't set _isInitialized to true if there's an error
    }
  }
  
  Future<void> _registerDefaultHotkeys() async {
    if (_windowService == null || _storageService == null) return;
    
    final settings = _storageService!.settings;
    
    // Show/Hide overlay: Cmd+Shift+Space
    await registerHotkey(
      'showHide',
      settings.hotkeyShowHide,
      () => _windowService!.toggleVisibility(),
    );
    
    // Toggle Privacy Mode: Cmd+Shift+P  
    await registerHotkey(
      'privacyMode',
      settings.hotkeyPrivacyMode,
      () => _windowService!.togglePrivacyMode(),
    );
    
    // Toggle Click-Through: Cmd+Shift+C
    await registerHotkey(
      'clickThrough', 
      settings.hotkeyClickThrough,
      () => _windowService!.toggleClickThrough(),
    );
    
    // New Sticky: Cmd+Shift+N
    await registerHotkey(
      'newSticky',
      settings.hotkeyNewSticky,
      () => _storageService!.createSticky(),
    );
    
    // Panic Hide: Cmd+Shift+H (if enabled)
    if (settings.enablePanicHide) {
      await registerHotkey(
        'panicHide',
        settings.hotkeyPanicHide,
        () => _windowService!.panicHide(),
      );
    }
  }
  
  Future<void> registerHotkey(String id, String hotkeyString, VoidCallback callback) async {
    try {
      // Parse hotkey string (e.g., "cmd+shift+space")
      final hotkey = _parseHotkeyString(hotkeyString);
      if (hotkey == null) {
        debugPrint('Failed to parse hotkey: $hotkeyString');
        return;
      }
      
      // Unregister existing hotkey if it exists
      if (_registeredHotkeys.containsKey(id)) {
        await hotKeyManager.unregister(_registeredHotkeys[id]!);
      }
      
      // Register new hotkey
      await hotKeyManager.register(hotkey, keyDownHandler: (hotKey) {
        debugPrint('🔥 Hotkey triggered: $id ($hotkeyString)');
        callback();
      });
      
      _registeredHotkeys[id] = hotkey;
      debugPrint('✅ Registered hotkey: $id -> $hotkeyString');
    } catch (e) {
      debugPrint('❌ Error registering hotkey $id: $e');
    }
  }
  
  Future<void> unregisterHotkey(String id) async {
    try {
      if (_registeredHotkeys.containsKey(id)) {
        await hotKeyManager.unregister(_registeredHotkeys[id]!);
        _registeredHotkeys.remove(id);
        debugPrint('Unregistered hotkey: $id');
      }
    } catch (e) {
      debugPrint('Error unregistering hotkey $id: $e');
    }
  }
  
  Future<void> updateHotkey(String id, String newHotkeyString) async {
    if (_registeredHotkeys.containsKey(id)) {
      // Get the current callback by re-registering with same logic
      await unregisterHotkey(id);
      
      // Re-register with new hotkey string
      if (id == 'showHide' && _windowService != null) {
        await registerHotkey(id, newHotkeyString, () => _windowService!.toggleVisibility());
      } else if (id == 'privacyMode' && _windowService != null) {
        await registerHotkey(id, newHotkeyString, () => _windowService!.togglePrivacyMode());
      } else if (id == 'clickThrough' && _windowService != null) {
        await registerHotkey(id, newHotkeyString, () => _windowService!.toggleClickThrough());
      } else if (id == 'newSticky' && _storageService != null) {
        await registerHotkey(id, newHotkeyString, () => _storageService!.createSticky());
      } else if (id == 'panicHide' && _windowService != null) {
        await registerHotkey(id, newHotkeyString, () => _windowService!.panicHide());
      }
    }
  }
  
  Future<void> unregisterAll() async {
    try {
      for (final id in _registeredHotkeys.keys.toList()) {
        await unregisterHotkey(id);
      }
      debugPrint('Unregistered all hotkeys');
    } catch (e) {
      debugPrint('Error unregistering all hotkeys: $e');
    }
  }
  
  Future<bool> isHotkeyAvailable(String hotkeyString) async {
    // For now, assume all hotkeys are available
    // In a real implementation, you'd check if the hotkey is already registered by another app
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
  
  HotKey? _parseHotkeyString(String hotkeyString) {
    try {
      final parts = hotkeyString.toLowerCase().split('+');
      final modifiers = <HotKeyModifier>[];
      LogicalKeyboardKey? key;
      
      for (final part in parts) {
        switch (part.trim()) {
          case 'cmd':
          case 'meta':
            modifiers.add(HotKeyModifier.meta);
            break;
          case 'ctrl':
          case 'control':
            modifiers.add(HotKeyModifier.control);
            break;
          case 'alt':
          case 'option':
            modifiers.add(HotKeyModifier.alt);
            break;
          case 'shift':
            modifiers.add(HotKeyModifier.shift);
            break;
          case 'space':
            key = LogicalKeyboardKey.space;
            break;
          case 'enter':
            key = LogicalKeyboardKey.enter;
            break;
          case 'escape':
            key = LogicalKeyboardKey.escape;
            break;
          default:
            // Single character keys
            if (part.length == 1) {
              final charCode = part.codeUnitAt(0);
              if (charCode >= 97 && charCode <= 122) { // a-z
                key = LogicalKeyboardKey.findKeyByKeyId(0x00000000061 + (charCode - 97));
              }
            }
            break;
        }
      }
      
      if (key != null) {
        return HotKey(key: key, modifiers: modifiers);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error parsing hotkey string "$hotkeyString": $e');
      return null;
    }
  }
  
  // Getters
  Map<String, String> get registeredHotkeys {
    return _registeredHotkeys.map((key, hotkey) => MapEntry(key, hotkey.toString()));
  }
  
  @override
  void dispose() {
    unregisterAll();
    super.dispose();
  }
}