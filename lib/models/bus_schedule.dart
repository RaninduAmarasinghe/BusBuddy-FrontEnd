class BusSchedule {
  final String busNumber;
  final String routeNumber;
  final String startPoint;
  final String endPoint;
  final String departureTime;
  final String arrivalTime;

  BusSchedule({
    required this.busNumber,
    required this.routeNumber,
    required this.startPoint,
    required this.endPoint,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      busNumber: json['busNumber']?.toString() ?? 'N/A',
      routeNumber: json['routeNumber']?.toString() ?? 'N/A',
      startPoint: json['startPoint'] ?? 'N/A',
      endPoint: json['endPoint'] ?? 'N/A',
      departureTime: json['departureTime'] ?? 'N/A',
      arrivalTime: json['arrivalTime'] ?? 'N/A',
    );
  }
}
