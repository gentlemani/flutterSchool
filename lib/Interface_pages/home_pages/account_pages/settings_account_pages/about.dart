import 'package:flutter/material.dart';

class AboutEatsily extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sobre Eatsily'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sobre Eatsily',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Eatsily es tu asistente personal de cocina. Gracias a nuestra avanzada'
              'tecnología de recomendación, Eatsily aprende de tus gustos y preferencias'
              'para ofrecerte recetas personalizadas. Cada vez que interactúas con la app,'
              'Eatsily ajusta sus sugerencias para brindarte platos que realmente disfrutarás,'
              'basándose en ingredientes, tipos de cocina y categorías que te gustan. Ya'
              'sea que quieras optimizar tu dieta o simplemente encontrar inspiración para'
              'tus comidas diarias, Eatsily se adapta a tus necesidades. ¡Explora, cocina y'
              'disfruta de una experiencia culinaria hecha a tu medida!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
