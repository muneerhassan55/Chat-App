// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/sign_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/alertbox.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Flag to manage loading state

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      CustomSnackbar.show(context, "Please fill all fields", Colors.red);
    } else {
      setState(() {
        isLoading = true; // Show loading spinner
      });
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      CustomSnackbar.show(context, "Login Successful!", Colors.green);
    } on FirebaseAuthException catch (e) {
      CustomSnackbar.show(context, e.code.toString(), Colors.red);
    }

    setState(() {
      isLoading = false; // Hide loading spinner
    });

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromJson(userData.data() as Map<String, dynamic>);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  userModel: userModel,
                  firebaseUser: credential!.user!,
                )),
      );
      // Perform navigation or further action after login success
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
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // To hide password input
              ),
              SizedBox(
                height: 30,
              ),
              CupertinoButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child:
                      isLoading // Show spinner or 'Login' text based on isLoading
                          ? CircularProgressIndicator(
                              color: Colors.blue,
                            )
                          : Text('Login'),
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () {
                          checkValue(); // Call login function
                        }),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
