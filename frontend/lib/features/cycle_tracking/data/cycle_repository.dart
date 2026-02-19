import '../../../shared/models/cycle_log.dart';

/// Cycle logs (Supabase will replace remote write when configured).
class CycleRepository {
  Future<void> saveLog(String userId, CycleLog log) async {
    // TODO: Supabase - save to cycles table (AppCollections.cycles)
  }
}
