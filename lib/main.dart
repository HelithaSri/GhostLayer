import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/models/sticky.dart';
import 'core/models/image_pin.dart';
import 'core/models/settings.dart';
import 'core/services/window_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/hotkey_service.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(StickyAdapter());
  Hive.registerAdapter(ImagePinAdapter());
  Hive.registerAdapter(SettingsAdapter());
  
  // Open Hive boxes before creating services
  await Hive.openBox<Sticky>('stickies');
  await Hive.openBox<ImagePin>('image_pins');
  await Hive.openBox<Settings>('settings');
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Configure initial window
  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(400, 300),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  // Initialize hotkey manager
  await hotKeyManager.unregisterAll();
  
  runApp(const GhostLayerApp());
}

class GhostLayerApp extends StatelessWidget {
  const GhostLayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WindowService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => HotkeyService()),
      ],
      child: Consumer<StorageService>(
        builder: (context, storageService, _) {
          return MaterialApp(
            title: 'GhostLayer',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: storageService.settings.isDarkMode 
                  ? Brightness.dark 
                  : Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: storageService.settings.isDarkMode 
                    ? Brightness.dark 
                    : Brightness.light,
              ),
            ),
            home: const GhostLayerMainApp(),
          );
        },
      ),
    );
  }
}
