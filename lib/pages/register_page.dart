import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:progrid/components/my_alert.dart';
import 'package:progrid/components/my_button.dart';
import 'package:progrid/components/my_loader.dart';
import 'package:progrid/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  // toggle to login page
  final void Function()? onTapSwitchPage;

  const RegisterPage({
    super.key,
    required this.onTapSwitchPage,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // register user
  Future<void> register() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: MyLoadingIndicator(),
      ),
    );

    // make sure passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const MyAlert(
          title: "Registration Error",
          content: "Passwords Don't Match",
        ),
      );
      return;
    }

    // create the user
    try {
      UserCredential credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pop(context);
      String userId = credentials.user!.uid;

      // save user data to firestore database
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text,
        'uid': userId,
        'type': 'engineer',
      });

      showDialog(
        context: context,
        builder: (context) => const MyAlert(
          title: "Registration Successful",
          content: "User Registered and Data Saved to Firestore",
        ),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => MyAlert(
          title: "Registration Error",
          content: e.message ?? "An unknown error occurred.",
        ),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20), // padding inside the box
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // welcome text
                const Text(
                  'Register Here!',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  hintText: 'email',
                  obscureText: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  hintText: 'password',
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  hintText: 'confirm password',
                  obscureText: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 10),

                // log in button
                MyButton(
                  onTap: register,
                  text: 'Register',
                  height: 40,
                ),
                const SizedBox(height: 14),

                // link to login page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTapSwitchPage,
                      child: Text(
                        "Login Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
