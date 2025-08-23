import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/image_pin.dart';
import '../../../core/services/storage_service.dart';
import '../resizable/resizable_widget.dart';

class DraggableImagePin extends StatefulWidget {
  final ImagePin imagePin;
  final GlobalKey canvasKey;
  final Function(ImagePin) onUpdate;
  final VoidCallback onDelete;

  const DraggableImagePin({
    super.key,
    required this.imagePin,
    required this.canvasKey,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableImagePin> createState() => _DraggableImagePinState();
}

class _DraggableImagePinState extends State<DraggableImagePin> {
  bool _isSelected = false;
  bool _isDragging = false;
  bool _isEditing = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.imagePin.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.imagePin.x,
      top: widget.imagePin.y,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSelected = !_isSelected;
          });
        },
        onDoubleTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _isSelected = true;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            _updatePosition(details.delta);
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: ResizableWidget(
          initialSize: widget.imagePin.size,
          minSize: const Size(50, 50),
          maxSize: const Size(800, 600),
          maintainAspectRatio: widget.imagePin.maintainAspectRatio,
          onResized: (newSize) {
            widget.imagePin.updateSize(newSize);
            widget.onUpdate(widget.imagePin);
          },
          child: _buildImagePinContent(),
        ),
      ),
    );
  }

  Widget _buildImagePinContent() {
    return Opacity(
      opacity: widget.imagePin.opacity,
      child: Transform.rotate(
        angle: widget.imagePin.rotation,
        child: Container(
          width: widget.imagePin.width,
          height: widget.imagePin.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: _isDragging ? 16 : 8,
                offset: _isDragging ? const Offset(0, 8) : const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Column(
              children: [
                // Header (if selected or editing)
                if (_isSelected || _isEditing) _buildHeader(),
                
                // Image content
                Expanded(
                  child: _buildImageContent(),
                ),
                
                // Footer with controls (if selected)
                if (_isSelected) _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: Row(
        children: [
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _saveTitle(),
                  )
                : Text(
                    widget.imagePin.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          InkWell(
            onTap: widget.onDelete,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // Handle different image sources
    if (widget.imagePin.imagePath.startsWith('http')) {
      // Network image
      return Image.network(
        widget.imagePin.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
      );
    } else if (widget.imagePin.imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        widget.imagePin.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // File image (local path)
      return Image.network(
        widget.imagePin.imagePath, // Assuming it's a file path for now
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 32, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: Row(
        children: [
          // Opacity slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: widget.imagePin.opacity,
                onChanged: (value) {
                  widget.imagePin.updateOpacity(value);
                  widget.onUpdate(widget.imagePin);
                  setState(() {});
                },
                min: 0.1,
                max: 1.0,
                divisions: 18,
              ),
            ),
          ),

          // Edit title button
          InkWell(
            onTap: () {
              if (_isEditing) {
                _saveTitle();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Icon(
              _isEditing ? Icons.check : Icons.edit,
              size: 14,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          // Rotation button
          InkWell(
            onTap: () {
              widget.imagePin.updateRotation(widget.imagePin.rotation + 0.785398); // 45 degrees
              widget.onUpdate(widget.imagePin);
              setState(() {});
            },
            child: const Icon(
              Icons.rotate_right,
              size: 14,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          // Aspect ratio toggle
          InkWell(
            onTap: () {
              widget.imagePin.toggleAspectRatio();
              widget.onUpdate(widget.imagePin);
              setState(() {});
            },
            child: Icon(
              widget.imagePin.maintainAspectRatio
                  ? Icons.aspect_ratio
                  : Icons.crop_free,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _updatePosition(Offset delta) {
    final renderBox = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final canvasSize = renderBox.size;
    final newX = (widget.imagePin.x + delta.dx).clamp(0, canvasSize.width - widget.imagePin.width);
    final newY = (widget.imagePin.y + delta.dy).clamp(0, canvasSize.height - widget.imagePin.height);

    // Snap to grid if enabled
    final storageService = context.read<StorageService>();
    if (storageService.settings.snapToGrid) {
      final gridSize = storageService.settings.gridSize;
      final snappedX = (newX / gridSize).round() * gridSize;
      final snappedY = (newY / gridSize).round() * gridSize;
      widget.imagePin.updatePosition(Offset(snappedX.toDouble(), snappedY.toDouble()));
    } else {
      widget.imagePin.updatePosition(Offset(newX.toDouble(), newY.toDouble()));
    }

    widget.onUpdate(widget.imagePin);
  }

  void _saveTitle() {
    widget.imagePin.updateTitle(_titleController.text);
    widget.onUpdate(widget.imagePin);
    setState(() {
      _isEditing = false;
    });
  }
}
