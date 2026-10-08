import 'dart:async';
import 'package:flutter/material.dart';

class ConversationSearchField extends StatefulWidget {
  const ConversationSearchField({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  State<ConversationSearchField> createState() => _State();
}

class _State extends State<ConversationSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onText(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => widget.onChanged(v),
    );
    setState(() {}); // refresh the clear button
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        onChanged: _onText,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }
}
