import 'package:flutter/material.dart';
import 'package:eatsily/constants/constants.dart';

class DinersCounter extends StatefulWidget {
  const DinersCounter({super.key});

  @override
  DinersCounterState createState() => DinersCounterState();
}

class DinersCounterState extends State<DinersCounter> {
  int counterDiners = 1;

  void _incrementCounter() {
    setState(() {
      counterDiners++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (counterDiners > 1) counterDiners--;
    });
  }

  @override
  Widget build(BuildContext context) {
    String textDiners = counterDiners == 1 ? "Comensal" : "Comensales";
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _decrementCounter,
            icon: const Icon(
              Icons.remove_circle_outlined,
              color: Colors.red,
            )),
        Text("$counterDiners $textDiners"),
        IconButton(
          onPressed: _incrementCounter,
          icon: const Icon(Icons.add_circle),
          color: colorGreen,
        ),
      ],
    );
  }
}
