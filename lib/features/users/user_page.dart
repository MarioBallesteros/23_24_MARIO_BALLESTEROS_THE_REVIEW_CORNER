import 'package:flutter/material.dart';
import 'package:thefluttercorner/features/users/user.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/widgets.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.user});

  final User user;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    final String name = _nameController.text.trim();
    final String role = _roleController.text.trim();

    if (name.isNotEmpty && role.isNotEmpty) {
      // Aquí, implementa la lógica para guardar el nuevo usuario en Firestore
      // Si widget.user.userId está vacío, es un nuevo usuario. De lo contrario, es una edición.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.userId.isEmpty ? 'Create User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            ElevatedButton(
              onPressed: _saveUser,
              child: Text('Save'),
            ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
    onPressed: () {
    // Tu lógica para manejar la pulsación del botón...
    },
    ));
  }
}

