import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefluttercorner/features/dashboard/review.dart';
import 'package:thefluttercorner/features/dashboard/reviewImages.dart';
import 'package:thefluttercorner/features/dashboard/reviewPage.dart';

class ReviewDetailsPage extends StatelessWidget {
  final Review review;

  const ReviewDetailsPage({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ReviewPage(review: review)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('reviews').doc(review.reviewId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text("No Review Data Available"));
          }

          // Rebuild Review object from the snapshot
          final updatedReview = Review.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    updatedReview.title,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Rating: ${updatedReview.rating}',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  Text(
                    updatedReview.reviewText,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Images:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  ReviewImages(reviewId: updatedReview.reviewId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
