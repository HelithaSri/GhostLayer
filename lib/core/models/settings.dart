import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool isPrivacyModeEnabled;

  @HiveField(2)
  bool isClickThroughEnabled;

  @HiveField(3)
  bool isAlwaysOnTop;

  @HiveField(4)
  bool isBlurEnabled;

  @HiveField(5)
  double windowOpacity;

  @HiveField(6)
  bool showGrid;

  @HiveField(7)
  double gridSize;

  @HiveField(8)
  bool snapToGrid;

  @HiveField(9)
  bool showStatusHUD;

  @HiveField(10)
  double lastWindowX;

  @HiveField(11)
  double lastWindowY;

  @HiveField(12)
  double lastWindowWidth;

  @HiveField(13)
  double lastWindowHeight;

  @HiveField(14)
  bool rememberWindowPosition;

  @HiveField(15)
  String hotkeyShowHide;

  @HiveField(16)
  String hotkeyPrivacyMode;

  @HiveField(17)
  String hotkeyClickThrough;

  @HiveField(18)
  String hotkeyNewSticky;

  @HiveField(19)
  String hotkeyPanicHide;

  @HiveField(20)
  bool enablePanicHide;

  @HiveField(21)
  DateTime lastUpdated;

  Settings({
    this.isDarkMode = false,
    this.isPrivacyModeEnabled = false,
    this.isClickThroughEnabled = false,
    this.isAlwaysOnTop = true,
    this.isBlurEnabled = true,
    this.windowOpacity = 0.95,
    this.showGrid = false,
    this.gridSize = 20.0,
    this.snapToGrid = true,
    this.showStatusHUD = true,
    this.lastWindowX = 100.0,
    this.lastWindowY = 100.0,
    this.lastWindowWidth = 1200.0,
    this.lastWindowHeight = 800.0,
    this.rememberWindowPosition = true,
    this.hotkeyShowHide = 'cmd+shift+space',
    this.hotkeyPrivacyMode = 'cmd+shift+p',
    this.hotkeyClickThrough = 'cmd+shift+c',
    this.hotkeyNewSticky = 'cmd+shift+n',
    this.hotkeyPanicHide = 'cmd+shift+h',
    this.enablePanicHide = true,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  void updateWindowPosition(double x, double y) {
    lastWindowX = x;
    lastWindowY = y;
    lastUpdated = DateTime.now();
    save();
  }

  void updateWindowSize(double width, double height) {
    lastWindowWidth = width;
    lastWindowHeight = height;
    lastUpdated = DateTime.now();
    save();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    lastUpdated = DateTime.now();
    save();
  }

  void togglePrivacyMode() {
    isPrivacyModeEnabled = !isPrivacyModeEnabled;
    lastUpdated = DateTime.now();
    save();
  }

  void toggleClickThrough() {
    isClickThroughEnabled = !isClickThroughEnabled;
    lastUpdated = DateTime.now();
    save();
  }

  void toggleAlwaysOnTop() {
    isAlwaysOnTop = !isAlwaysOnTop;
    lastUpdated = DateTime.now();
    save();
  }

  void toggleBlur() {
    isBlurEnabled = !isBlurEnabled;
    lastUpdated = DateTime.now();
    save();
  }

  void updateWindowOpacity(double opacity) {
    windowOpacity = opacity.clamp(0.1, 1.0);
    lastUpdated = DateTime.now();
    save();
  }

  void toggleGrid() {
    showGrid = !showGrid;
    lastUpdated = DateTime.now();
    save();
  }

  void updateGridSize(double size) {
    gridSize = size.clamp(10.0, 50.0);
    lastUpdated = DateTime.now();
    save();
  }

  void toggleSnapToGrid() {
    snapToGrid = !snapToGrid;
    lastUpdated = DateTime.now();
    save();
  }

  void toggleStatusHUD() {
    showStatusHUD = !showStatusHUD;
    lastUpdated = DateTime.now();
    save();
  }

  void updateHotkey(String type, String hotkey) {
    switch (type) {
      case 'showHide':
        hotkeyShowHide = hotkey;
        break;
      case 'privacyMode':
        hotkeyPrivacyMode = hotkey;
        break;
      case 'clickThrough':
        hotkeyClickThrough = hotkey;
        break;
      case 'newSticky':
        hotkeyNewSticky = hotkey;
        break;
      case 'panicHide':
        hotkeyPanicHide = hotkey;
        break;
    }
    lastUpdated = DateTime.now();
    save();
  }

  Settings copyWith({
    bool? isDarkMode,
    bool? isPrivacyModeEnabled,
    bool? isClickThroughEnabled,
    bool? isAlwaysOnTop,
    bool? isBlurEnabled,
    double? windowOpacity,
    bool? showGrid,
    double? gridSize,
    bool? snapToGrid,
    bool? showStatusHUD,
    double? lastWindowX,
    double? lastWindowY,
    double? lastWindowWidth,
    double? lastWindowHeight,
    bool? rememberWindowPosition,
    String? hotkeyShowHide,
    String? hotkeyPrivacyMode,
    String? hotkeyClickThrough,
    String? hotkeyNewSticky,
    String? hotkeyPanicHide,
    bool? enablePanicHide,
    DateTime? lastUpdated,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPrivacyModeEnabled: isPrivacyModeEnabled ?? this.isPrivacyModeEnabled,
      isClickThroughEnabled: isClickThroughEnabled ?? this.isClickThroughEnabled,
      isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
      isBlurEnabled: isBlurEnabled ?? this.isBlurEnabled,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      showGrid: showGrid ?? this.showGrid,
      gridSize: gridSize ?? this.gridSize,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      showStatusHUD: showStatusHUD ?? this.showStatusHUD,
      lastWindowX: lastWindowX ?? this.lastWindowX,
      lastWindowY: lastWindowY ?? this.lastWindowY,
      lastWindowWidth: lastWindowWidth ?? this.lastWindowWidth,
      lastWindowHeight: lastWindowHeight ?? this.lastWindowHeight,
      rememberWindowPosition: rememberWindowPosition ?? this.rememberWindowPosition,
      hotkeyShowHide: hotkeyShowHide ?? this.hotkeyShowHide,
      hotkeyPrivacyMode: hotkeyPrivacyMode ?? this.hotkeyPrivacyMode,
      hotkeyClickThrough: hotkeyClickThrough ?? this.hotkeyClickThrough,
      hotkeyNewSticky: hotkeyNewSticky ?? this.hotkeyNewSticky,
      hotkeyPanicHide: hotkeyPanicHide ?? this.hotkeyPanicHide,
      enablePanicHide: enablePanicHide ?? this.enablePanicHide,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'Settings(darkMode: $isDarkMode, privacyMode: $isPrivacyModeEnabled, clickThrough: $isClickThroughEnabled, alwaysOnTop: $isAlwaysOnTop)';
  }
}
