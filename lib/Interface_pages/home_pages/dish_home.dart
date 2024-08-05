import 'package:flutter/material.dart';

class DishHome extends StatefulWidget {
  const DishHome({super.key});

  @override
  State<DishHome> createState() => _DishHomeState();
}

class _DishHomeState extends State<DishHome> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  final String imagePath = 'assets/Fondo2.jpg';
  final int likesCount = 4;

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Widget beastMeals() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(18.0)),
        Expanded(
            child: ListView(
          scrollDirection: Axis.horizontal,
          children: [foodInformation(), foodInformation()],
        )),
        const Text(
          "Top rating",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Padding(padding: EdgeInsets.all(12.0)),
        Expanded(
          child: ListWheelScrollView(
            itemExtent: 300,
            diameterRatio: 5,
            useMagnifier: true,
            magnification: 1.1,
            children: [
              foodInformation(),
              foodInformation(),
            ],
          ),
        )
      ],
    );
  }

  Widget foodInformation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "Nueces",
              style: TextStyle(fontSize: 20),
            ),
            Image.asset(
              imagePath,
              width: 300, // Ajusta el tamaño según lo necesites
              height: 180,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 300,
              child: Text(
                "Disfruta de toda la nutricion con estas nueces de buen gusto",
                textAlign: TextAlign.center, // Centrar el texto
                overflow: TextOverflow
                    .ellipsis, // Opcional: Muestra "..." si es demasiado largo
                maxLines: 3, // Limita el texto a un máximo de 3 líneas
                style: TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
        const SizedBox(width: 10),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('3'),
            Icon(Icons.thumb_up_alt_outlined),
            // Aquí podrías agregar más widgets si lo deseas, como íconos
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('2'),
            Icon(
              Icons.thumb_down_alt_outlined,
            )
          ],
        )
      ],
    );
  }

  Widget recommended() {
    return ListView(
      scrollDirection: Axis.horizontal,
    );
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: beastMeals(),
        ),
        backgroundColor: const Color.fromARGB(219, 155, 97, 200));
    //backgroundColor: Color.fromARGB(0, 255, 193, 7));
  }
}
