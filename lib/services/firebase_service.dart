import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../models/user_location.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> updateUserLocation({
    required String userId,
    required String userName,
    required LatLng position,
  }) async {
    await _dbRef.child('active_users/$userId').set({
      'name': userName,
      'lat': position.latitude,
      'lng': position.longitude,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<UserLocation>> getUsersStream(String currentUserId) {
    return _dbRef.child('active_users').onValue.map((event) {
      final List<UserLocation> usersList = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          if (key != currentUserId) {
            usersList.add(
              UserLocation(
                id: key,
                name: value['name'] ?? 'Ẩn danh',
                position: LatLng(
                  (value['lat'] as num).toDouble(),
                  (value['lng'] as num).toDouble(),
                ),
              ),
            );
          }
        });
      }
      return usersList;
    });
  }
}