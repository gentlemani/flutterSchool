import 'package:eatsily/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/utils/auth.helpers.dart';

class SettingsAccount extends StatefulWidget {
  const SettingsAccount({super.key});

  @override
  State<SettingsAccount> createState() => _SettingsAccountState();
}

class _SettingsAccountState extends State<SettingsAccount> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Close the dialog box without closing session
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); //Close the dialog box and close session
                handleLogout(context, redirectTo: const WidgetTree());
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones"),
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        leading: IconButton(
          icon: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2)),
              child: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 0, 0, 0),
              )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildSettingCard(
              icon: Icons.straighten,
              title: 'Unidades de medida',
              color: Colors.green,
              onTap: () {},
            ),
            _buildSettingCard(
              icon: Icons.star_rate,
              title: 'Valora Eatsily',
              color: Colors.orange,
              onTap: () {},
            ),
            _buildSettingCard(
              icon: Icons.share,
              title: 'Comparte Eatsily',
              color: Colors.pink,
              onTap: () {},
            ),
            _buildSettingCard(
              icon: Icons.info_outline,
              title: 'Sobre Eatsily',
              color: Colors.teal,
              onTap: () {},
            ),
            _buildSettingCard(
              icon: Icons.contact_mail,
              title: 'Contacto',
              color: Colors.amber,
              onTap: () {},
            ),
            _buildSettingCard(
              icon: Icons.exit_to_app,
              title: 'Cerrar Sesión',
              color: Colors.brown,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
