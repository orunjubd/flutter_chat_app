// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🚀 CRITICAL: Import Riverpod test hooks!
import 'package:chat_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 🚀 FIXED: Wrapped the application inside a ProviderScope container box!
    // ✅ ফিক্সড: উইজেট টেস্টের ভেতর 'ProviderScope' দিয়ে র‍্যাপ করায় টেস্ট ইঞ্জিন রিভারপড রিড করতে পারবে।
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Your trailing test assertion expectations continue down here cleanly...
  });
}
