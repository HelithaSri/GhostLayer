import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/window_service.dart';
import '../../../core/services/storage_service.dart';
import '../../theme/app_theme.dart';

class StatusHUD extends StatelessWidget {
  const StatusHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WindowService, StorageService>(
      builder: (context, windowService, storageService, _) {
        return Container(
          decoration: AppTheme.glassDecoration(context, opacity: 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIndicator(
                context,
                icon: Icons.push_pin,
                isActive: windowService.isAlwaysOnTop,
                tooltip: 'Always On Top',
                onTap: () => windowService.toggleAlwaysOnTop(),
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                context,
                icon: Icons.security,
                isActive: windowService.isPrivacyModeEnabled,
                tooltip: 'Privacy Mode (Cmd+Shift+P)',
                onTap: () => windowService.togglePrivacyMode(),
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                context,
                icon: Icons.touch_app_outlined,
                isActive: windowService.isClickThroughEnabled,
                tooltip: 'Click Through (Cmd+Shift+C)',
                onTap: () => windowService.toggleClickThrough(),
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                context,
                icon: Icons.blur_on,
                isActive: windowService.isBlurEnabled,
                tooltip: 'Blur Effect',
                onTap: () => windowService.toggleBlur(),
              ),
              const SizedBox(width: 12),
              _buildOpacitySlider(context, windowService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildOpacitySlider(BuildContext context, WindowService windowService) {
    return Container(
      width: 80,
      child: Tooltip(
        message: 'Window Opacity: ${(windowService.windowOpacity * 100).round()}%',
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: windowService.windowOpacity,
            onChanged: (value) {
              windowService.setWindowOpacity(value);
            },
            min: 0.1,
            max: 1.0,
            divisions: 18,
          ),
        ),
      ),
    );
  }
}
