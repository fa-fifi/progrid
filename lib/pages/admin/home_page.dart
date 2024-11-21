import 'package:flutter/material.dart';
import 'package:progrid/components/my_button.dart';
import 'package:progrid/models/user_information.dart';

// Standard Top Admin Home Page
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userInformation = UserInformation();

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(40),
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Admin Home Page",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Text("User ID: ${userInformation.userId}"),
            Text("Email: ${userInformation.email}"),
            Text("User Type: ${userInformation.userType}"),
            const SizedBox(height: 20),

            // logout button
            MyButton(
              onTap: UserInformation().logout,
              text: "Logout",
            ),
          ],
        )),
      ),
    );
  }
}
