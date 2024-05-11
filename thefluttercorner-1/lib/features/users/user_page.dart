import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thefluttercorner/features/users/Usuario.dart';

class UserPage extends StatefulWidget {
  final Usuario usuario;

  const UserPage({Key? key, required this.usuario}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nombreController;
  late TextEditingController _contrasenyaController; // Se mantiene para nuevo usuario
  String _selectedRol = 'usuario';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _contrasenyaController = TextEditingController();
    _selectedRol = widget.usuario.rol.isNotEmpty ? widget.usuario.rol : 'usuario';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenyaController.dispose();
    super.dispose();
  }

  Future<String> _getNextUserId() async {
    final counterRef = _firestore.collection('counters').doc('userCounter');
    final snapshot = await counterRef.get();
    int currentCount = snapshot.exists ? snapshot.data()!['count'] : 0;

    await _firestore.runTransaction((transaction) async {
      transaction.set(counterRef, {'count': currentCount + 1});
    });

    return (currentCount + 1).toString();
  }

  Future<void> _saveUsuario() async {
    final String nombre = _nombreController.text.trim();
    final String contrasenya = _contrasenyaController.text.trim();
    final String rol = _selectedRol;

    // Verifica si es un nuevo usuario para requerir la contraseña, de lo contrario, para un usuario existente la contraseña no se valida
    bool camposValidos = nombre.isNotEmpty && rol.isNotEmpty && (widget.usuario.usuarioId.isEmpty ? contrasenya.isNotEmpty : true);

    if (camposValidos) {
      String usuarioId = widget.usuario.usuarioId.isEmpty ? await _getNextUserId() : widget.usuario.usuarioId;

      // Considera crear un objeto Usuario para simplificar la gestión de datos
      Map<String, dynamic> usuarioData = {
        'nombre': nombre,
        'rol': rol,
      };

      // Solo agrega la contraseña al mapa si es un nuevo usuario
      if (widget.usuario.usuarioId.isEmpty) {
        usuarioData['contrasenya'] = contrasenya;
      }

      await _firestore.collection('users').doc(usuarioId).set(usuarioData, SetOptions(merge: true));

      Fluttertoast.showToast(msg: "Usuario guardado con éxito");
      Navigator.of(context).pop(true);
    } else {
      Fluttertoast.showToast(msg: "Por favor, rellena todos los campos necesarios");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario.usuarioId.isEmpty ? 'Crear Usuario' : 'Editar Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              // Solo muestra el campo de contraseña si es un nuevo usuario
              if (widget.usuario.usuarioId.isEmpty)
                TextField(
                  controller: _contrasenyaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
              DropdownButton<String>(
                value: _selectedRol,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRol = newValue!;
                  });
                },
                items: <String>['admin', 'usuario']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _saveUsuario,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.usuario.usuarioId.isNotEmpty
          ? FloatingActionButton(
        onPressed: () async {
          // Confirmar y ejecutar eliminación del usuario aquí
        },
        child: const Icon(Icons.delete),
        backgroundColor: Colors.red,
      )
          : null,
    );
  }
}
