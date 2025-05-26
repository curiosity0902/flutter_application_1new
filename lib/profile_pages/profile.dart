import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/storage/logo.dart';
import 'package:flutter_application_1/profile_pages/edit_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  File? _selectedFile;
  dynamic userDoc;
  final ImageLogoStorage imageLogoStorage = ImageLogoStorage();
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    getByUserId();
  }

  Future<void> selectImageGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> getByUserId() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        userDoc = documentSnapshot.data();
      });
      print("User document loaded: $userDoc");
    } catch (e) {
      print("Error getting user document: $e");
    }
  }

  Future<void> pushStorage() async {
    if (_selectedFile != null) {
      try {
        setState(() {
          _isLoadingImage = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$userId.jpg');
        await ref.putFile(_selectedFile!);
        final url = await ref.getDownloadURL();
        print("Image URL: $url");
        setState(() {
          imageLogoStorage.imageUrl = url;
        });

        if (imageLogoStorage.imageUrl != null &&
            imageLogoStorage.imageUrl!.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'image': imageLogoStorage.imageUrl!,
          });
          print("User document updated with image URL");
          await getByUserId();
        } else {
          print("Image URL is empty");
        }
      } catch (error) {
        print("Error uploading image: $error");
      } finally {
        setState(() {
          _isLoadingImage = false;
        });
      }
    } else {
      print("No file selected");
    }
  }

  Future<void> loadImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    await Future.delayed(Duration(seconds: 3)); 

    setState(() {
      _isLoadingImage = false; 
    });
  }

  Future<void> deleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Удаление аккаунта"),
          content: Text("Вы действительно хотите удалить аккаунт?"),
          actions: <Widget>[
            TextButton(
              child: Text("Нет"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .delete();
                  if (userDoc['image'] != null && userDoc['image'] != '') {
                    await FirebaseStorage.instance
                        .refFromURL(userDoc['image'])
                        .delete();
                  }
                  await FirebaseAuth.instance.currentUser!.delete();
                  if (mounted) {
                    Navigator.popAndPushNamed(context, '/');
                  }
                } catch (error) {
                  print("Error deleting account: $error");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.popAndPushNamed(context, '/');
      }
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formatDate(Timestamp timestamp) {
    if (timestamp == null) return "Дата рождения не указана";
    DateTime date = timestamp.toDate();
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        child: userDoc != null
            ? Column(
                children: [
                  ClipPath(
                    clipper: DiagonalClipper(),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.47,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A6157),
                            const Color(0xFF4A6157).withOpacity(0.95),
                            const Color(0xFF4A6157).withOpacity(0.90),
                            const Color(0xFF4A6157).withOpacity(0.85),
                            const Color(0xFF4A6157).withOpacity(0.75),
                            const Color(0xFF4A6157).withOpacity(0.60),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: _isLoadingImage
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            color: const Color(
                                                0xFF4A6157),
                                          ),
                                        )
                                      : userDoc['image'] == null ||
                                              userDoc['image'] == ''
                                          ? CircleAvatar(
                                              radius: 80,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              child: IconButton(
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4A6157),
                                                ),
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  await selectImageGallery();
                                                  if (_selectedFile != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Color(
                                                              0xFF4A6157), 
                                                        ),
                                                      ),
                                                    );
                                                    await pushStorage();
                                                    if (mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                },
                                              ),
                                            )
                                          : userDoc['image'] == ''
                                              ? CircleAvatar(
                                                  radius: 80,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  backgroundImage: AssetImage(
                                                      'assets/icon_profile.png'), 
                                                  onBackgroundImageError:
                                                      (error, stackTrace) {
                                                    print(
                                                        "Error loading image: $error");
                                                  },
                                                )
                                              : CircleAvatar(
                                                  radius: 80,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  backgroundImage: NetworkImage(
                                                      userDoc['image']),
                                                  onBackgroundImageError:
                                                      (error, stackTrace) {
                                                    print(
                                                        "Error loading image: $error");
                                                  },
                                                ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 35.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ваш профиль',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0, top: 15),
                          child: Text(
                            textAlign: TextAlign.center,
                            "${userDoc['fullname']}",
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email, 
                                color: Colors.black, 
                                size: 20, 
                              ),
                              const SizedBox(
                                  width:
                                      8),
                              Text(
                                "Email: ${userDoc['email']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month, 
                                color: Colors.black, 
                                size: 20, 
                              ),
                              const SizedBox(
                                  width:
                                      8), 
                              Text(
                                "Дата рождения: ${formatDate(userDoc['dateofbirth'] ?? Timestamp.now())}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone, 
                                color: Colors.black, 
                                size: 20, 
                              ),
                              const SizedBox(
                                  width:
                                      8), 
                              Text(
                                "Телефон: ${userDoc['phone']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 16),
                        // // Подпись "Ваш профиль" с круглыми элементами по бокам

                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Кнопка "Редактировать" с текстом, без иконки
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 70.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(),
                                  ),
                                );
                                if (result == true) {
                                  await getByUserId();
                                }
                              },
                              child: Text(
                                "Редактировать",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () => signOut(),
                                  icon: Icon(Icons.exit_to_app,
                                      color: Colors.black),
                                  label: Text(
                                    "Выйти",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(
                                    width: 20), 
                                TextButton.icon(
                                  onPressed: () => deleteAccount(),
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    "Удалить",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF4A6157),
                ),
              ),
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
