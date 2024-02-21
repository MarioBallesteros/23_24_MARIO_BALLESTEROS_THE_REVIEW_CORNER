import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String title;
  final String reviewText;
  final double rating;
  final String userId;
  final Timestamp creationDate;

  // Asumiendo que estos son todos los campos que quieres mostrar en tu tabla
  static const int itemCount = 6;

  Review({
    required this.reviewId,
    required this.title,
    required this.reviewText,
    required this.rating,
    required this.userId,
    required this.creationDate,
  });

  // Método para crear una instancia de Review a partir de un documento de Firestore
  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return Review(
      reviewId: doc.id,
      title: data['title'] ?? '',
      reviewText: data['reviewText'] ?? '',
      rating: data['rating'] ?? 0.0,
      userId: data['userId'] ?? '',
      creationDate: data['creationDate'] ?? Timestamp.now(),
    );
  }

  // Método para obtener el encabezado de la columna basado en el índice
  static String getHeaderLabel(int index) {
    switch (index) {
      case 0:
        return 'ID';
      case 1:
        return 'Title';
      case 2:
        return 'Review Text';
      case 3:
        return 'Rating';
      case 4:
        return 'User ID';
      case 5:
        return 'Creation Date';
      default:
        return '';
    }
  }

  // Método para obtener el texto de la celda basado en el índice de la columna
  String getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return reviewId;
      case 1:
        return title;
      case 2:
        return reviewText;
      case 3:
        return rating.toString();
      case 4:
        return userId;
      case 5:
        return creationDate.toDate().toString(); // Asumiendo que quieres mostrar la fecha como String
      default:
        return '';
    }
  }
}
