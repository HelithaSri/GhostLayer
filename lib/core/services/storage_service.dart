import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/sticky.dart';
import '../models/image_pin.dart';
import '../models/settings.dart';

class StorageService extends ChangeNotifier {
  static const String _stickiesBoxName = 'stickies';
  static const String _imagePinsBoxName = 'image_pins';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';
  
  late Box<Sticky> _stickiesBox;
  late Box<ImagePin> _imagePinsBox;
  late Box<Settings> _settingsBox;
  
  Settings _settings = Settings();
  final Uuid _uuid = const Uuid();
  
  // Getters
  Settings get settings => _settings;
  List<Sticky> get stickies => _stickiesBox.values.toList();
  List<ImagePin> get imagePins => _imagePinsBox.values.toList();
  List<Sticky> get visibleStickies => stickies.where((s) => s.isVisible).toList();
  List<ImagePin> get visibleImagePins => imagePins.where((i) => i.isVisible).toList();
  
  StorageService() {
    _initializeStorage();
  }
  
  Future<void> _initializeStorage() async {
    try {
      // Open Hive boxes
      _stickiesBox = await Hive.openBox<Sticky>(_stickiesBoxName);
      _imagePinsBox = await Hive.openBox<ImagePin>(_imagePinsBoxName);
      _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
      
      // Load or create settings
      _settings = _settingsBox.get(_settingsKey) ?? Settings();
      if (!_settingsBox.containsKey(_settingsKey)) {
        await _settingsBox.put(_settingsKey, _settings);
      }
      
      // Create sample data if this is the first run
      if (_stickiesBox.isEmpty && _imagePinsBox.isEmpty) {
        await _createSampleData();
      }
      
      notifyListeners();
      debugPrint('Storage initialized successfully');
    } catch (e) {
      debugPrint('Error initializing storage: $e');
    }
  }
  
  Future<void> _createSampleData() async {
    // Create welcome sticky
    final welcomeSticky = Sticky(
      id: _uuid.v4(),
      title: 'Welcome to GhostLayer!',
      content: '''# Welcome to GhostLayer! 🎉

This is your private overlay for notes and markers.

## Features:
- **Privacy Mode**: Press `Cmd+Shift+P` to prevent screenshots
- **Click-Through**: Press `Cmd+Shift+C` to click through the overlay  
- **Always On Top**: Toggle with the status icons
- **Global Hotkeys**:
  - `Cmd+Shift+Space`: Show/Hide overlay
  - `Cmd+Shift+N`: New sticky note
  - `Cmd+Shift+H`: Panic hide

## Getting Started:
1. Drag me around to reposition
2. Resize using the corner handles
3. Try the privacy mode toggle in the status bar
4. Create new notes with the + button

Enjoy your private workspace! 🚀''',
      x: 100,
      y: 100,
      width: 400,
      height: 500,
      colorValue: 0xFFF3E5F5, // Purple 50
    );
    
    // Create tips sticky
    final tipsSticky = Sticky(
      id: _uuid.v4(),
      title: 'Pro Tips',
      content: '''# Pro Tips 💡

## Keyboard Shortcuts:
- `Cmd+Shift+Space`: Toggle overlay visibility
- `Cmd+Shift+P`: Toggle privacy mode
- `Cmd+Shift+C`: Toggle click-through
- `Cmd+Shift+N`: Create new sticky
- `Cmd+Shift+H`: Panic hide (emergency)

## Privacy Features:
- **Privacy Mode**: Blocks screenshots and screen recordings
- **Click-Through**: Interact with apps behind the overlay
- **Panic Hide**: Instantly hide everything

## Customization:
- Adjust opacity with the slider
- Enable/disable blur effects
- Toggle grid snapping
- Choose light or dark themes

## Organization:
- Use the sidebar to manage all notes
- Search through your content
- Pin important notes to stay visible

Happy organizing! 📝''',
      x: 550,
      y: 150,
      width: 350,
      height: 400,
      colorValue: 0xFFE8F5E8, // Green 50
    );
    
    await addSticky(welcomeSticky);
    await addSticky(tipsSticky);
    
    debugPrint('Sample data created');
  }
  
  // Sticky operations
  Future<void> addSticky(Sticky sticky) async {
    try {
      await _stickiesBox.put(sticky.id, sticky);
      notifyListeners();
      debugPrint('Sticky added: ${sticky.title}');
    } catch (e) {
      debugPrint('Error adding sticky: $e');
    }
  }
  
  Future<Sticky> createSticky({
    String? title,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    Color? color,
  }) async {
    final sticky = Sticky(
      id: _uuid.v4(),
      title: title ?? 'New Note',
      content: content ?? '# New Note\n\nStart typing here...',
      x: x ?? 100,
      y: y ?? 100,
      width: width ?? 300,
      height: height ?? 200,
      colorValue: color?.value ?? 0xFFFFF3E0, // Amber 50
    );
    
    await addSticky(sticky);
    return sticky;
  }
  
  Future<void> updateSticky(Sticky sticky) async {
    try {
      await sticky.save();
      notifyListeners();
      debugPrint('Sticky updated: ${sticky.title}');
    } catch (e) {
      debugPrint('Error updating sticky: $e');
    }
  }
  
  Future<void> deleteSticky(String stickyId) async {
    try {
      await _stickiesBox.delete(stickyId);
      notifyListeners();
      debugPrint('Sticky deleted: $stickyId');
    } catch (e) {
      debugPrint('Error deleting sticky: $e');
    }
  }
  
  Sticky? getSticky(String stickyId) {
    return _stickiesBox.get(stickyId);
  }
  
  List<Sticky> searchStickies(String query) {
    if (query.isEmpty) return stickies;
    
    final lowerQuery = query.toLowerCase();
    return stickies.where((sticky) {
      return sticky.title.toLowerCase().contains(lowerQuery) ||
             sticky.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  // ImagePin operations
  Future<void> addImagePin(ImagePin imagePin) async {
    try {
      await _imagePinsBox.put(imagePin.id, imagePin);
      notifyListeners();
      debugPrint('ImagePin added: ${imagePin.title}');
    } catch (e) {
      debugPrint('Error adding image pin: $e');
    }
  }
  
  Future<ImagePin> createImagePin({
    required String title,
    required String imagePath,
    double? x,
    double? y,
    double? width,
    double? height,
  }) async {
    final imagePin = ImagePin(
      id: _uuid.v4(),
      title: title,
      imagePath: imagePath,
      x: x ?? 100,
      y: y ?? 100,
      width: width ?? 200,
      height: height ?? 200,
    );
    
    await addImagePin(imagePin);
    return imagePin;
  }
  
  Future<void> updateImagePin(ImagePin imagePin) async {
    try {
      await imagePin.save();
      notifyListeners();
      debugPrint('ImagePin updated: ${imagePin.title}');
    } catch (e) {
      debugPrint('Error updating image pin: $e');
    }
  }
  
  Future<void> deleteImagePin(String imagePinId) async {
    try {
      await _imagePinsBox.delete(imagePinId);
      notifyListeners();
      debugPrint('ImagePin deleted: $imagePinId');
    } catch (e) {
      debugPrint('Error deleting image pin: $e');
    }
  }
  
  ImagePin? getImagePin(String imagePinId) {
    return _imagePinsBox.get(imagePinId);
  }
  
  List<ImagePin> searchImagePins(String query) {
    if (query.isEmpty) return imagePins;
    
    final lowerQuery = query.toLowerCase();
    return imagePins.where((imagePin) {
      return imagePin.title.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  // Settings operations
  Future<void> updateSettings(Settings newSettings) async {
    try {
      _settings = newSettings;
      await _settingsBox.put(_settingsKey, _settings);
      notifyListeners();
      debugPrint('Settings updated');
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }
  
  Future<void> updateSetting<T>(String key, T value) async {
    try {
      switch (key) {
        case 'isDarkMode':
          if (value is bool) _settings.isDarkMode = value;
          break;
        case 'isPrivacyModeEnabled':
          if (value is bool) _settings.isPrivacyModeEnabled = value;
          break;
        case 'isClickThroughEnabled':
          if (value is bool) _settings.isClickThroughEnabled = value;
          break;
        case 'isAlwaysOnTop':
          if (value is bool) _settings.isAlwaysOnTop = value;
          break;
        case 'isBlurEnabled':
          if (value is bool) _settings.isBlurEnabled = value;
          break;
        case 'windowOpacity':
          if (value is double) _settings.windowOpacity = value;
          break;
        case 'showGrid':
          if (value is bool) _settings.showGrid = value;
          break;
        case 'gridSize':
          if (value is double) _settings.gridSize = value;
          break;
        case 'snapToGrid':
          if (value is bool) _settings.snapToGrid = value;
          break;
        case 'showStatusHUD':
          if (value is bool) _settings.showStatusHUD = value;
          break;
      }
      
      _settings.lastUpdated = DateTime.now();
      await _settingsBox.put(_settingsKey, _settings);
      notifyListeners();
      debugPrint('Setting updated: $key = $value');
    } catch (e) {
      debugPrint('Error updating setting $key: $e');
    }
  }
  
  // Bulk operations
  Future<void> hideAllItems() async {
    try {
      for (final sticky in stickies) {
        if (sticky.isVisible) {
          sticky.isVisible = false;
          await sticky.save();
        }
      }
      
      for (final imagePin in imagePins) {
        if (imagePin.isVisible) {
          imagePin.isVisible = false;
          await imagePin.save();
        }
      }
      
      notifyListeners();
      debugPrint('All items hidden');
    } catch (e) {
      debugPrint('Error hiding all items: $e');
    }
  }
  
  Future<void> showAllItems() async {
    try {
      for (final sticky in stickies) {
        if (!sticky.isVisible) {
          sticky.isVisible = true;
          await sticky.save();
        }
      }
      
      for (final imagePin in imagePins) {
        if (!imagePin.isVisible) {
          imagePin.isVisible = true;
          await imagePin.save();
        }
      }
      
      notifyListeners();
      debugPrint('All items shown');
    } catch (e) {
      debugPrint('Error showing all items: $e');
    }
  }
  
  Future<void> clearAllData() async {
    try {
      await _stickiesBox.clear();
      await _imagePinsBox.clear();
      notifyListeners();
      debugPrint('All data cleared');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }
  
  // Export/Import operations
  Map<String, dynamic> exportData() {
    return {
      'stickies': stickies.map((s) => {
        'id': s.id,
        'title': s.title,
        'content': s.content,
        'x': s.x,
        'y': s.y,
        'width': s.width,
        'height': s.height,
        'opacity': s.opacity,
        'colorValue': s.colorValue,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'isVisible': s.isVisible,
        'isMinimized': s.isMinimized,
      }).toList(),
      'imagePins': imagePins.map((i) => {
        'id': i.id,
        'title': i.title,
        'imagePath': i.imagePath,
        'x': i.x,
        'y': i.y,
        'width': i.width,
        'height': i.height,
        'opacity': i.opacity,
        'createdAt': i.createdAt.toIso8601String(),
        'updatedAt': i.updatedAt.toIso8601String(),
        'isVisible': i.isVisible,
        'maintainAspectRatio': i.maintainAspectRatio,
        'rotation': i.rotation,
      }).toList(),
      'settings': {
        'isDarkMode': _settings.isDarkMode,
        'isPrivacyModeEnabled': _settings.isPrivacyModeEnabled,
        'isClickThroughEnabled': _settings.isClickThroughEnabled,
        'isAlwaysOnTop': _settings.isAlwaysOnTop,
        'isBlurEnabled': _settings.isBlurEnabled,
        'windowOpacity': _settings.windowOpacity,
        'showGrid': _settings.showGrid,
        'gridSize': _settings.gridSize,
        'snapToGrid': _settings.snapToGrid,
        'showStatusHUD': _settings.showStatusHUD,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
  
  @override
  void dispose() {
    _stickiesBox.close();
    _imagePinsBox.close();
    _settingsBox.close();
    super.dispose();
  }
}
