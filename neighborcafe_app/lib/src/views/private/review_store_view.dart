import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewStoreView extends StatefulWidget {
  const ReviewStoreView({super.key});

  @override
  _ReviewStoreViewState createState() => _ReviewStoreViewState();
}

class _ReviewStoreViewState extends State<ReviewStoreView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedinUser; // Cambia a User? para permitir valores nulos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            username != null ? "Welcome $username" : "Welcome User",
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }
}
