import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/window_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/hotkey_service.dart';
import '../../theme/app_theme.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<WindowService, StorageService, HotkeyService>(
      builder: (context, windowService, storageService, hotkeyService, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Window Settings
              _buildSection(
                context,
                'Window',
                [
                  _buildSwitchTile(
                    context,
                    'Always On Top',
                    'Keep window above other applications',
                    windowService.isAlwaysOnTop,
                    (value) => windowService.setAlwaysOnTop(value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Blur Effect',
                    'Apply background blur to window',
                    windowService.isBlurEnabled,
                    (value) => windowService.setBlur(value),
                  ),
                  _buildSliderTile(
                    context,
                    'Window Opacity',
                    windowService.windowOpacity,
                    (value) => windowService.setWindowOpacity(value),
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    format: (value) => '${(value * 100).round()}%',
                  ),
                ],
              ),

              // Privacy Settings
              _buildSection(
                context,
                'Privacy',
                [
                  _buildSwitchTile(
                    context,
                    'Privacy Mode',
                    'Prevent screenshots and screen recordings',
                    windowService.isPrivacyModeEnabled,
                    (value) => windowService.setPrivacyMode(value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Click Through',
                    'Allow clicking through the overlay',
                    windowService.isClickThroughEnabled,
                    (value) => windowService.setClickThrough(value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Enable Panic Hide',
                    'Enable emergency hide hotkey',
                    storageService.settings.enablePanicHide,
                    (value) => storageService.updateSetting('enablePanicHide', value),
                  ),
                ],
              ),

              // Canvas Settings
              _buildSection(
                context,
                'Canvas',
                [
                  _buildSwitchTile(
                    context,
                    'Show Grid',
                    'Display alignment grid on canvas',
                    storageService.settings.showGrid,
                    (value) => storageService.updateSetting('showGrid', value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Snap to Grid',
                    'Automatically align items to grid',
                    storageService.settings.snapToGrid,
                    (value) => storageService.updateSetting('snapToGrid', value),
                  ),
                  _buildSliderTile(
                    context,
                    'Grid Size',
                    storageService.settings.gridSize,
                    (value) => storageService.updateSetting('gridSize', value),
                    min: 10.0,
                    max: 50.0,
                    divisions: 8,
                    format: (value) => '${value.round()}px',
                  ),
                ],
              ),

              // Interface Settings
              _buildSection(
                context,
                'Interface',
                [
                  _buildSwitchTile(
                    context,
                    'Dark Mode',
                    'Use dark theme',
                    storageService.settings.isDarkMode,
                    (value) => storageService.updateSetting('isDarkMode', value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Show Status HUD',
                    'Display status indicators in top-right',
                    storageService.settings.showStatusHUD,
                    (value) => storageService.updateSetting('showStatusHUD', value),
                  ),
                ],
              ),

              // Hotkey Settings
              _buildSection(
                context,
                'Hotkeys',
                [
                  _buildHotkeyTile(
                    context,
                    'Show/Hide Overlay',
                    storageService.settings.hotkeyShowHide,
                    (hotkey) => _updateHotkey('showHide', hotkey, storageService, hotkeyService),
                  ),
                  _buildHotkeyTile(
                    context,
                    'Toggle Privacy Mode',
                    storageService.settings.hotkeyPrivacyMode,
                    (hotkey) => _updateHotkey('privacyMode', hotkey, storageService, hotkeyService),
                  ),
                  _buildHotkeyTile(
                    context,
                    'Toggle Click Through',
                    storageService.settings.hotkeyClickThrough,
                    (hotkey) => _updateHotkey('clickThrough', hotkey, storageService, hotkeyService),
                  ),
                  _buildHotkeyTile(
                    context,
                    'New Sticky Note',
                    storageService.settings.hotkeyNewSticky,
                    (hotkey) => _updateHotkey('newSticky', hotkey, storageService, hotkeyService),
                  ),
                  if (storageService.settings.enablePanicHide)
                    _buildHotkeyTile(
                      context,
                      'Panic Hide',
                      storageService.settings.hotkeyPanicHide,
                      (hotkey) => _updateHotkey('panicHide', hotkey, storageService, hotkeyService),
                    ),
                ],
              ),

              // Data Management
              _buildSection(
                context,
                'Data',
                [
                  _buildActionTile(
                    context,
                    'Export Data',
                    'Export all notes and settings',
                    Icons.download,
                    () => _exportData(context, storageService),
                  ),
                  _buildActionTile(
                    context,
                    'Clear All Data',
                    'Delete all notes and reset settings',
                    Icons.delete_forever,
                    () => _showClearDataDialog(context, storageService),
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              
              // App Info
              _buildAppInfo(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 16),
          child: Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    double value,
    Function(double) onChanged, {
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTheme.bodyMedium),
            Text(
              format(value),
              style: AppTheme.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
          ),
        ),
      ],
    );
  }

  Widget _buildHotkeyTile(
    BuildContext context,
    String title,
    String hotkey,
    Function(String) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTheme.bodyMedium),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          hotkey,
          style: AppTheme.bodySmall.copyWith(
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      onTap: () => _showHotkeyDialog(context, title, hotkey, onChanged),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'GhostLayer v1.0.0',
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Private overlay for macOS',
            style: AppTheme.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _updateHotkey(String type, String hotkey, StorageService storageService, HotkeyService hotkeyService) {
    storageService.settings.updateHotkey(type, hotkey);
    storageService.updateSettings(storageService.settings);
    hotkeyService.updateHotkey(type, hotkey);
  }

  void _showHotkeyDialog(BuildContext context, String title, String currentHotkey, Function(String) onChanged) {
    // TODO: Implement hotkey capture dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hotkey editing not yet implemented'),
      ),
    );
  }

  void _exportData(BuildContext context, StorageService storageService) {
    final data = storageService.exportData();
    // TODO: Implement data export (save to file)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export not yet implemented'),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, StorageService storageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your notes, images, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              storageService.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
