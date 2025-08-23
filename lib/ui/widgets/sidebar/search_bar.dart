import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focusNode.hasFocus
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search notes and images...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
