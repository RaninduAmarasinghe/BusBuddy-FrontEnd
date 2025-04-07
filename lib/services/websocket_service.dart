import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late StompClient stompClient;

void connectWebSocket({
  required String busId,
  required Function(String data) onLocationReceived,
}) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://192.168.8.101:8080/ws-location',
      onConnect: (StompFrame frame) {
        stompClient.subscribe(
          destination: '/location/live/$busId',
          callback: (frame) {
            if (frame.body != null) {
              onLocationReceived(frame.body!);
            }
          },
        );
      },
      onWebSocketError: (dynamic error) => print("WebSocket error: $error"),
    ),
  );

  stompClient.activate();
}
