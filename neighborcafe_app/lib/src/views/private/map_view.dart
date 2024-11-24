import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import '../../components/review_dialog.dart';
import 'package:logger/logger.dart';
import '../../components/reviews_stream.dart';
import '../../components/star_rating.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  StreamSubscription<LocationData>? _locationSubscription;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
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
      _logger.e("No user is currently logged in.");
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
      _logger.e('Error getting username: $e');
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
      _updateLocationAndSearch(currentLocation);

      _locationSubscription =
          _location.onLocationChanged.listen((LocationData newLocation) {
        _updateLocationAndSearch(newLocation);
      });
    } catch (e) {
      _logger.e('Error getting location: $e');
    }
  }

  void _updateLocationAndSearch(LocationData location) {
    if (location.latitude != null && location.longitude != null) {
      final newPosition = LatLng(location.latitude!, location.longitude!);

      final distance = _calculateDistance(
        _initialPosition.latitude,
        _initialPosition.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      if (distance > 10) {
        setState(() {
          _initialPosition = newPosition;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
        _searchNearbyCafes();
      }
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.14 / 180;
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
        _logger.w('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching nearby cafes: $e');
    }
  }

  Future<void> handleFavorite(Map<String, dynamic> place, String? photoUrl) async {
    final favoritesCollection = _firestore.collection('favorites');
    final querySnapshot = await favoritesCollection
        .where('user', isEqualTo: username)
        .where('place_id', isEqualTo: place["place_id"])
        .get();

    if (querySnapshot.docs.isEmpty) {
      await favoritesCollection.add({
        'place_address': place['vicinity'],
        'place_id': place["place_id"],
        'place_name': place['name'],
        'place_photoUrl': photoUrl,
        'user': username,
      });
    } else {
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  void _showMarkerDetails(Map<String, dynamic> place) async {
    final apiKey = await _getApiKey();
    String imageUrl;

    if (place['photos'] != null && place['photos'].isNotEmpty) {
      imageUrl =
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$apiKey';
    } else {
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos/random?query=coffee&client_id=YOUR_UNSPLASH_API_KEY'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        imageUrl = data['urls']['regular'];
      } else {
        imageUrl =
            'https://pqs.pe/wp-content/uploads/2016/08/pqs-como-abrir-cafeteria.jpg';
      }
    }

    final image = NetworkImage(imageUrl);
    final completer = Completer<void>();
    final imageStream = image.resolve(const ImageConfiguration());
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete();
    }, onError: (dynamic error, StackTrace? stackTrace) {
      completer.completeError(error);
    });
    imageStream.addListener(listener);

    try {
      await completer.future;
    } catch (e) {
      _logger.e('Error loading image: $e');
    } finally {
      imageStream.removeListener(listener);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.secondaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16.0), // Smooth border radius
                    child: SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(
                                16.0), // Smooth border radius for placeholder
                            child: Image.asset(
                              'assets/placeholder_image.png', // Path to your placeholder image
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        place['name'] ?? 'No name available',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('favorites')
                            .where('user', isEqualTo: username)
                            .where('place_id', isEqualTo: place['place_id'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              handleFavorite(place, imageUrl);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(place['vicinity'] ?? 'No address available'),
                ),
                const SizedBox(height: 8.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('place_id', isEqualTo: place['place_id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarRating(rating: 0),
                            const SizedBox(width: 4.0),
                            const Text(
                              ' (No ha sido calificado)',
                            ),
                          ],
                        ),
                      );
                    }
                    final reviews = snapshot.data!.docs;
                    double averageRating = reviews
                            .map((review) => review['rating'])
                            .reduce((a, b) => a + b) /
                        reviews.length;
                    return Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StarRating(rating: averageRating),
                          const SizedBox(width: 4.0),
                          Text(
                            ' (${averageRating.toStringAsFixed(1)})',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                const Center(
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor),
                  ),
                ),
                ReviewsStream(placeId: place['place_id']),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showAddReviewDialog(context, place['place_id'], () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: const Text('Añadir una review'),
                  ),
                )
              ],
            ),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
