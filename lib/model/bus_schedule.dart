class BusSchedule {
  final String busNumber;
  final int routeNumber;
  final String startPoint;
  final String endPoint;
  final List<String> departureTimes;
  final List<String> arrivalTimes;
  final String companyName;

  BusSchedule({
    required this.busNumber,
    required this.routeNumber,
    required this.startPoint,
    required this.endPoint,
    required this.departureTimes,
    required this.arrivalTimes,
    required this.companyName,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      busNumber: json['busNumber'],
      routeNumber: json['routeNumber'],
      startPoint: json['startPoint'],
      endPoint: json['endPoint'],
      departureTimes: List<String>.from(json['departureTimes']),
      arrivalTimes: List<String>.from(json['arrivalTimes']),
      companyName: json['companyName'],
    );
  }
}
