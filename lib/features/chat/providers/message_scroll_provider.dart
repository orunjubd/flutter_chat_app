import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

final messageScrollControllerProvider = Provider<MessageScrollController>((
  ref,
) {
  return MessageScrollController();
});

class MessageScrollController {
  final itemScrollController = ItemScrollController();

  final itemPositionsListener = ItemPositionsListener.create();

  int _lastMessageCount = 0;

  bool _autoScrollEnabled = true;

  bool get autoScrollEnabled => _autoScrollEnabled;

  void enableAutoScroll() {
    _autoScrollEnabled = true;
  }

  void disableAutoScroll() {
    _autoScrollEnabled = false;
  }

  Future<void> scrollToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 450),
  }) async {
    if (!itemScrollController.isAttached) return;

    await itemScrollController.scrollTo(
      index: index,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: .25,
    );
  }

  Future<void> onMessageCountChanged(int count) async {
    if (count <= 0) {
      _lastMessageCount = 0;
      return;
    }

    if (!_autoScrollEnabled) {
      _lastMessageCount = count;
      return;
    }

    if (count == _lastMessageCount) return;

    _lastMessageCount = count;

    if (!itemScrollController.isAttached) return;

    await itemScrollController.scrollTo(
      index: count - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: .15,
    );
  }
}
