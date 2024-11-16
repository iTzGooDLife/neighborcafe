import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:convert';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedinUser; // Cambia a User? para permitir valores nulos
  String? username;

  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(-33.035007, -71.596955); // Default VdM
  bool _locationServiceEnabled = false;
  final Location _location = Location();

  final Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _checkLocationPermissions();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser; // No es necesario usar await aquí
    if (user != null) {
      setState(() {
        loggedinUser = user; // Actualiza el estado
      });
      await getUsername(user.uid);
    } else {
      // Manejar caso donde el usuario no está autenticado
      print("No user is currently logged in.");
    }
  }

  // Función para obtener el nombre de usuario desde Firestore
  Future<void> getUsername(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['name']; // Almacenar el nombre de usuario
        });
      }
    } catch (e) {
      print('Error getting username: $e');
    }
  }

  // Revisa permisos de ubicación
  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationServiceEnabled = true;
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    if (!_locationServiceEnabled) return;

    try {
      LocationData currentLocation = await _location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _initialPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<String> _getApiKey() async {
    await dotenv.load();
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  Future<void> _searchNearbyCafes() async {
    final apiKey = await _getApiKey();
    final lat = _initialPosition.latitude;
    final lng = _initialPosition.longitude;
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=cafe&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _markers.clear();

        List results = data['results'];

        // Add a marker for each cafe
        for (var place in results) {
          final location = place['geometry']['location'];
          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(location['lat'], location['lng']),
            infoWindow: InfoWindow(title: place['name']),
            onTap: () {
              _showMarkerDetails(place);
            },
          );

          setState(() {
            _markers.add(marker);
          });
        }
      } else {
        print('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby cafes: $e');
    }
  }

  void _showMarkerDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take up more space
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.9, // Adjust the height as needed
          width: MediaQuery.of(context).size.width, // Full width of the screen
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(place['vicinity']),
              SizedBox(height: 8.0),
              Text('Rating: ${place['rating'] ?? 'N/A'}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _initialPosition.latitude == 0.0 && _initialPosition.longitude == 0.0
              ? const Center(
                  child: CircularProgressIndicator(), // Loading
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _getUserLocation();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                ),
          Positioned(
            bottom: 16,
            left: 70,
            right: 70,
            child: ElevatedButton(
              onPressed: _searchNearbyCafes,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Buscar cafeterías cercanas'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
