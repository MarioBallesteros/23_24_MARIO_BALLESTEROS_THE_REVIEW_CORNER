import 'package:flutter/material.dart';
import 'package:thefluttercorner/features/dashboard/review.dart';
import 'package:thefluttercorner/features/dashboard/reviewImages.dart';

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
            onPressed: () {
              // Aquí podrías navegar a una página de edición si la tienes.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.title,
                style: Theme.of(context).textTheme.headline5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Rating: ${review.rating}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Text(
                review.reviewText,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 20),
              Text(
                'Images:',
                style: Theme.of(context).textTheme.headline6,
              ),
              // Asumiendo que ReviewImages es un widget que toma una lista de URLs de imágenes.
              ReviewImages(reviewId: review.reviewId),
            ],
          ),
        ),
      ),
    );
  }
}
