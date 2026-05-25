import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'list_providers.dart';

final initProvider = FutureProvider<void>((ref) async {
  final lists = await ref.read(allListsProvider.future);
  if (lists.isEmpty) {
    await ref.read(allListsProvider.notifier).createList('Inbox', '#4772E6');
  }
});
