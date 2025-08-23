import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/window_service.dart';
import '../../core/services/storage_service.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/canvas/canvas_area.dart';
import '../widgets/status_hud/status_hud.dart';
import '../widgets/grid/grid_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSidebarVisible = true;
  double _sidebarWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<WindowService, StorageService>(
        builder: (context, windowService, storageService, _) {
          return Stack(
            children: [
              // Grid overlay (if enabled)
              if (storageService.settings.showGrid)
                GridOverlay(
                  gridSize: storageService.settings.gridSize,
                ),
              
              // Main content area
              Row(
                children: [
                  // Sidebar
                  if (_isSidebarVisible)
                    SizedBox(
                      width: _sidebarWidth,
                      child: const Sidebar(),
                    ),
                  
                  // Resize handle for sidebar
                  if (_isSidebarVisible)
                    MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _sidebarWidth = (_sidebarWidth + details.delta.dx)
                                .clamp(200.0, 400.0);
                          });
                        },
                        child: Container(
                          width: 4,
                          color: Colors.transparent,
                          child: Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  
                  // Canvas area
                  Expanded(
                    child: CanvasArea(
                      onToggleSidebar: () {
                        setState(() {
                          _isSidebarVisible = !_isSidebarVisible;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              // Status HUD (top-right)
              if (storageService.settings.showStatusHUD)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: StatusHUD(),
                ),
              
              // Sidebar toggle button (when sidebar is hidden)
              if (!_isSidebarVisible)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildSidebarToggle(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarToggle() {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            setState(() {
              _isSidebarVisible = true;
            });
          },
          icon: const Icon(Icons.menu),
          tooltip: 'Show Sidebar',
        ),
      ),
    );
  }
}
