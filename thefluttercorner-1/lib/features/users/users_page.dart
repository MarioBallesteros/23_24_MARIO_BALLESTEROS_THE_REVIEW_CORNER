import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:thefluttercorner/features/users/Usuario.dart';
import 'package:thefluttercorner/features/users/user_page.dart';
import '../../widgets/widgets.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Usuarios',
              description: 'Lista de usuarios que pueden iniciar sesión en este panel.',
            ),
            const Gap(16),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text("No hay datos disponibles"));
                    }
                    final users = snapshot.data!.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
                    return ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final usuario = users[index];
                        return ListTile(
                          title: Text(
                            '${usuario.nombre} (ID: ${usuario.usuarioId})', // Muestra el nombre y el ID del usuario
                            style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Rol: ${usuario.rol}', // Muestra el rol del usuario
                            style: theme.textTheme.labelMedium,
                          ),
                          trailing: const Icon(Icons.navigate_next_outlined),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => UserPage(usuario: usuario)),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UserPage(usuario: Usuario(usuarioId: '', nombre: '', contrasenya: '', rol: ''))),
              );
            },
          ),
        )
    );
  }
}
