import 'dart:io';
import 'package:eatsily/Interface_pages/home_pages/account_pages/create_recipe_account.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/edit_account.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/settings_account.dart';
import 'package:eatsily/Interface_pages/home_pages/recipes_page/recipes.dart';
import 'package:eatsily/common_widgets/seasonal_background.dart';
import 'package:eatsily/constants/constants.dart';
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
  String selectedCategory = "preferidas";

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
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Preferencias',
            style: buttomTextStyle,
          ),
          const SizedBox(width: 50),
          const Icon(Icons.room_preferences),
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
                      selectedCategory = "preferidas";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == "preferidas"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: Text("Preferidas", style: buttomTextStyle),
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
                  child: Text("Creadas", style: buttomTextStyle),
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
            child: selectedCategory == "preferidas"
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
          .where('vote', isEqualTo: true) // Filter only Likes
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay recetas preferidas.'));
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

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.75),
              itemCount: recipeSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = recipeSnapshot.data!.docs[index];
                final recipeId = doc.id;
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipesHome(recetaId: recipeId),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            doc['image'], // URL de la imagen
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            doc['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCreadas() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateRecipeAccount()));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: colorGreen,
                ),
                const SizedBox(width: 10),
                Text(
                  "Crear Receta",
                  style: buttomTextStyle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Recetas')
              .where('created_by', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No has creado recetas.'));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas en el grid
                crossAxisSpacing: 10.0, // Espaciado entre columnas
                mainAxisSpacing: 10.0, // Espaciado entre filas
                childAspectRatio: 1 / 0.9, // Relación de aspecto
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Card(
                  elevation: 4.0,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Receta seleccionada  ${doc['name']}"),
                      ));
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            doc['image'], // URL de la imagen
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            doc['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )),
      ],
    ));
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
          titleTextStyle: headingTextStyle,
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
          SeasonalBackground(),
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
                        style: bodyTextStyle,
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
