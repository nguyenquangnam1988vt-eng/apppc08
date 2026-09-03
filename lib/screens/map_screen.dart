import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/firebase_service.dart';
import '../models/user_location.dart';

class MapScreen extends StatefulWidget {
  final String myUserId;
  final String myName;

  const MapScreen({
    super.key,
    required this.myUserId,
    required this.myName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<List<UserLocation>>? _usersStream;

  LatLng? _myCurrentPosition;
  List<UserLocation> _otherUsers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initTrackingAndListening();
  }

  void _initTrackingAndListening() async {
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) return;

    _positionStream = _locationService.getLocationStream().listen((Position pos) {
      final myLatLng = LatLng(pos.latitude, pos.longitude);
      
      setState(() {
        _myCurrentPosition = myLatLng;
      });

      _firebaseService.updateUserLocation(
        userId: widget.myUserId,
        userName: widget.myName,
        position: myLatLng,
      );
    });

    _usersStream = _firebaseService.getUsersStream(widget.myUserId).listen((users) {
      setState(() {
        _otherUsers = users;
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _usersStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bản đồ (${_otherUsers.length} người đang online)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _myCurrentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _myCurrentPosition!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.trackingapp.app',
                ),
                MarkerLayer(
                  markers: [
                    // Marker của mình
                    Marker(
                      point: _myCurrentPosition!,
                      width: 80,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: Colors.white,
                            child: Text(widget.myName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.my_location, color: Colors.red, size: 30),
                        ],
                      ),
                    ),
                    // Marker của người khác
                    ..._otherUsers.map(
                      (user) => Marker(
                        point: user.position,
                        width: 80,
                        height: 60,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              child: Text(user.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                            const Icon(Icons.person_pin_circle, color: Colors.blue, size: 35),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_myCurrentPosition != null) {
            _mapController.move(_myCurrentPosition!, 15.0);
          }
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}