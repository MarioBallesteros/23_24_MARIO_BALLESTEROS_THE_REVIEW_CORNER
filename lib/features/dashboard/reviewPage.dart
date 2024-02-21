import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefluttercorner/features/dashboard/review.dart';

class ReviewPage extends StatefulWidget {
  final Review review;

  const ReviewPage({Key? key, required this.review}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late TextEditingController _titleController;
  late TextEditingController _reviewTextController;
  late TextEditingController _ratingController; // Asegúrate de manejar correctamente el tipo de dato
  // Considera agregar controladores para los demás campos según sea necesario

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.review.title);
    _reviewTextController = TextEditingController(text: widget.review.reviewText);
    _ratingController = TextEditingController(text: widget.review.rating.toString());
    // Inicializa los demás controladores aquí
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewTextController.dispose();
    _ratingController.dispose();
    // Dispone los demás controladores aquí
    super.dispose();
  }

  Future<void> _saveReview() async {
    // Aquí implementarías la lógica para guardar o actualizar la reseña
    // Similar a _saveUser, pero adaptado para reseñas
  }

  @override
  Widget build(BuildContext context) {
    // Construye la UI para la página de edición/creación de reseñas
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review.reviewId.isEmpty ? 'Create Review' : 'Edit Review'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campos de texto para editar los atributos de la reseña
              // Botón para guardar los cambios
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveReview,
        child: const Icon(Icons.save),
      ),
    );
  }
}
