import 'package:flutter/material.dart';
import 'account_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Screen(color: Colors.red),
    Screen(color: Color.fromARGB(255, 244, 54, 120)),
    Screen(color: Color.fromARGB(255, 54, 114, 244)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index != 2) {
        _currentIndex = index;
      } else {
        // Si se selecciona la tercera opción (index = 2), muestra el contenido del perfil
        _currentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    if (_currentIndex != 2) {
      currentPage = _pages[_currentIndex];
    } else {
      currentPage = const AccountPage();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Bienvenido')),
        automaticallyImplyLeading: false,
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(255, 25, 97, 27),
        selectedFontSize: 15,
        unselectedFontSize: 13,
        iconSize: 25,
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedLabelStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded, color: Colors.green),
            activeIcon: Icon(Icons.star_border_outlined),
            label: 'Mejores\nplatillos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.soup_kitchen_sharp, color: Colors.green),
            activeIcon: Icon(Icons.soup_kitchen_outlined),
            label: 'Cocina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.green),
            activeIcon: Icon(Icons.account_circle_outlined),
            label: 'Perfil',
          ),
        ],
      ),
      extendBody: true,
    );
  }
}

class Screen extends StatelessWidget {
  final Color color;

  const Screen({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
    );
  }
}
