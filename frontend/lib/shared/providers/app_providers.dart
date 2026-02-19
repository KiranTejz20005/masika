import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/hive_keys.dart';
import '../../core/services/hive_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/reward_point.dart';
import '../models/user_profile.dart';
import '../models/user_health_profile.dart';
import '../models/cycle_log.dart';
import '../models/order.dart';
import '../models/appointment.dart';
import '../models/app_notification.dart';
import '../models/doctor_profile.dart';
import '../../features/cycle_tracking/data/cycle_repository.dart';
import '../../features/health_onboarding/data/health_profile_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../backend/repositories/doctor_repository.dart';

final localeProvider = StateProvider<Locale?>((ref) => const Locale('en'));

// Backend Repository Providers
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) => DoctorRepository());

// Auth State Providers
final isUserLoggedInProvider = StateProvider<bool>((ref) => false);
final isDoctorLoggedInProvider = StateProvider<bool>((ref) => false);

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final cached = HiveService.getValue<Map>(HiveKeys.userProfile);
    if (cached != null) {
      state = UserProfile.fromJson(Map<String, dynamic>.from(cached));
    }
  }

  Future<void> setProfile(UserProfile profile) async {
    state = profile;
    await HiveService.setValue(HiveKeys.userProfile, profile.toJson());
  }

  /// Clear profile and persist; used on logout.
  Future<void> clearProfile() async {
    state = null;
    await HiveService.remove(HiveKeys.userProfile);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>(
  (ref) => UserProfileNotifier(),
);
final navIndexProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════════
// Doctor Portal session (separate from patient profile)
// ═══════════════════════════════════════════════════════════════

class DoctorProfileNotifier extends StateNotifier<DoctorProfile?> {
  DoctorProfileNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final cached = HiveService.getValue<Map>(HiveKeys.doctorProfile);
    if (cached != null) {
      state = DoctorProfile.fromJson(Map<String, dynamic>.from(cached));
    }
  }

  Future<void> setProfile(DoctorProfile profile) async {
    state = profile;
    await HiveService.setValue(HiveKeys.doctorProfile, profile.toJson());
  }

  Future<void> clearProfile() async {
    state = null;
    await HiveService.remove(HiveKeys.doctorProfile);
  }
}

final doctorProfileProvider =
    StateNotifierProvider<DoctorProfileNotifier, DoctorProfile?>(
  (ref) => DoctorProfileNotifier(),
);

final doctorNavIndexProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════════
// Notifications (Unread / Read, Mark all as read)
// ═══════════════════════════════════════════════════════════════

List<AppNotification> _createDummyNotifications() {
  return [
    const AppNotification(
      id: '1',
      title: 'Lab Results Ready',
      description:
          'Your hormone profile analysis is complete. Tap to view your diagnostic report.',
      timeAgo: '2m ago',
      dateGroup: 'today',
      iconId: 0,
      isRead: false,
    ),
    const AppNotification(
      id: '2',
      title: 'Message from Dr. Sarah',
      description:
          '"Hello! I\'ve reviewed your latest cycle data. Let\'s discuss this during your call."',
      timeAgo: '1h ago',
      dateGroup: 'today',
      iconId: 1,
      isRead: false,
    ),
    const AppNotification(
      id: '3',
      title: 'Appointment Confirmed',
      description:
          'Your consultation with Dr. Aris is confirmed for tomorrow at 10:30 AM.',
      timeAgo: 'Yesterday',
      dateGroup: 'yesterday',
      iconId: 2,
      isRead: false,
    ),
    const AppNotification(
      id: '4',
      title: 'Daily Wellness Tip',
      description:
          'Staying hydrated helps balance cortisol levels. Remember to drink 2L today.',
      timeAgo: 'Yesterday',
      dateGroup: 'yesterday',
      iconId: 3,
      isRead: false,
    ),
  ];
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(_createDummyNotifications());

  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final n in state)
        n.id == id ? n.copyWith(isRead: true) : n,
    ];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

class HealthProfileNotifier extends StateNotifier<UserHealthProfile?> {
  HealthProfileNotifier(this._ref) : super(null) {
    _load();
  }
  final Ref _ref;
  final HealthProfileRepository _repo = HealthProfileRepository();

  Future<void> _load() async {
    final userId = _ref.read(userProfileProvider)?.id;
    if (userId == null || userId.isEmpty) return;
    final local = await _repo.getLocal(userId);
    state = local;
  }

  /// Call when user is known (e.g. after login) to load or refresh health profile.
  Future<void> reload() async {
    await _load();
  }

  Future<void> setHealthProfile(UserHealthProfile profile) async {
    state = profile;
    await _repo.save(profile);
  }

  void clearForUserChange() {
    state = null;
  }
}

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, UserHealthProfile?>(
  (ref) => HealthProfileNotifier(ref),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(Product product) {
    final existing = state.indexWhere((item) => item.product.id == product.id);
    if (existing != -1) {
      final item = state[existing];
      state = [
        ...state.sublist(0, existing),
        CartItem(product: item.product, quantity: item.quantity + 1),
        ...state.sublist(existing + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void remove(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class RewardsNotifier extends StateNotifier<List<RewardPoint>> {
  RewardsNotifier() : super([]);

  void addPoints(RewardPoint point) {
    state = [...state, point];
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, List<RewardPoint>>(
  (ref) => RewardsNotifier(),
);

class CycleLogNotifier extends StateNotifier<List<CycleLog>> {
  CycleLogNotifier(this._ref) : super([]) {
    _load();
  }
  final Ref _ref;
  final CycleRepository _repository = CycleRepository();

  Future<void> _load() async {
    final cached = HiveService.getValue<List>(HiveKeys.cycleLogs);
    if (cached != null) {
      final logs = cached
          .map((item) => CycleLog.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      state = List<CycleLog>.from(logs);
    }
  }

  Future<void> add(CycleLog log) async {
    state = [...state, log];
    await _persist();
    final userId = _ref.read(userProfileProvider)?.id;
    if (userId != null && userId.isNotEmpty) {
      await _repository.saveLog(userId, log);
    }
    _ref.read(rewardsProvider.notifier).addPoints(
          RewardPoint(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            points: 5,
            reason: 'points_log',
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update(CycleLog log) async {
    state = [
      for (final item in state)
        if (item.id == log.id) log else item,
    ];
    await _persist();
    final userId = _ref.read(userProfileProvider)?.id;
    if (userId != null && userId.isNotEmpty) {
      await _repository.saveLog(userId, log);
    }
  }

  Future<void> _persist() async {
    final data = state.map((log) => log.toJson()).toList();
    await HiveService.setValue(HiveKeys.cycleLogs, data);
  }
}

final cycleLogsProvider =
    StateNotifierProvider<CycleLogNotifier, List<CycleLog>>(
  (ref) => CycleLogNotifier(ref),
);

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([]);

  void add(Order order) => state = [...state, order];
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>(
  (ref) => OrdersNotifier(),
);

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]);

  void add(Appointment appointment) => state = [...state, appointment];
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentNotifier, List<Appointment>>(
  (ref) => AppointmentNotifier(),
);
