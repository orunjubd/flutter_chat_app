// // lib/features/chat/providers/reaction_repository_provider.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_app/features/chat/data/repositories/reaction_repository.dart';

// /// 🔗 THE ISOLATED REACTION REPOSITORY PROVIDER REGISTRY
// /// ✅ ফিক্সড: আর্কিটেকচার রুলস অনুযায়ী প্রোভাইডারটিকে রিপোজিটরি ফাইল থেকে বের করে আলাদা প্রোভাইডার ফাইলে শিফট করা হলো!
// final reactionRepositoryProvider = Provider<ReactionRepository>((ref) {
//   return ReactionRepository(FirebaseFirestore.instance);
// });
