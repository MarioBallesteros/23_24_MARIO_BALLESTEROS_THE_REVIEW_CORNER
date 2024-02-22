import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReviewImages extends StatelessWidget {
  final String reviewId;

  const ReviewImages({Key? key, required this.reviewId}) : super(key: key);

  Future<List<String>> _fetchImageUrls() async {
    try {
      print('Fetching images for review ID: $reviewId');
      final ListResult result = await FirebaseStorage.instance
          .ref('imagenesReview/$reviewId')
          .listAll();

      List<String> imageUrls = [];
      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        print('Found image URL: $url');
        imageUrls.add(url);
      }

      print('Total images found: ${imageUrls.length}');
      return imageUrls;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchImageUrls(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.error != null) {
          print('FutureBuilder error: ${snapshot.error}');
          return Center(child: Text("Error loading images"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No images found"));
        }

        final imageUrls = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: imageUrls.map((url) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(url, width: 100, height: 100),
            )).toList(),
          ),
        );
      },
    );
  }
}
