import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final Size initialSize;
  final Size minSize;
  final Size maxSize;
  final Function(Size) onResized;
  final bool maintainAspectRatio;
  final bool showHandles;

  const ResizableWidget({
    super.key,
    required this.child,
    required this.initialSize,
    this.minSize = const Size(100, 100),
    this.maxSize = const Size(800, 600),
    required this.onResized,
    this.maintainAspectRatio = false,
    this.showHandles = true,
  });

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late Size _currentSize;
  bool _isResizing = false;
  late double _aspectRatio;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize;
    _aspectRatio = widget.initialSize.width / widget.initialSize.height;
  }

  @override
  void didUpdateWidget(ResizableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSize != widget.initialSize) {
      _currentSize = widget.initialSize;
      _aspectRatio = widget.initialSize.width / widget.initialSize.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _currentSize.width,
      height: _currentSize.height,
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Resize handles (only show when handles are enabled)
          if (widget.showHandles) ..._buildResizeHandles(),
        ],
      ),
    );
  }

  List<Widget> _buildResizeHandles() {
    const handleSize = 12.0;
    const handleColor = Colors.blue;

    return [
      // Bottom-right corner handle (primary)
      Positioned(
        bottom: -handleSize / 2,
        right: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeDownRight,
          (delta) => _resizeFromBottomRight(delta),
        ),
      ),

      // Bottom-left corner handle
      Positioned(
        bottom: -handleSize / 2,
        left: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeDownLeft,
          (delta) => _resizeFromBottomLeft(delta),
        ),
      ),

      // Top-right corner handle
      Positioned(
        top: -handleSize / 2,
        right: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeUpRight,
          (delta) => _resizeFromTopRight(delta),
        ),
      ),

      // Top-left corner handle
      Positioned(
        top: -handleSize / 2,
        left: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeUpLeft,
          (delta) => _resizeFromTopLeft(delta),
        ),
      ),

      // Right edge handle
      Positioned(
        top: _currentSize.height / 2 - handleSize / 2,
        right: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeLeftRight,
          (delta) => _resizeFromRight(delta),
        ),
      ),

      // Left edge handle
      Positioned(
        top: _currentSize.height / 2 - handleSize / 2,
        left: -handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeLeftRight,
          (delta) => _resizeFromLeft(delta),
        ),
      ),

      // Bottom edge handle
      Positioned(
        bottom: -handleSize / 2,
        left: _currentSize.width / 2 - handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeUpDown,
          (delta) => _resizeFromBottom(delta),
        ),
      ),

      // Top edge handle
      Positioned(
        top: -handleSize / 2,
        left: _currentSize.width / 2 - handleSize / 2,
        child: _buildResizeHandle(
          handleSize,
          handleColor,
          SystemMouseCursors.resizeUpDown,
          (delta) => _resizeFromTop(delta),
        ),
      ),
    ];
  }

  Widget _buildResizeHandle(
    double size,
    Color color,
    SystemMouseCursor cursor,
    Function(Offset) onPanUpdate,
  ) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isResizing = true;
          });
        },
        onPanUpdate: (details) {
          onPanUpdate(details.delta);
        },
        onPanEnd: (details) {
          setState(() {
            _isResizing = false;
          });
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resizeFromBottomRight(Offset delta) {
    final newWidth = _currentSize.width + delta.dx;
    final newHeight = _currentSize.height + delta.dy;
    _updateSize(newWidth, newHeight);
  }

  void _resizeFromBottomLeft(Offset delta) {
    final newWidth = _currentSize.width - delta.dx;
    final newHeight = _currentSize.height + delta.dy;
    _updateSize(newWidth, newHeight);
  }

  void _resizeFromTopRight(Offset delta) {
    final newWidth = _currentSize.width + delta.dx;
    final newHeight = _currentSize.height - delta.dy;
    _updateSize(newWidth, newHeight);
  }

  void _resizeFromTopLeft(Offset delta) {
    final newWidth = _currentSize.width - delta.dx;
    final newHeight = _currentSize.height - delta.dy;
    _updateSize(newWidth, newHeight);
  }

  void _resizeFromRight(Offset delta) {
    final newWidth = _currentSize.width + delta.dx;
    if (widget.maintainAspectRatio) {
      final newHeight = newWidth / _aspectRatio;
      _updateSize(newWidth, newHeight);
    } else {
      _updateSize(newWidth, _currentSize.height);
    }
  }

  void _resizeFromLeft(Offset delta) {
    final newWidth = _currentSize.width - delta.dx;
    if (widget.maintainAspectRatio) {
      final newHeight = newWidth / _aspectRatio;
      _updateSize(newWidth, newHeight);
    } else {
      _updateSize(newWidth, _currentSize.height);
    }
  }

  void _resizeFromBottom(Offset delta) {
    final newHeight = _currentSize.height + delta.dy;
    if (widget.maintainAspectRatio) {
      final newWidth = newHeight * _aspectRatio;
      _updateSize(newWidth, newHeight);
    } else {
      _updateSize(_currentSize.width, newHeight);
    }
  }

  void _resizeFromTop(Offset delta) {
    final newHeight = _currentSize.height - delta.dy;
    if (widget.maintainAspectRatio) {
      final newWidth = newHeight * _aspectRatio;
      _updateSize(newWidth, newHeight);
    } else {
      _updateSize(_currentSize.width, newHeight);
    }
  }

  void _updateSize(double newWidth, double newHeight) {
    // Clamp to min/max constraints
    final clampedWidth = newWidth.clamp(widget.minSize.width, widget.maxSize.width);
    final clampedHeight = newHeight.clamp(widget.minSize.height, widget.maxSize.height);

    final newSize = Size(clampedWidth, clampedHeight);
    
    if (newSize != _currentSize) {
      setState(() {
        _currentSize = newSize;
      });
      widget.onResized(newSize);
    }
  }
}
