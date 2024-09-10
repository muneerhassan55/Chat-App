// ignore_for_file: prefer_const_constructors

import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/complete_profile.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/widgets/alertbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  bool isLoading = false; // Flag to manage loading state

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = confirmpasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      CustomSnackbar.show(context, "Please fill all fields", Colors.red);
    } else if (password != cpassword) {
      CustomSnackbar.show(context, "Passwords don't match", Colors.orange);
    } else {
      setState(() {
        isLoading = true; // Show loading spinner
      });
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      CustomSnackbar.show(context, "Sign Up Successful!", Colors.green);
    } on FirebaseAuthException catch (e) {
      CustomSnackbar.show(context, e.code.toString(), Colors.red);
      setState(() {
        isLoading = false; // Hide loading spinner on error
      });
      return;
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toJson())
          .then((value) {
        CustomSnackbar.show(
            context, "User Created Successfully!", Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CompleteProfile(
                  userModel: newUser, firebaseUser: credential!.user!)),
        );
      });
      setState(() {
        isLoading = false; // Hide loading spinner on success
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chat App',
                style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmpasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 30),
              CupertinoButton(
                color: Theme.of(context).colorScheme.secondary,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.blue)
                    : Text('Sign Up'),
                onPressed: isLoading
                    ? null // Disable button while loading
                    : checkValue,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
