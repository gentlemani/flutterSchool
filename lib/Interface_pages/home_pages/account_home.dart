import 'dart:io';
import 'package:eatsily/Interface_pages/home_pages/account_pages/edit_account.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/settings_account.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountHome extends StatefulWidget {
  const AccountHome({super.key});

  @override
  State<AccountHome> createState() => _AccountHomeState();
}

class _AccountHomeState extends State<AccountHome> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  File? _imageFile;
  final picker = ImagePicker();
  String? _uploadStatusMessage;
  String? _profileImageUrl;
  bool _isLoading = false;
  String selectedCategory = "gustadas";

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true; // Show the load indicator
        _imageFile = File(pickedFile.path);
      });
      await uploadProfileImage(_imageFile!); // Upload the image
      setState(() {
        _isLoading = false; // Hide the load indicator
      });
    }
  }

  Future<void> uploadProfileImage(File image) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      // Upload the image
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask;

      String downloadURL = await storageReference.getDownloadURL();
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(uid);

      DocumentSnapshot doc = await userDocRef.get();
      if (doc.exists) {
        // The document exists, we can update it
        await userDocRef.update({
          'profileImageUrl': downloadURL,
        });
      } else {
        // The document does not exist, we can create a new
        await userDocRef.set({
          'profileImageUrl': downloadURL,
        });
      }
      setState(() {
        _uploadStatusMessage = 'Imagen de perfil actualizada.';
      });
    } catch (e) {
      setState(() {
        _uploadStatusMessage = 'Error al subir la imagen.';
      });
    }
  }

  void _loadUserProfileImage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _profileImageUrl = userData?.containsKey('profileImageUrl') == true
            ? userData!['profileImageUrl']
            : null; // Null if the field doesn't exist
      });
    }
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _buttonPref() {
    return FloatingActionButton.extended(
      onPressed: () {},
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 230, 227, 228),
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(width: 50),
          Icon(Icons.room_preferences),
        ],
      ),
      extendedPadding: const EdgeInsets.only(left: 20, right: 20),
    );
  }

  Widget _gestureImage() {
    return GestureDetector(
      onTap: () {
        getImage();
      },
      child: CircleAvatar(
        radius: 80,
        backgroundColor: Colors.white,
        backgroundImage: _imageFile != null
            ? FileImage(_imageFile!) as ImageProvider<Object>
            : (_profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage('assets/iconoP.png'))
                as ImageProvider<Object>?,
        child: _imageFile == null && _profileImageUrl == null
            ? const Icon(Icons.person,
                size: 80, color: Color.fromARGB(0, 158, 158, 158))
            : null,
      ),
    );
  }

  Widget list() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = "gustadas";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == "gustadas"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: const Text("Recetas Gustadas"),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = "Creadas";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == "Creadas"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: const Text("Recetas Creadas"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Show data according to the selected category
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: selectedCategory == "gustadas"
                ? _buildGustadas()
                : _buildCreadas(),
          ),
        ),
      ],
    );
  }

  Widget _buildGustadas() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Vote')
          .where('vote', isEqualTo: true) // Filtrar solo los likes
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay recetas gustadas.'));
        }

        List<String> recipeIds =
            snapshot.data!.docs.map((doc) => doc.id).toList();

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Recetas')
              .where(FieldPath.documentId, whereIn: recipeIds)
              .get(),
          builder: (context, recipeSnapshot) {
            if (recipeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!recipeSnapshot.hasData || recipeSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No se encontraron recetas.'));
            }

            return ListView(
              children: recipeSnapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['name']),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Receta seleccionada: ${doc['name']}')),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildCreadas() {
    return ListView(
      children: List.generate(0, (index) {
        return ListTile(
          title: Text("Receta creadas ${index + 1}"),
          onTap: () {
            Text("Receta creadas ${index + 1} seleccionada");
          },
        );
      }),
    );
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return ClipRRect(
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text('Perfil'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditAccount(gestureImage: _gestureImage())),
                ).then((_) {});
              },
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsAccount()),
                ).then((_) {});
              },
            ),
          ],
        ),
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                _gestureImage(),
                const SizedBox(height: 20),
                if (_uploadStatusMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _uploadStatusMessage!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                user != null
                    ? Text(
                        '${user.email}',
                        style: const TextStyle(fontSize: 19),
                      )
                    : const Text('No hay un usuario autenticado'),
                const SizedBox(height: 30),
                _buttonPref(),
                const SizedBox(height: 20),
                Expanded(child: list())
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ]),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
