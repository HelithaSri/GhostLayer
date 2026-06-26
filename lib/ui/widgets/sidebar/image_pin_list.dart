import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/models/image_pin.dart';
import '../../theme/app_theme.dart';

class ImagePinList extends StatelessWidget {
  final String searchQuery;

  const ImagePinList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, _) {
        final imagePins = searchQuery.isEmpty
            ? storageService.imagePins
            : storageService.searchImagePins(searchQuery);

        if (imagePins.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: imagePins.length,
          itemBuilder: (context, index) {
            final imagePin = imagePins[index];
            return _buildImagePinItem(context, imagePin, storageService);
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
            searchQuery.isEmpty ? Icons.image_outlined : Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No images yet'
                : 'No images found',
            style: AppTheme.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Add your first image to get started'
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

  Widget _buildImagePinItem(BuildContext context, ImagePin imagePin, StorageService storageService) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _focusOnImagePin(imagePin, storageService);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _buildThumbnail(imagePin),
              ),
            ),
            title: Text(
              imagePin.title,
              style: AppTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _getImageInfo(imagePin),
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      imagePin.isVisible ? Icons.visibility : Icons.visibility_off,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(imagePin.opacity * 100).round()}%',
                      style: AppTheme.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (imagePin.rotation != 0)
                      Icon(
                        Icons.rotate_right,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    const Spacer(),
                    Text(
                      _formatDate(imagePin.updatedAt),
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
                      imagePin.isVisible ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    title: Text(imagePin.isVisible ? 'Hide' : 'Show'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_aspect_ratio',
                  child: ListTile(
                    leading: Icon(
                      imagePin.maintainAspectRatio ? Icons.crop_free : Icons.aspect_ratio,
                      size: 16,
                    ),
                    title: Text(imagePin.maintainAspectRatio ? 'Free Resize' : 'Lock Aspect'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'reset_rotation',
                  child: const ListTile(
                    leading: Icon(Icons.refresh, size: 16),
                    title: Text('Reset Rotation'),
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
              onSelected: (value) => _handleMenuAction(context, value, imagePin, storageService),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ImagePin imagePin) {
    if (imagePin.imagePath.startsWith('http')) {
      // Network image
      return Image.network(
        imagePin.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorThumbnail();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingThumbnail();
        },
      );
    } else if (imagePin.imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        imagePin.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorThumbnail();
        },
      );
    } else {
      // File image (local path)
      return Image.network(
        imagePin.imagePath, // Assuming it's a file path for now
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorThumbnail();
        },
      );
    }
  }

  Widget _buildErrorThumbnail() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingThumbnail() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  String _getImageInfo(ImagePin imagePin) {
    final size = '${imagePin.width.round()} × ${imagePin.height.round()}';
    final source = imagePin.imagePath.startsWith('http') ? 'Web' : 'Local';
    return '$size • $source';
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

  void _handleMenuAction(BuildContext context, String action, ImagePin imagePin, StorageService storageService) {
    switch (action) {
      case 'toggle_visibility':
        imagePin.toggleVisibility();
        storageService.updateImagePin(imagePin);
        break;
      case 'toggle_aspect_ratio':
        imagePin.toggleAspectRatio();
        storageService.updateImagePin(imagePin);
        break;
      case 'reset_rotation':
        imagePin.updateRotation(0.0);
        storageService.updateImagePin(imagePin);
        break;
      case 'duplicate':
        _duplicateImagePin(imagePin, storageService);
        break;
      case 'delete':
        _showDeleteConfirmation(context, imagePin, storageService);
        break;
    }
  }

  void _duplicateImagePin(ImagePin imagePin, StorageService storageService) {
    storageService.createImagePin(
      title: '${imagePin.title} (Copy)',
      imagePath: imagePin.imagePath,
      x: imagePin.x + 20,
      y: imagePin.y + 20,
      width: imagePin.width,
      height: imagePin.height,
    );
  }

  void _showDeleteConfirmation(BuildContext context, ImagePin imagePin, StorageService storageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: Text('Are you sure you want to delete "${imagePin.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              storageService.deleteImagePin(imagePin.id);
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

  void _focusOnImagePin(ImagePin imagePin, StorageService storageService) {
    // Make image pin visible if hidden
    if (!imagePin.isVisible) {
      imagePin.toggleVisibility();
      storageService.updateImagePin(imagePin);
    }

    // TODO: Implement canvas focus/scroll to image pin
    // This would require communication with the canvas area
  }
}
