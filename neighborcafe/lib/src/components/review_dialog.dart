import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void showAddReviewDialog(
    BuildContext context, String placeId, VoidCallback onReviewSubmitted) {
  final TextEditingController reviewController = TextEditingController();
  double rating = 0.0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Añadir una review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const SizedBox(height: 16.0),
              const Text('Rating'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  rating = rating;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Salir'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Fetch the user's name from Firestore
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                final userName = userDoc['name'];

                await FirebaseFirestore.instance.collection('reviews').add({
                  'place_id': placeId,
                  'user': userName, // Use the user's name instead of email
                  'comment': reviewController.text,
                  'rating': rating,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                reviewController.clear();
                onReviewSubmitted();
              }
            },
            child: const Text('Submit Review'),
          ),
        ],
      );
    },
  );
}
