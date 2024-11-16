import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import '../../components/review_dialog.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;

  const StarRating(
      {super.key,
      this.rating = 0.0,
      this.starCount = 5,
      this.color = Colors.amber});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        double fractionalPart = rating - index;
        if (fractionalPart >= 1) {
          return Icon(Icons.star, color: color);
        } else if (fractionalPart > 0) {
          return Stack(
            children: [
              Icon(Icons.star_border, color: color),
              ClipRect(
                clipper: _StarClipper(fractionalPart),
                child: Icon(Icons.star, color: color),
              ),
            ],
          );
        } else {
          return Icon(Icons.star_border, color: color);
        }
      }),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fraction;

  _StarClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
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

  void _showMarkerDetails(Map<String, dynamic> place) async {
    final apiKey = await _getApiKey();
    String imageUrl;

    if (place['photos'] != null && place['photos'].isNotEmpty) {
      imageUrl =
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$apiKey';
    } else {
      // Fetch a random coffee image from Unsplash
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos/random?query=coffee&client_id=YOUR_UNSPLASH_API_KEY'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        imageUrl = data['urls']['regular'];
      } else {
        // Fallback image if Unsplash API fails
        imageUrl =
            'https://pqs.pe/wp-content/uploads/2016/08/pqs-como-abrir-cafeteria.jpg';
      }
    }

    // Pre-fetch the image
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
      print('Error loading image: $e');
    } finally {
      imageStream.removeListener(listener);
    }

    // Open the modal bottom sheet after the image has loaded
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take up more space
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.9, // Adjust the height as needed
          width: MediaQuery.of(context).size.width, // Full width of the screen
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16.0), // Smooth border radius
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
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    place['name'] ?? 'No name available',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                      return const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarRating(rating: 0),
                            SizedBox(width: 4.0),
                            Text(
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
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                      return const Center(child: Text('No reviews yet.'));
                    }
                    final reviews = snapshot.data!.docs;
                    return Column(
                      children: reviews.map((review) {
                        return Card(
                          child: ListTile(
                            title: Text(review['user']),
                            subtitle: Text(review['comment']),
                            trailing: StarRating(rating: review['rating']),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
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
                    child: const Text('Add a Review'),
                  ),
                ),
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
