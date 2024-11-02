import 'package:flutter/material.dart';

class DinersCounter extends StatefulWidget {
  const DinersCounter({super.key});

  @override
  _DinersCounterState createState() => _DinersCounterState();
}

class _DinersCounterState extends State<DinersCounter> {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _decrementCounter,
            icon: const Icon(Icons.remove_circle_outlined)),
        Text("$counterDiners Comensal(es)"),
        IconButton(
            onPressed: _incrementCounter, icon: const Icon(Icons.add_circle)),
      ],
    );
  }
}
