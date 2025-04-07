import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late StompClient stompClient;

void connectWebSocket({required Function(String) onLocationReceived}) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://192.168.8.101:8080/ws-location', // 👈 Replace with your IP
      onConnect: (StompFrame frame) {
        stompClient.subscribe(
          destination: '/location/live',
          callback: (frame) {
            if (frame.body != null) {
              onLocationReceived(frame.body!);
            }
          },
        );
      },
      onWebSocketError: (dynamic error) => print("WebSocket Error: $error"),
      onDisconnect: (_) => print("WebSocket Disconnected"),
    ),
  );

  stompClient.activate();
}
