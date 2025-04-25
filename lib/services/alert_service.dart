import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchOldAlerts(String companyId) async {
  final response = await http.get(
    Uri.parse(
        'https://busbuddy.ngrok.app/company/$companyId'), // update if needed
  );

  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(response.body);
    return json
        .where((a) => a['type'] == 'Missing Item')
        .toList()
        .cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load alerts');
  }
}
