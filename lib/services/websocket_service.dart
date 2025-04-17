import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late StompClient stompClient;

/// Initializes and connects to WebSocket.
/// If [onLocationReceived] is passed, subscribes to live location for the given bus.
void connectWebSocket({
  required String busId,
  Function(String data)? onLocationReceived,
  Function(String data)? onAlertReceived, // NEW: alert callback
}) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://192.168.8.101:8080/ws-location',
      onConnect: (StompFrame frame) {
        print("✅ WebSocket connected");

        // 🔁 Subscribe to bus location updates
        if (onLocationReceived != null) {
          stompClient.subscribe(
            destination: '/location/live/$busId',
            callback: (frame) {
              if (frame.body != null) {
                onLocationReceived(frame.body!);
              }
            },
          );
        }

        // 🔔 Subscribe to alert messages for this bus
        if (onAlertReceived != null) {
          stompClient.subscribe(
            destination:
                '/topic/alerts/$busId', // listens to alerts for this bus only
            callback: (frame) {
              if (frame.body != null) {
                onAlertReceived(frame.body!);
              }
            },
          );
        }
      },
      onWebSocketError: (dynamic error) => print("WebSocket error: $error"),
      onDisconnect: (frame) => print("WebSocket disconnected"),
      onStompError: (frame) => print("STOMP error: ${frame.body}"),
      onDebugMessage: (msg) => print("DEBUG: $msg"),
    ),
  );

  if (!stompClient.connected) {
    stompClient.activate();
  }
}
