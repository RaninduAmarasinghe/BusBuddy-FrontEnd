import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late StompClient stompClient;

/// Initializes and connects to WebSocket.
/// If [onLocationReceived] is passed, subscribes to live location for the given bus.
void connectWebSocket({
  required String busId,
  Function(String data)? onLocationReceived,
}) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://192.168.8.100:8080/ws-location',
      onConnect: (StompFrame frame) {
        print("WebSocket connected");

        // Location updates subscription
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

        // You can add more subscriptions here if needed (e.g., admin panel receiving alerts)
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

/// Call this to manually disconnect the WebSocket
void disconnectWebSocket() {
  if (stompClient.connected) {
    stompClient.deactivate();
    print("WebSocket disconnected");
  }
}
