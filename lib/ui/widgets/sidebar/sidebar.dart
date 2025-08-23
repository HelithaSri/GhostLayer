import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/window_service.dart';
import '../../theme/app_theme.dart';
import 'search_bar.dart';
import 'sticky_list.dart';
import 'image_pin_list.dart';
import 'sidebar_header.dart';
import 'settings_panel.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.frostedGlassDecoration(context, opacity: 0.95),
      child: Column(
        children: [
          // Header
          SidebarHeader(
            onSettingsPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
            showingSettings: _showSettings,
          ),

          if (_showSettings) ...[
            // Settings panel
            Expanded(
              child: SettingsPanel(
                onClose: () {
                  setState(() {
                    _showSettings = false;
                  });
                },
              ),
            ),
          ] else ...[
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.sticky_note_2, size: 18),
                    text: 'Notes',
                  ),
                  Tab(
                    icon: Icon(Icons.image, size: 18),
                    text: 'Images',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Stickies tab
                  StickyList(searchQuery: _searchQuery),
                  
                  // Image pins tab
                  ImagePinList(searchQuery: _searchQuery),
                ],
              ),
            ),

            // Add button
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildAddButton(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Consumer<StorageService>(
      builder: (context, storageService, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddMenu(context, storageService),
            icon: const Icon(Icons.add),
            label: Text(_tabController.index == 0 ? 'New Note' : 'Add Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      },
    );
  }

  void _showAddMenu(BuildContext context, StorageService storageService) {
    if (_tabController.index == 0) {
      // Create new sticky
      _createNewSticky(storageService);
    } else {
      // Show image picker menu
      _showImagePickerMenu(context, storageService);
    }
  }

  void _createNewSticky(StorageService storageService) {
    storageService.createSticky(
      title: 'New Note',
      content: '# New Note\n\nStart typing here...',
      x: 100 + (storageService.stickies.length * 20).toDouble(),
      y: 100 + (storageService.stickies.length * 20).toDouble(),
      color: AppTheme.getRandomStickyColor(),
    );
  }

  void _showImagePickerMenu(BuildContext context, StorageService storageService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: AppTheme.frostedGlassDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Library'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement image picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image picker not yet implemented'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera not yet implemented'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('From URL'),
              onTap: () {
                Navigator.pop(context);
                _showUrlDialog(context, storageService);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog(BuildContext context, StorageService storageService) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/image.png',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                storageService.createImagePin(
                  title: 'Image Pin',
                  imagePath: controller.text,
                  x: 100 + (storageService.imagePins.length * 20).toDouble(),
                  y: 100 + (storageService.imagePins.length * 20).toDouble(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
