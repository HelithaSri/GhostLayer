import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/models/sticky.dart';
import '../../theme/app_theme.dart';

class StickyList extends StatelessWidget {
  final String searchQuery;

  const StickyList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, _) {
        final stickies = searchQuery.isEmpty
            ? storageService.stickies
            : storageService.searchStickies(searchQuery);

        if (stickies.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stickies.length,
          itemBuilder: (context, index) {
            final sticky = stickies[index];
            return _buildStickyItem(context, sticky, storageService);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.sticky_note_2_outlined : Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No notes yet'
                : 'No notes found',
            style: AppTheme.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Create your first note to get started'
                : 'Try a different search term',
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyItem(BuildContext context, Sticky sticky, StorageService storageService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: sticky.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sticky.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: sticky.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          sticky.title,
          style: AppTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getPreviewText(sticky.content),
              style: AppTheme.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  sticky.isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(sticky.opacity * 100).round()}%',
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(sticky.updatedAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_visibility',
              child: ListTile(
                leading: Icon(
                  sticky.isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                ),
                title: Text(sticky.isVisible ? 'Hide' : 'Show'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_minimize',
              child: ListTile(
                leading: Icon(
                  sticky.isMinimized ? Icons.open_in_full : Icons.minimize,
                  size: 16,
                ),
                title: Text(sticky.isMinimized ? 'Expand' : 'Minimize'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'duplicate',
              child: const ListTile(
                leading: Icon(Icons.copy, size: 16),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const ListTile(
                leading: Icon(Icons.delete, size: 16, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, value, sticky, storageService),
        ),
        onTap: () {
          // Focus on the sticky in the canvas
          _focusOnSticky(sticky, storageService);
        },
      ),
    );
  }

  String _getPreviewText(String content) {
    // Remove markdown formatting for preview
    String preview = content
        .replaceAll(RegExp(r'#{1,6}\s+'), '') // Remove headers
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Remove bold
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Remove italic
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Remove code
        .replaceAll(RegExp(r'\n+'), ' ') // Replace newlines with spaces
        .trim();

    return preview.isEmpty ? 'Empty note' : preview;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleMenuAction(BuildContext context, String action, Sticky sticky, StorageService storageService) {
    switch (action) {
      case 'toggle_visibility':
        sticky.toggleVisibility();
        storageService.updateSticky(sticky);
        break;
      case 'toggle_minimize':
        sticky.toggleMinimized();
        storageService.updateSticky(sticky);
        break;
      case 'duplicate':
        _duplicateSticky(sticky, storageService);
        break;
      case 'delete':
        _showDeleteConfirmation(context, sticky, storageService);
        break;
    }
  }

  void _duplicateSticky(Sticky sticky, StorageService storageService) {
    storageService.createSticky(
      title: '${sticky.title} (Copy)',
      content: sticky.content,
      x: sticky.x + 20,
      y: sticky.y + 20,
      width: sticky.width,
      height: sticky.height,
      color: sticky.color,
    );
  }

  void _showDeleteConfirmation(BuildContext context, Sticky sticky, StorageService storageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${sticky.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              storageService.deleteSticky(sticky.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _focusOnSticky(Sticky sticky, StorageService storageService) {
    // Make sticky visible if hidden
    if (!sticky.isVisible) {
      sticky.toggleVisibility();
      storageService.updateSticky(sticky);
    }

    // Expand if minimized
    if (sticky.isMinimized) {
      sticky.toggleMinimized();
      storageService.updateSticky(sticky);
    }

    // TODO: Implement canvas focus/scroll to sticky
    // This would require communication with the canvas area
  }
}
