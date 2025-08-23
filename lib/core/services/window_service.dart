import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class WindowService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('ghost_layer/window_control');
  
  bool _isPrivacyModeEnabled = false;
  bool _isClickThroughEnabled = false;
  bool _isAlwaysOnTop = true;
  bool _isBlurEnabled = true;
  double _windowOpacity = 0.95;
  bool _isVisible = true;
  
  // Getters
  bool get isPrivacyModeEnabled => _isPrivacyModeEnabled;
  bool get isClickThroughEnabled => _isClickThroughEnabled;
  bool get isAlwaysOnTop => _isAlwaysOnTop;
  bool get isBlurEnabled => _isBlurEnabled;
  double get windowOpacity => _windowOpacity;
  bool get isVisible => _isVisible;
  
  WindowService() {
    _initializeWindow();
  }
  
  Future<void> _initializeWindow() async {
    try {
      // Set up initial window properties
      await Window.initialize();
      await _updateBlur();
      await _updateAlwaysOnTop();
    } catch (e) {
      debugPrint('Error initializing window: $e');
    }
  }
  
  /// Toggle privacy mode - prevents window from being captured in screenshots/recordings
  Future<void> togglePrivacyMode() async {
    debugPrint('🔒 PRIVACY MODE TOGGLE CALLED - Current state: $_isPrivacyModeEnabled');
    try {
      _isPrivacyModeEnabled = !_isPrivacyModeEnabled;
      debugPrint('🔒 Calling platform method setSharingTypeNone with enabled: $_isPrivacyModeEnabled');
      await _channel.invokeMethod('setSharingTypeNone', {
        'enabled': _isPrivacyModeEnabled,
      });
      notifyListeners();
      debugPrint('🔒 Privacy mode ${_isPrivacyModeEnabled ? 'enabled' : 'disabled'} - SUCCESS');
    } catch (e) {
      debugPrint('🔒 ERROR toggling privacy mode: $e');
      // Revert state on error
      _isPrivacyModeEnabled = !_isPrivacyModeEnabled;
      notifyListeners();
    }
  }
  
  /// Set privacy mode state
  Future<void> setPrivacyMode(bool enabled) async {
    if (_isPrivacyModeEnabled == enabled) return;
    
    try {
      _isPrivacyModeEnabled = enabled;
      await _channel.invokeMethod('setSharingTypeNone', {
        'enabled': enabled,
      });
      notifyListeners();
      debugPrint('Privacy mode set to $enabled');
    } catch (e) {
      debugPrint('Error setting privacy mode: $e');
      // Revert state on error
      _isPrivacyModeEnabled = !enabled;
      notifyListeners();
    }
  }
  
  /// Toggle click-through mode - allows clicking through the window
  Future<void> toggleClickThrough() async {
    debugPrint('👆 CLICK-THROUGH TOGGLE CALLED - Current state: $_isClickThroughEnabled');
    try {
      _isClickThroughEnabled = !_isClickThroughEnabled;
      debugPrint('👆 Calling platform method setIgnoresMouseEvents with enabled: $_isClickThroughEnabled');
      await _channel.invokeMethod('setIgnoresMouseEvents', {
        'enabled': _isClickThroughEnabled,
      });
      notifyListeners();
      debugPrint('👆 Click-through mode ${_isClickThroughEnabled ? 'enabled' : 'disabled'} - SUCCESS');
    } catch (e) {
      debugPrint('👆 ERROR toggling click-through mode: $e');
      // Revert state on error
      _isClickThroughEnabled = !_isClickThroughEnabled;
      notifyListeners();
    }
  }
  
  /// Set click-through mode state
  Future<void> setClickThrough(bool enabled) async {
    if (_isClickThroughEnabled == enabled) return;
    
    try {
      _isClickThroughEnabled = enabled;
      await _channel.invokeMethod('setIgnoresMouseEvents', {
        'enabled': enabled,
      });
      notifyListeners();
      debugPrint('Click-through mode set to $enabled');
    } catch (e) {
      debugPrint('Error setting click-through mode: $e');
      // Revert state on error
      _isClickThroughEnabled = !enabled;
      notifyListeners();
    }
  }
  
  /// Toggle always on top mode
  Future<void> toggleAlwaysOnTop() async {
    debugPrint('📌 ALWAYS-ON-TOP TOGGLE CALLED - Current state: $_isAlwaysOnTop');
    try {
      _isAlwaysOnTop = !_isAlwaysOnTop;
      debugPrint('📌 Calling _updateAlwaysOnTop with enabled: $_isAlwaysOnTop');
      await _updateAlwaysOnTop();
      notifyListeners();
      debugPrint('📌 Always on top ${_isAlwaysOnTop ? 'enabled' : 'disabled'} - SUCCESS');
    } catch (e) {
      debugPrint('📌 ERROR toggling always on top: $e');
      // Revert state on error
      _isAlwaysOnTop = !_isAlwaysOnTop;
      notifyListeners();
    }
  }
  
  /// Set always on top state
  Future<void> setAlwaysOnTop(bool enabled, {int level = 1}) async {
    if (_isAlwaysOnTop == enabled) return;
    
    try {
      _isAlwaysOnTop = enabled;
      await _channel.invokeMethod('setAlwaysOnTop', {
        'enabled': enabled,
        'level': level,
      });
      notifyListeners();
      debugPrint('Always on top set to $enabled');
    } catch (e) {
      debugPrint('Error setting always on top: $e');
      // Revert state on error
      _isAlwaysOnTop = !enabled;
      notifyListeners();
    }
  }
  
  Future<void> _updateAlwaysOnTop() async {
    debugPrint('📌 _updateAlwaysOnTop calling platform method setAlwaysOnTop with enabled: $_isAlwaysOnTop, level: 1');
    await _channel.invokeMethod('setAlwaysOnTop', {
      'enabled': _isAlwaysOnTop,
      'level': 1, // floating level
    });
    debugPrint('📌 _updateAlwaysOnTop platform call completed');
  }
  
  /// Toggle blur effect
  Future<void> toggleBlur() async {
    try {
      _isBlurEnabled = !_isBlurEnabled;
      await _updateBlur();
      notifyListeners();
      debugPrint('Blur effect ${_isBlurEnabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error toggling blur: $e');
      // Revert state on error
      _isBlurEnabled = !_isBlurEnabled;
    }
  }
  
  /// Set blur state
  Future<void> setBlur(bool enabled) async {
    if (_isBlurEnabled == enabled) return;
    
    try {
      _isBlurEnabled = enabled;
      await _updateBlur();
      notifyListeners();
      debugPrint('Blur effect set to $enabled');
    } catch (e) {
      debugPrint('Error setting blur: $e');
      // Revert state on error
      _isBlurEnabled = !enabled;
    }
  }
  
  Future<void> _updateBlur() async {
    if (_isBlurEnabled) {
      await Window.setEffect(
        effect: WindowEffect.acrylic,
        color: const Color(0x44FFFFFF),
      );
    } else {
      await Window.setEffect(
        effect: WindowEffect.transparent,
        color: Colors.transparent,
      );
    }
  }
  
  /// Set window opacity
  Future<void> setWindowOpacity(double opacity) async {
    final clampedOpacity = opacity.clamp(0.1, 1.0);
    if (_windowOpacity == clampedOpacity) return;
    
    try {
      _windowOpacity = clampedOpacity;
      await _channel.invokeMethod('setWindowOpacity', {
        'opacity': clampedOpacity,
      });
      notifyListeners();
      debugPrint('Window opacity set to $clampedOpacity');
    } catch (e) {
      debugPrint('Error setting window opacity: $e');
    }
  }
  
  /// Show/hide the window
  Future<void> toggleVisibility() async {
    try {
      _isVisible = !_isVisible;
      if (_isVisible) {
        await windowManager.show();
        await windowManager.focus();
      } else {
        await windowManager.hide();
      }
      notifyListeners();
      debugPrint('Window ${_isVisible ? 'shown' : 'hidden'}');
    } catch (e) {
      debugPrint('Error toggling window visibility: $e');
      // Revert state on error
      _isVisible = !_isVisible;
    }
  }
  
  /// Set window visibility
  Future<void> setVisibility(bool visible) async {
    if (_isVisible == visible) return;
    
    try {
      _isVisible = visible;
      if (visible) {
        await windowManager.show();
        await windowManager.focus();
      } else {
        await windowManager.hide();
      }
      notifyListeners();
      debugPrint('Window visibility set to $visible');
    } catch (e) {
      debugPrint('Error setting window visibility: $e');
      // Revert state on error
      _isVisible = !visible;
    }
  }
  
  /// Panic hide - instantly hide all content and disable privacy mode
  Future<void> panicHide() async {
    try {
      await setPrivacyMode(false);
      await setVisibility(false);
      debugPrint('Panic hide activated');
    } catch (e) {
      debugPrint('Error during panic hide: $e');
    }
  }
  
  /// Get current window information
  Future<Map<String, dynamic>?> getWindowInfo() async {
    try {
      final result = await _channel.invokeMethod('getWindowInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Error getting window info: $e');
      return null;
    }
  }
  
  /// Update window position and size
  Future<void> updateWindowBounds(Offset position, Size size) async {
    try {
      await windowManager.setPosition(position);
      await windowManager.setSize(size);
      debugPrint('Window bounds updated: position=$position, size=$size');
    } catch (e) {
      debugPrint('Error updating window bounds: $e');
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
