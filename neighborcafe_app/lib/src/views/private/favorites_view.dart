import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:neighborcafe/src/settings/app_colors.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends State<FavoritesView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  User? loggedinUser;
  String? username;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  Stream<List<Map<String, dynamic>>> getFavorites(String? username) {
  return FirebaseFirestore.instance
      .collection('favorites')
      .where('user', isEqualTo: username)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
}

  Future<void> deleteFavorite(String docId) async {
    await FirebaseFirestore.instance.collection('favorites').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Título en la parte superior
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mis Cafeterías Favoritas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getFavorites(username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No tienes cafeterías favoritas aún.'),
                  );
                }

                final favorites = snapshot.data!;

                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: favorite['place_photoUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  favorite['place_photoUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.coffee, size: 50),
                        title: Text(
                          favorite['place_name'] ?? 'Nombre no disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(favorite['place_address'] ?? 'Dirección no disponible'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar favorito'),
                                content: const Text(
                                    '¿Estás seguro de que deseas eliminar esta cafetería de tus favoritos?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await deleteFavorite(favorite['id']);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
