import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:toast/toast.dart';

class EditProfilePage extends StatefulWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  String oldPassword = '';
  dynamic userData;
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      setState(() {
        userData = documentSnapshot.data();
        _fullNameController.text = userData['fullname'];
        _phoneController.text = userData['phone'];
        _passwordController.text = userData['password'];
        oldPassword = userData['password'];
      });
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  Future<void> selectImageGallery() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _selectedFile = pickedFile != null ? File(pickedFile.path) : null;
      });
    } catch (error) {
      print("Error picking image: $error");
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = 'profile_${widget.userId}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print("Error uploading image: $error");
      return '';
    }
  }

  updatePassword() async {
    if (_passwordController.text != userData['password']) {
      if (_passwordController.text.length < 6) {
        // Длина пароля слишком мала
      } else {
        FirebaseAuth auth = FirebaseAuth.instance;
        await auth.signOut();
        await auth.signInWithEmailAndPassword(
            email: userData['email'], password: oldPassword);
        await auth.currentUser!.updatePassword(_passwordController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'password': _passwordController.text,
        });
      }
    }
  }

  Future<void> saveUserData() async {
    try {
      // Показать диалог с индикатором загрузки
      setState(() {
        _isLoading = true;
      });

      await updatePassword();

      String imageUrl = userData['image'];
      if (_selectedFile != null) {
        imageUrl = await uploadImage(_selectedFile!);
      }

      // Обновление данных пользователя
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'fullname': _fullNameController.text,
        'phone': _phoneController.text,
        'image': imageUrl,
      });

      // Закрыть диалог после завершения операции
      Navigator.pop(context); // Закрыть диалог загрузки

      if (_passwordController.text.length < 6) {
        Toast.show('Длина пароля минимум 6 символов');
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(getIndex: 3)));
        // Вернуться на предыдущую страницу
      }
    } catch (error) {
      print("Error saving user data: $error");
      // Закрыть диалог при ошибке
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskFormatter = MaskTextInputFormatter(
      mask: '+7(###)-###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    return Scaffold(
      body: CustomPaint(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8.0,
                    color: Color.fromARGB(227, 74, 97, 87),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await selectImageGallery();
                              if (_selectedFile != null) {
                                setState(() {});
                              }
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage: _selectedFile != null
                                      ? FileImage(
                                          _selectedFile!) // Если выбран файл, отображаем его
                                      : NetworkImage(userData?['image'] ??
                                          ''), // Если userData и image существуют, показываем NetworkImage
                                  backgroundColor: Colors.grey.shade200,
                                  child: (_selectedFile == null &&
                                          userData?['image'] == null)
                                      ? const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.edit,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _fullNameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'ФИО',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _passwordController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _phoneController,
                            inputFormatters: [maskFormatter],
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Телефон',
                              hintText: '+7(945)-000-00-00',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: saveUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13.0, horizontal: 40.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Сохранить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF4A6157),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
