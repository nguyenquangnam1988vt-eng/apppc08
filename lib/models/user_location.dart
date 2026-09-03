import 'package:latlong2/latlong.dart';

class UserLocation {
  final String id;
  final String name;
  final LatLng position;

  UserLocation({
    required this.id,
    required this.name,
    required this.position,
  });
}