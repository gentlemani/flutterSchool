import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: const Color.fromARGB(255, 26, 92, 114),
      selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      selectedFontSize: 14,
      unselectedFontSize: 16,
      iconSize: 25,
      backgroundColor: const Color.fromARGB(251, 174, 171, 171),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      selectedLabelStyle: const TextStyle(
          color: Color.fromARGB(255, 26, 92, 114),
          fontWeight: FontWeight.bold),
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.star_rounded,
              color: Color.fromARGB(255, 26, 92, 114)),
          activeIcon: Icon(Icons.star_border_outlined),
          label: 'Mejores\nplatillos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.soup_kitchen_sharp,
              color: Color.fromARGB(255, 26, 92, 114)),
          activeIcon: Icon(Icons.soup_kitchen_outlined),
          label: 'Cocina',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle,
              color: Color.fromARGB(255, 26, 92, 114)),
          activeIcon: Icon(Icons.account_circle_outlined),
          label: 'Perfil',
        ),
      ],
    );
  }
}
