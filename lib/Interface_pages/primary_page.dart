import 'package:flutter/material.dart';
import 'account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  List<String> docIDs = [];

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              print(element.reference);
            }));
  }

  @override
  void initState() {
    getDocId();
    super.initState();
  }

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
      body: currentPage,
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
            icon: Icon(Icons.star_rounded, color: Colors.blueGrey),
            activeIcon: Icon(Icons.star_border_outlined),
            label: 'Mejores\nplatillos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.soup_kitchen_sharp, color: Colors.blueGrey),
            activeIcon: Icon(Icons.soup_kitchen_outlined),
            label: 'Cocina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.blueGrey),
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
