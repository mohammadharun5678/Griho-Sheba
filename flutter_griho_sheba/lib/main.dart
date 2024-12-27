import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_griho_sheba/Home_page.dart';
import 'package:flutter_griho_sheba/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Initialize Firebase for Web with databaseURL
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB86BaJIMQVv5B8t-pzMrONgjf6wdYIHCM",
          authDomain: "griho-sheba.firebaseapp.com",
          databaseURL: "https://griho-sheba-default-rtdb.firebaseio.com",
          projectId: "griho-sheba",
          storageBucket: "griho-sheba.appspot.com",
          messagingSenderId: "957742934687",
          appId: "1:957742934687:web:95a174e4cd57edbedf50aa",
          measurementId: "G-XN7S0MKKJ2"),
    );
  } else {
    // Initialize Firebase for Android and iOS (native)
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseRelated _firebaseRelated = FirebaseRelated();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _firebaseRelated.fetchUserData();
    setState(() {
      // The UI will update once the user data is retrieved and assigned.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
