//import 'package:flutter/foundation.dart';
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

  Future<void> scrollToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 450),
  }) async {
    if (!itemScrollController.isAttached) {
      return;
    }
    await itemScrollController.scrollTo(
      index: index,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: .25,
    );
  }
}
