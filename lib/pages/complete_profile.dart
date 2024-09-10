// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/widgets/alertbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullnameController = TextEditingController();
  bool isLoading = false; // Add loading state variable

  void checkValues() {
    String fullname = fullnameController.text.trim();
    if (fullname == '' || imageFile == null) {
      CustomSnackbar.show(context, 'Please fill all the fields', Colors.red);
    } else {
      uploadData();
    }
  }

  uploadData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profilepictures")
          .child(widget.userModel.uid.toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      String fullname = fullnameController.text.toString();

      widget.userModel.fullname = fullname;
      widget.userModel.profilepic = imageUrl;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userModel.uid)
          .set(widget.userModel.toJson())
          .then((value) {
        CustomSnackbar.show(context, 'Data Uploaded', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser,
                  )),
        );
      });
    } catch (e) {
      CustomSnackbar.show(context, 'Upload failed: $e', Colors.red);
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Profile Picture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text('Select from Gallery'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
        title: Text(
          "Complete Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: Icon(
                    (imageFile == null) ? Icons.person : null,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fullnameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator() // Show loading spinner
                  : CupertinoButton(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text('Submit'),
                      onPressed: () {
                        checkValues();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
