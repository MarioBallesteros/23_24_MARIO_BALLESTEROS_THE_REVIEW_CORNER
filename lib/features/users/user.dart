import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.userId,
    required this.name,
    required this.role,
  });

  final String userId;
  final String name;
  final String role;

  //Mapeo para poder sacar de la tabla de base de datos cada Usuario
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return User(
      userId: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
    );
  }
}