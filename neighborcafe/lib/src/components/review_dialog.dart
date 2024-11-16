import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void showAddReviewDialog(BuildContext context, String placeId) {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add a Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: 'Review'),
              ),
              SizedBox(height: 16.0),
              Text('Rating'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
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
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance.collection('reviews').add({
                  'place_id': placeId,
                  'user': user.email,
                  'comment': _reviewController.text,
                  'rating': _rating,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                _reviewController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Submit Review'),
          ),
        ],
      );
    },
  );
}
