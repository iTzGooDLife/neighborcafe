import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'star_rating.dart'; // Asegúrate de importar el widget StarRating si está en otro archivo
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ReviewsStream extends StatelessWidget {
  final String placeId;

  ReviewsStream({required this.placeId});

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('place_id', isEqualTo: placeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No hay reviews todavía. ¡Sé el primero!'));
        }
        final reviews = snapshot.data!.docs;
        return Column(
          children: reviews.map((review) {
            return Card(
              child: GestureDetector(
                onDoubleTap: () async {
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirmar eliminación'),
                        content: Text(
                            '¿Estás seguro de que deseas eliminar este comentario?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text('Eliminar'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete) {
                    await FirebaseFirestore.instance
                        .collection('reviews')
                        .doc(review.id)
                        .delete();
                  }
                },
                child: ListTile(
                  title: Text(review['user']),
                  subtitle: Text(review['comment']),
                  trailing: StarRating(rating: review['rating']),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
