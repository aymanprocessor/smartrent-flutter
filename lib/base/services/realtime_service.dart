import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../api/endpoint/api_endpoint.dart';
import '../utils/local_storage.dart';
import '../widgets/logger.dart';
import 'notification_service.dart';

final log = logger(RealtimeService);

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  PusherChannelsFlutter? _pusher;
  
  bool _isConnected = false;
  int? _currentUserId;

  // Pusher configuration - UPDATE THESE VALUES
  static const String _pusherKey = 'e2aaf506-f2b9-43fe-81b6-0d26c5fe5596'; // Replace with your Pusher key
  static const String _pusherCluster = 'ap2'; // Replace with your cluster (e.g., 'eu', 'ap1', 'us2')
  
  // Laravel broadcasting auth endpoint
  static String get _authEndpoint => '${ApiConfig.mainDomain}/broadcasting/auth';

  bool get isConnected => _isConnected;

  /// Initialize and connect to Pusher
  Future<void> init() async {
    if (_pusher != null)
    {
      log.i('[RealtimeService] Pusher already initialized.');
      return;
    }

    try {
      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onSubscriptionError: _onSubscriptionError,
        onEvent: _onEvent,
        onAuthorizer: _onAuthorizer,
      );

      await _pusher!.connect();
      log.i('[RealtimeService] Pusher initialized and connecting...');
    } catch (e) {
      log.e('[RealtimeService] Init error: $e');
    }
  }

  /// Subscribe to user's private notification channel
  Future<void> subscribeToUserChannel(int userId) async {
    if (_pusher == null) {
      log.w('[RealtimeService] Pusher not initialized. Call init() first.');
      return;
    }

    // Unsubscribe from previous channel if different user
    if (_currentUserId != null && _currentUserId != userId) {
      await unsubscribeFromUserChannel();
    }

    _currentUserId = userId;
    final channelName = 'user-notification-$userId';

    try {
      await _pusher!.subscribe(channelName: channelName);
      log.i('[RealtimeService] Subscribed to channel: $channelName');
    } catch (e) {
      log.e('[RealtimeService] Subscribe error: $e');
    }
  }

  /// Unsubscribe from current user channel
  Future<void> unsubscribeFromUserChannel() async {
    if (_currentUserId == null || _pusher == null) return;

    final channelName = 'user-notification-$_currentUserId';
    try {
      await _pusher!.unsubscribe(channelName: channelName);
      _currentUserId = null;
      log.i('[RealtimeService] Unsubscribed from channel: $channelName');
    } catch (e) {
      log.e('[RealtimeService] Unsubscribe error: $e');
    }
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    if (_pusher == null) return;

    try {
      await unsubscribeFromUserChannel();
      await _pusher!.disconnect();
      _isConnected = false;
      log.i('[RealtimeService] Disconnected from Pusher');
    } catch (e) {
      log.e('[RealtimeService] Disconnect error: $e');
    }
  }

  /// Authorizer for private channels - sends Bearer token to Laravel
  Future<Map<String, String>?> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    final token = LocalStorage.token;
    if (token.isEmpty) {
      log.w('[RealtimeService] No auth token available for channel auth');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(_authEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'auth': json['auth'] as String,
          if (json['channel_data'] != null) 'channel_data': json['channel_data'] as String,
        };
      } else {
        log.e('[RealtimeService] Auth failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log.e('[RealtimeService] Auth error: $e');
    }
    return null;
  }

  void _onConnectionStateChange(String currentState, String previousState) {
    log.i('[RealtimeService] Connection: $previousState -> $currentState');
    _isConnected = currentState == 'CONNECTED';
  }

  void _onError(String message, int? code, dynamic e) {
    log.e('[RealtimeService] Error: $message (code: $code)');
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    log.i('[RealtimeService] Subscription succeeded: $channelName');
  }

  void _onSubscriptionError(String message, dynamic e) {
    debugPrint('[RealtimeService] Subscription error: $message');
  }

  /// Handle incoming Pusher events
  void _onEvent(PusherEvent event) {
    log.i('[RealtimeService] Event received: ${event.eventName} on ${event.channelName}');
    log.i('[RealtimeService] Event data: ${event.data}');

    // Handle the specific event from Laravel
    if (event.eventName == 'user-dashboard-notification-push') {
      _handleDashboardNotification(event);
    }
  }

  /// Process dashboard notification event and show local notification
  void _handleDashboardNotification(PusherEvent event) {
    try {
      if (event.data == null) return;

      Map<String, dynamic> eventData;
      if (event.data is String) {
        eventData = jsonDecode(event.data!) as Map<String, dynamic>;
      } else {
        eventData = event.data as Map<String, dynamic>;
      }

      // Show local notification using awesome_notifications
      NotificationService.showFromPusherEvent(eventData);
    } catch (e) {
      log.e('[RealtimeService] Error handling notification: $e');
    }
  }
}
