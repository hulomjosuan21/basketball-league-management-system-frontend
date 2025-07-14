import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/services/notification_model_serices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationFetchState {
  final List<NotificationModel>? notifications;
  final bool isLoading;
  final bool isError;
  final void Function() refetch;

  NotificationFetchState({
    required this.notifications,
    required this.isLoading,
    required this.isError,
    required this.refetch,
  });
}

final notificationsProvider = FutureProvider.family
    .autoDispose<List<NotificationModel>?, String>((ref, userId) async {
      ref.keepAlive();
      return await NotificationModelSerices().fetchNotifications(userId);
    });

NotificationFetchState watchNotifications(WidgetRef ref, String userId) {
  final asyncData = ref.watch(notificationsProvider(userId));

  return NotificationFetchState(
    notifications: asyncData.value,
    isLoading: asyncData.isLoading,
    isError: asyncData.hasError,
    refetch: () => ref.refresh(notificationsProvider(userId)),
  );
}
