import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../widgets/logger.dart';

final log = logger(NotificationService);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelKey = 'carbo_notifications';
  static const String _channelName = 'Carbo Notifications';
  static const String _channelDescription = 'Notifications for booking updates and alerts';


  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // default icon (uses app icon)
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: _channelName,
          channelDescription: _channelDescription,
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: false,
    );

    // Request notification permissions
    await requestPermission();

    // Set up notification listeners
    _setupListeners();
  }

  static Future<bool> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  static void _setupListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Show a local notification
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: _channelKey,
        title: title,
        body: body,
        payload: payload != null ? {'data': payload} : null,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
    );
  }

  /// Show notification from Pusher event data
  static Future<void> showFromPusherEvent(Map<String, dynamic> eventData) async {
    final title = eventData['title'] as String? ?? 'New Notification';
    final body = eventData['message'] as String? ?? eventData['body'] as String? ?? '';
    final id = eventData['id'];

    await show(
      title: title,
      body: body,
      payload: eventData.toString(),
      id: id is int ? id : null,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancel a specific notification by id
  static Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Static callback methods required by awesome_notifications
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification tap - navigate to appropriate screen
    final payload = receivedAction.payload;
    if (payload != null && payload.containsKey('data')) {
      // Parse payload and navigate
      // Example: Get.toNamed(Routes.notification);
      log.i('Notification tapped with payload: ${payload['data']}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    log.i('Notification created: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    log.i('Notification displayed: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    log.i('Notification dismissed: ${receivedAction.id}');
  }
}
