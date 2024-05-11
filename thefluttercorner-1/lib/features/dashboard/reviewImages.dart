import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReviewImages extends StatelessWidget {
  final String reviewId;

  const ReviewImages({Key? key, required this.reviewId}) : super(key: key);

  Future<List<String>> _fetchImageUrls() async {
    List<String> imageUrls = [];
    try {
      print('Fetching images for review ID: $reviewId');
      // Intenta listar todos los archivos dentro de la carpeta correspondiente al reviewId
      final ListResult result = await FirebaseStorage.instance
          .ref('imagenesReview/$reviewId')
          .listAll();

      // Para cada referencia de archivo en el resultado, obtén la URL de descarga
      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        imageUrls.add(url); // Añade la URL a la lista de URLs de imágenes
        print('Found image URL: $url');
      }
      print('Total images found: ${imageUrls.length}');
    } catch (e) {
      print('Error fetching images: $e');
    }
    return imageUrls; // Devuelve la lista de URLs de imágenes
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

        // Si hay datos, muestra las imágenes en una fila horizontal
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
