import 'package:latlong2/latlong.dart';

class GpsData {
  final LatLng position;
  final double speed;
  final bool isSos;

  GpsData({
    required this.position,
    required this.speed,
    required this.isSos,
  });

  factory GpsData.fromJson(Map<String, dynamic> json) {
    return GpsData(
      position: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
      speed: double.parse(json['vel'].toString()),
      isSos: json['sos'].toString() == "1",
    );
  }
}
