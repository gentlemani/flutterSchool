import 'package:flutter/material.dart';
import 'package:eatsily/Interface_pages/home_pages/dish_home.dart';
import 'package:eatsily/Interface_pages/home_pages/menu_home.dart';
import 'home_pages/account_home.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  int _currentIndex = 0;

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  void _onItemTapped(int index) {
    setState(() {
      // Si se selecciona la tercera opción (index = 2), muestra el contenido del perfil
      _currentIndex = index;
    });
  }

  Widget page() {
    Widget currentPage;
    if (_currentIndex == 0) {
      currentPage = const DishHome();
    } else if (_currentIndex == 1) {
      currentPage = const MenuHome();
    } else {
      currentPage = const AccountHome();
    }
    return currentPage;
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 25, 97, 27),
        selectedFontSize: 15,
        unselectedFontSize: 13,
        iconSize: 25,
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 25, 97, 27),
            fontWeight: FontWeight.bold),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded, color: Colors.black),
            activeIcon: Icon(Icons.star_border_outlined),
            label: 'Mejores\nplatillos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.soup_kitchen_sharp, color: Colors.black),
            activeIcon: Icon(Icons.soup_kitchen_outlined),
            label: 'Cocina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),
            activeIcon: Icon(Icons.account_circle_outlined),
            label: 'Perfil',
          ),
        ],
      ),
      extendBody: true,
    );
  }
}
