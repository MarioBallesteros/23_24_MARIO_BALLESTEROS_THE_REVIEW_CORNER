import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  Usuario({
    required this.usuarioId,
    required this.nombre,
    required this.contrasenya,
    required this.rol,
  });

  final String usuarioId;
  final String nombre;
  final String contrasenya;
  final String rol;

  // Mapeo para sacar de Firestore cada usuario
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Usuario(
      usuarioId: doc.id,
      nombre: data['nombre'] ?? '',
      contrasenya: data['contrasenya'] ?? '',
      rol: data['rol'] ?? '',
    );
  }
}
