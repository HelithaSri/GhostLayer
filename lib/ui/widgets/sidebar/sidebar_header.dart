import 'package:flutter/material.dart';

class SidebarHeader extends StatelessWidget {
  final VoidCallback onSettingsPressed;
  final bool showingSettings;

  const SidebarHeader({
    super.key,
    required this.onSettingsPressed,
    required this.showingSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // App icon and name
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.layers,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GhostLayer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Private Overlay',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Settings button
          IconButton(
            onPressed: onSettingsPressed,
            icon: Icon(
              showingSettings ? Icons.close : Icons.settings,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: showingSettings ? 'Close Settings' : 'Settings',
          ),
        ],
      ),
    );
  }
}
