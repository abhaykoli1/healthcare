import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final punchProvider = Provider((ref) => PunchService());

class PunchService {
  Future<void> inDuty(String staffId) async {
    await ApiClient.post("/staff/$staffId/punch-in?duty_type=DAY", {});
  }

  Future<void> outDuty(String staffId) async {
    await ApiClient.post("/staff/$staffId/punch-out", {});
  }
}
