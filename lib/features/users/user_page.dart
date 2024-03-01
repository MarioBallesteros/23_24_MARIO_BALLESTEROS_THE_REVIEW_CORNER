import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefluttercorner/features/users/Usuario.dart';

class UserPage extends StatefulWidget {
  final Usuario usuario;

  const UserPage({super.key, required this.usuario});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nombreController;
  late TextEditingController _contrasenyaController;
  late TextEditingController _rolController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _contrasenyaController = TextEditingController(); // Asumiendo que no mostramos la contraseña
    _rolController = TextEditingController(text: widget.usuario.rol);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenyaController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  Future<void> _saveUsuario() async {
    final String nombre = _nombreController.text.trim();
    final String contrasenya = _contrasenyaController.text.trim(); // Asumiendo que quieres guardar/actualizar la contraseña
    final String rol = _rolController.text.trim();

    if (nombre.isNotEmpty && rol.isNotEmpty) {
      String usuarioId = widget.usuario.usuarioId;
      if (usuarioId.isEmpty) {
        // Crear un nuevo usuario
        DocumentReference docRef = await FirebaseFirestore.instance.collection('users').add({
          'nombre': nombre,
          'contrasenya': contrasenya, // Considera la seguridad de almacenar contraseñas
          'rol': rol,
        });
        usuarioId = docRef.id; // Obtener el ID del nuevo documento
      } else {
        // Actualizar un usuario existente
        await FirebaseFirestore.instance.collection('users').doc(usuarioId).update({
          'nombre': nombre,
          'contrasenya': contrasenya,
          'rol': rol,
        });
      }

      Navigator.of(context).pop(); // Regresa a la pantalla anterior después de guardar
    }
  }

  Future<void> _deleteUsuario() async {
    // Similar a _deleteUser pero utilizando el campo `usuarioId`
    if (widget.usuario.usuarioId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(widget.usuario.usuarioId).delete();
      Navigator.of(context).pop(); // Regresa a la pantalla anterior después de eliminar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario.usuarioId.isEmpty ? 'Crear Usuario' : 'Editar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _contrasenyaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _rolController,
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            ElevatedButton(
              onPressed: _saveUsuario,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.usuario.usuarioId.isNotEmpty
          ? FloatingActionButton(
        onPressed: _deleteUsuario,
        child: const Icon(Icons.delete),
        backgroundColor: Colors.red,
      )
          : null,
    );
  }
}
