import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late TextEditingController _ratingController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.review.title);
    _reviewTextController = TextEditingController(text: widget.review.reviewText);
    _ratingController = TextEditingController(text: widget.review.rating.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewTextController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    try {
      final double rating = double.tryParse(_ratingController.text) ?? widget.review.rating;
      String newReviewId;

      if (widget.review.reviewId.isEmpty) {
        // Obtener el total de documentos en la colección para generar un nuevo ID
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('reviews').get();
        int totalDocuments = querySnapshot.docs.length;
        newReviewId = (totalDocuments + 1).toString(); // Este es un enfoque básico y puede tener problemas en entornos concurrentes

        // Crear un nuevo documento con un ID generado manualmente
        await FirebaseFirestore.instance.collection('reviews').doc(newReviewId).set({
          'title': _titleController.text,
          'reviewText': _reviewTextController.text,
          'rating': rating,
          // Agrega cualquier otro campo necesario
        });
        Fluttertoast.showToast(
          msg: "Reseña creada correctamente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Actualizar un documento existente
        await FirebaseFirestore.instance.collection('reviews').doc(widget.review.reviewId).update({
          'title': _titleController.text,
          'reviewText': _reviewTextController.text,
          'rating': rating,
          // Agrega cualquier otro campo necesario
        });
        Fluttertoast.showToast(
          msg: "Reseña actualizada correctamente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      Navigator.of(context).pop(true); // Indica que se han realizado cambios
    } catch (e) {
      // Manejar errores
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review.reviewId.isEmpty ? 'Crear Reseña' : 'Editar Reseña'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _reviewTextController,
                decoration: const InputDecoration(labelText: 'Texto de la Reseña'),
                maxLines: null, // Permite múltiples líneas
              ),
              TextField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Calificación'),
                keyboardType: TextInputType.number, // Teclado numérico
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReview,
                child: const Text('Guardar Reseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
