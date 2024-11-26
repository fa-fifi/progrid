import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:progrid/firebase_options.dart';
import 'package:progrid/models/tower_provider.dart';
import 'package:progrid/models/user_provider.dart';
import 'package:progrid/services/auth_wrapper.dart';
import 'package:progrid/utils/themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TowersProvider()),
      ],
      child: MaterialApp(
        title: 'Progrid',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
