import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/window_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/hotkey_service.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

class GhostLayerMainApp extends StatefulWidget {
  const GhostLayerMainApp({super.key});

  @override
  State<GhostLayerMainApp> createState() => _GhostLayerMainAppState();
}

class _GhostLayerMainAppState extends State<GhostLayerMainApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final windowService = context.read<WindowService>();
    final storageService = context.read<StorageService>();
    final hotkeyService = context.read<HotkeyService>();

    // Wait for storage to initialize first
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Initialize hotkeys with services
    await hotkeyService.initialize(windowService, storageService);
    
    // Apply saved settings to window service
    final settings = storageService.settings;
    await windowService.setPrivacyMode(settings.isPrivacyModeEnabled);
    await windowService.setClickThrough(settings.isClickThroughEnabled);
    await windowService.setAlwaysOnTop(settings.isAlwaysOnTop);
    await windowService.setBlur(settings.isBlurEnabled);
    await windowService.setWindowOpacity(settings.windowOpacity);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, _) {
        return MaterialApp(
          title: 'GhostLayer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: storageService.settings.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
          home: const MainScreen(),
        );
      },
    );
  }
}
