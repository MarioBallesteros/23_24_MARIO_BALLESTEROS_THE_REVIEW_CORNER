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
      await FirebaseFirestore.instance.collection('reviews').doc(widget.review.reviewId).update({
        'title': _titleController.text,
        'reviewText': _reviewTextController.text,
        'rating': rating,
      });
      // Si la actualización es exitosa, muestra un toast de éxito
      Fluttertoast.showToast(
        msg: "Se ha actualizado correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop(true); // Indica que se han realizado cambios
    } catch (e) {
      // Si ocurre un error, muestra un toast de error
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
        title: Text(widget.review.reviewId.isEmpty ? 'Create Review' : 'Edit Review'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _reviewTextController,
                decoration: InputDecoration(labelText: 'Review Text'),
                maxLines: null, // Permite múltiples líneas
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number, // Teclado numérico
              ),
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
