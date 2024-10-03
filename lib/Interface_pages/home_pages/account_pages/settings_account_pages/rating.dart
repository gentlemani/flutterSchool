import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rating extends StatefulWidget {
  const Rating({super.key});

  @override
  RatingState createState() => RatingState();
}

class RatingState extends State<Rating> {
  double _rating = 0.0;
  final String userId = 'ID_DEL_USUARIO';

  Future<void> _submitRating() async {
    if (_rating > 0) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          'rating': _rating,
        }, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Has valorado la app con $_rating estrellas.')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la valoración: $error')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona una valoración.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valora la App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Cómo valoras nuestra aplicación?',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Enviar Valoración'),
            ),
          ],
        ),
      ),
    );
  }
}
