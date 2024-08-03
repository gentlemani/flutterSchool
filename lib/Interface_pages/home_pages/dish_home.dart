import 'package:flutter/material.dart';

class DishHome extends StatefulWidget {
  const DishHome({super.key});

  @override
  State<DishHome> createState() => _DishHomeState();
}

class _DishHomeState extends State<DishHome> {
  final String imagePath = 'assets/Fondo2.jpg';
  final int likesCount = 4;

  Widget scrollplat() {
    return ListWheelScrollView(
      itemExtent: 300,
      diameterRatio: 5,
      useMagnifier: true,
      magnification: 1.1,
      children: [
        _sdsubmitButton(),
        _sdsubmitButton(),
        _sdsubmitButton(),
        _sdsubmitButton(),
        _sdsubmitButton(),
        _sdsubmitButton()
      ],
    );
  }

  Widget _sdsubmitButton() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: scrollplat(),
        ),
        backgroundColor: const Color.fromARGB(219, 155, 97, 200));
    //backgroundColor: Color.fromARGB(0, 255, 193, 7));
  }
}
