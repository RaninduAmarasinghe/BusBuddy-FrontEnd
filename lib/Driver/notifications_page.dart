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

class _NotificationsPageState extends State<NotificationsPage>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> _alerts = [];
  late final StompClient _stompClient;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _fetchOldAlerts();
  }

  @override
  bool get wantKeepAlive => true; // keep state (and scroll) alive

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'https://busbuddy.ngrok.app/ws-location',
        onConnect: (StompFrame frame) {
          final topic = '/topic/alerts/${widget.busId}';
          debugPrint("📡 Subscribing to $topic");
          _stompClient.subscribe(
            destination: topic,
            callback: (frame) {
              if (frame.body != null) {
                final alert = jsonDecode(frame.body!);
                final type =
                    (alert['type'] as String).toLowerCase().replaceAll(' ', '');
                if (type == 'missingitem') {
                  setState(() => _alerts.insert(0, alert));
                }
              }
            },
          );
        },
        onWebSocketError: (error) => debugPrint("WebSocket Error: $error"),
        onDisconnect: (_) => debugPrint("WebSocket Disconnected"),
      ),
    )..activate();
  }

  Future<void> _fetchOldAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('https://busbuddy.ngrok.app/company/${widget.companyId}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final missingAlerts = data.where((alert) {
          final type =
              (alert['type'] as String).toLowerCase().replaceAll(' ', '');
          return type == 'missingitem' && alert['busId'] == widget.busId;
        }).cast<Map<String, dynamic>>();
        setState(() => _alerts.addAll(missingAlerts));
      } else {
        debugPrint("❌ Failed to load alerts: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching alerts: $e");
    }
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _alerts.isEmpty
          ? const _EmptyState()
          : _AlertList(
              alerts: _alerts,
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.blueGrey),
          SizedBox(height: 12),
          Text(
            "No missing‑item alerts yet",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          SizedBox(height: 4),
          Text(
            "You'll see new alerts here in real time.",
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  const _AlertList({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      cacheExtent: 800, // preload offscreen items
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) => _AlertCard(alert: alerts[i]),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final message = alert['message'] as String? ?? 'No message';
    final sender = alert['senderName'] as String? ?? 'Unknown';
    final contact = alert['contactNumber'] as String? ?? '-';

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.redAccent.withOpacity(.15),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(sender,
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(width: 12),
                        const Icon(Icons.call_rounded,
                            size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(contact,
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
