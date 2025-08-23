import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/models/sticky.dart';
import '../../../core/models/image_pin.dart';
import '../draggable/draggable_sticky.dart';
import '../draggable/draggable_image_pin.dart';

class CanvasArea extends StatefulWidget {
  final VoidCallback onToggleSidebar;

  const CanvasArea({
    super.key,
    required this.onToggleSidebar,
  });

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _canvasKey,
      width: double.infinity,
      height: double.infinity,
      child: Consumer<StorageService>(
        builder: (context, storageService, _) {
          return Stack(
            children: [
              // Background tap detector for deselecting items
              GestureDetector(
                onTap: () {
                  // Clear focus and deselect items
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),

              // Render all visible stickies
              ...storageService.visibleStickies.map((sticky) {
                return DraggableSticky(
                  key: ValueKey(sticky.id),
                  sticky: sticky,
                  canvasKey: _canvasKey,
                  onUpdate: (updatedSticky) {
                    storageService.updateSticky(updatedSticky);
                  },
                  onDelete: () {
                    storageService.deleteSticky(sticky.id);
                  },
                );
              }).toList(),

              // Render all visible image pins
              ...storageService.visibleImagePins.map((imagePin) {
                return DraggableImagePin(
                  key: ValueKey(imagePin.id),
                  imagePin: imagePin,
                  canvasKey: _canvasKey,
                  onUpdate: (updatedImagePin) {
                    storageService.updateImagePin(updatedImagePin);
                  },
                  onDelete: () {
                    storageService.deleteImagePin(imagePin.id);
                  },
                );
              }).toList(),

              // Canvas toolbar (top-left when no sidebar)
              Positioned(
                top: 16,
                left: 16,
                child: _buildCanvasToolbar(context, storageService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCanvasToolbar(BuildContext context, StorageService storageService) {
    return Container(
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: widget.onToggleSidebar,
            icon: const Icon(Icons.menu),
            tooltip: 'Toggle Sidebar',
          ),
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          IconButton(
            onPressed: () => _createNewSticky(storageService),
            icon: const Icon(Icons.note_add),
            tooltip: 'New Note (Cmd+Shift+N)',
          ),
          IconButton(
            onPressed: () => _showCanvasMenu(context, storageService),
            icon: const Icon(Icons.more_vert),
            tooltip: 'Canvas Options',
          ),
        ],
      ),
    );
  }

  void _createNewSticky(StorageService storageService) {
    // Create sticky at a position that's likely to be visible
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final canvasSize = renderBox?.size ?? const Size(800, 600);
    
    final x = (canvasSize.width * 0.3) + (storageService.stickies.length * 20).toDouble();
    final y = (canvasSize.height * 0.3) + (storageService.stickies.length * 20).toDouble();
    
    storageService.createSticky(
      x: x.clamp(50, canvasSize.width - 350),
      y: y.clamp(50, canvasSize.height - 250),
    );
  }

  void _showCanvasMenu(BuildContext context, StorageService storageService) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(16, 60, 0, 0),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'show_all',
          child: const ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Show All Items'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'hide_all',
          child: const ListTile(
            leading: Icon(Icons.visibility_off),
            title: Text('Hide All Items'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'toggle_grid',
          child: ListTile(
            leading: Icon(storageService.settings.showGrid
                ? Icons.grid_off
                : Icons.grid_on),
            title: Text(storageService.settings.showGrid
                ? 'Hide Grid'
                : 'Show Grid'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle_snap',
          child: ListTile(
            leading: Icon(storageService.settings.snapToGrid
                ? Icons.grid_3x3
                : Icons.grid_3x3_outlined),
            title: Text(storageService.settings.snapToGrid
                ? 'Disable Snap to Grid'
                : 'Enable Snap to Grid'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'show_all':
          storageService.showAllItems();
          break;
        case 'hide_all':
          storageService.hideAllItems();
          break;
        case 'toggle_grid':
          storageService.updateSetting('showGrid', !storageService.settings.showGrid);
          break;
        case 'toggle_snap':
          storageService.updateSetting('snapToGrid', !storageService.settings.snapToGrid);
          break;
      }
    });
  }
}
