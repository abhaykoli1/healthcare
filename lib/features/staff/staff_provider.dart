import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final staffProvider = StateNotifierProvider<StaffNotifier, AsyncValue<Map?>>(
  (ref) => StaffNotifier(),
);

class StaffNotifier extends StateNotifier<AsyncValue<Map?>> {
  StaffNotifier() : super(const AsyncLoading());

  Future<void> apply(Map data) async {
    state = const AsyncLoading();
    final res = await ApiClient.post("/staff/apply", data);
    state = AsyncData(res);
  }

  Future<void> fetch(String id) async {
    state = const AsyncLoading();
    final res = await ApiClient.get("/staff/$id");
    state = AsyncData(res);
  }
}
