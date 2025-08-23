import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../../core/models/sticky.dart';
import '../../../core/services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../resizable/resizable_widget.dart';

class DraggableSticky extends StatefulWidget {
  final Sticky sticky;
  final GlobalKey canvasKey;
  final Function(Sticky) onUpdate;
  final VoidCallback onDelete;

  const DraggableSticky({
    super.key,
    required this.sticky,
    required this.canvasKey,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableSticky> createState() => _DraggableStickyState();
}

class _DraggableStickyState extends State<DraggableSticky> {
  bool _isSelected = false;
  bool _isEditing = false;
  bool _isDragging = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.sticky.title);
    _contentController = TextEditingController(text: widget.sticky.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sticky.isMinimized) {
      return _buildMinimizedSticky();
    }

    return Positioned(
      left: widget.sticky.x,
      top: widget.sticky.y,
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
          initialSize: widget.sticky.size,
          minSize: const Size(200, 150),
          maxSize: const Size(800, 600),
          onResized: (newSize) {
            widget.sticky.updateSize(newSize);
            widget.onUpdate(widget.sticky);
          },
          child: _buildStickyContent(),
        ),
      ),
    );
  }

  Widget _buildMinimizedSticky() {
    return Positioned(
      left: widget.sticky.x,
      top: widget.sticky.y,
      child: GestureDetector(
        onTap: () {
          widget.sticky.toggleMinimized();
          widget.onUpdate(widget.sticky);
        },
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
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
        child: Container(
          width: 120,
          height: 30,
          decoration: BoxDecoration(
            color: widget.sticky.color.withOpacity(widget.sticky.opacity),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.sticky.title,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyContent() {
    return Opacity(
      opacity: widget.sticky.opacity,
      child: Container(
        width: widget.sticky.width,
        height: widget.sticky.height,
        decoration: BoxDecoration(
          color: widget.sticky.color,
          borderRadius: BorderRadius.circular(12),
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
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _isEditing ? _buildEditingContent() : _buildDisplayContent(),
            ),
            
            // Footer with controls
            if (_isSelected) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _titleController,
                    style: AppTheme.titleMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _saveChanges(),
                  )
                : Text(
                    widget.sticky.title,
                    style: AppTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  widget.sticky.toggleMinimized();
                  widget.onUpdate(widget.sticky);
                },
                child: const Icon(Icons.minimize, size: 16),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: widget.onDelete,
                child: const Icon(Icons.close, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: widget.sticky.content.startsWith('#')
          ? MarkdownBody(
              data: widget.sticky.content,
              styleSheet: MarkdownStyleSheet(
                p: AppTheme.bodyMedium,
                h1: AppTheme.titleLarge,
                h2: AppTheme.titleMedium,
                code: AppTheme.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: Colors.black.withOpacity(0.1),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Text(
                widget.sticky.content,
                style: AppTheme.bodyMedium,
              ),
            ),
    );
  }

  Widget _buildEditingContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        style: AppTheme.bodyMedium,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start typing...',
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          // Opacity slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: widget.sticky.opacity,
                onChanged: (value) {
                  widget.sticky.updateOpacity(value);
                  widget.onUpdate(widget.sticky);
                  setState(() {});
                },
                min: 0.1,
                max: 1.0,
                divisions: 18,
              ),
            ),
          ),
          
          // Edit button
          IconButton(
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            iconSize: 16,
            tooltip: _isEditing ? 'Save' : 'Edit',
          ),
          
          // Color picker
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return PopupMenuButton<Color>(
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.sticky.color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
        ),
      ),
      itemBuilder: (context) => AppTheme.stickyColors.map((color) {
        return PopupMenuItem<Color>(
          value: color,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
            ),
          ),
        );
      }).toList(),
      onSelected: (color) {
        widget.sticky.color = color;
        widget.onUpdate(widget.sticky);
        setState(() {});
      },
    );
  }

  void _updatePosition(Offset delta) {
    final renderBox = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final canvasSize = renderBox.size;
    final newX = (widget.sticky.x + delta.dx).clamp(0, canvasSize.width - widget.sticky.width);
    final newY = (widget.sticky.y + delta.dy).clamp(0, canvasSize.height - widget.sticky.height);

    // Snap to grid if enabled
    final storageService = context.read<StorageService>();
    if (storageService.settings.snapToGrid) {
      final gridSize = storageService.settings.gridSize;
      final snappedX = (newX / gridSize).round() * gridSize;
      final snappedY = (newY / gridSize).round() * gridSize;
      widget.sticky.updatePosition(Offset(snappedX.toDouble(), snappedY.toDouble()));
    } else {
      widget.sticky.updatePosition(Offset(newX.toDouble(), newY.toDouble()));
    }

    widget.onUpdate(widget.sticky);
  }

  void _saveChanges() {
    widget.sticky.updateContent(_titleController.text, _contentController.text);
    widget.onUpdate(widget.sticky);
    setState(() {
      _isEditing = false;
    });
  }
}
