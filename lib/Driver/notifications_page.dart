import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class NotificationsPage extends StatefulWidget {
  final String companyId;
  final String busId;

  const NotificationsPage({
    super.key,
    required this.companyId,
    required this.busId,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _alerts = [];
  late StompClient _stompClient;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _fetchOldAlerts();
  }

  /// WebSocket connection to /topic/alerts/{busId}
  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://192.168.8.100:8080/ws-location',
        onConnect: (StompFrame frame) {
          final topic = '/topic/alerts/${widget.busId}';
          print("📡 Subscribing to $topic");

          _stompClient.subscribe(
            destination: topic,
            callback: (frame) {
              if (frame.body != null) {
                final alert = jsonDecode(frame.body!);
                print("📥 Realtime alert received: ${alert['type']}");

                final type =
                    (alert['type']?.toLowerCase().replaceAll(' ', '') ?? '');
                if (type == 'missingitem') {
                  setState(() {
                    _alerts.insert(0, alert);
                  });
                }
              }
            },
          );
        },
        onWebSocketError: (error) => print("WebSocket Error: $error"),
        onDisconnect: (_) => print("WebSocket Disconnected"),
      ),
    );

    _stompClient.activate();
  }

  /// REST fallback to load old alerts
  Future<void> _fetchOldAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.100:8080/company/${widget.companyId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final missingAlerts = data.where((alert) {
          final type = (alert['type']?.toLowerCase().replaceAll(' ', '') ?? '');
          return type == 'missingitem' && alert['busId'] == widget.busId;
        }).cast<Map<String, dynamic>>();

        setState(() {
          _alerts.addAll(missingAlerts);
        });
      } else {
        print("❌ Failed to load alerts: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching alerts: $e");
    }
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _alerts.isEmpty
          ? const Center(
              child: Text(
                "No missing item alerts yet.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(alert['message'] ?? 'No message'),
                    subtitle: Text(
                        'From: ${alert['senderName'] ?? 'Unknown'}\nContact: ${alert['contactNumber'] ?? '-'}'),
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
