import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefluttercorner/features/dashboard/review.dart';

class ModificarReview extends StatefulWidget {
  final Review review;

  const ModificarReview({Key? key, required this.review}) : super(key: key);

  @override
  _ModificarReviewState createState() => _ModificarReviewState();
}

class _ModificarReviewState extends State<ModificarReview> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewTextController = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.review.title;
    _reviewTextController.text = widget.review.reviewText;
    _rating = widget.review.rating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewTextController.dispose();
    super.dispose();
  }

  Future<void> _updateReview() async {
    // Actualiza la review en Firestore
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.review.reviewId)
        .update({
      'title': _titleController.text,
      'reviewText': _reviewTextController.text,
      'rating': _rating,
    });

    // Vuelve a la pantalla anterior
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Review'),
      ),
      body: Padding(
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
              maxLines: null,
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: 'Rating: $_rating',
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _updateReview,
              child: Text('Update Review'),
            ),
          ],
        ),
      ),
    );
  }
}
