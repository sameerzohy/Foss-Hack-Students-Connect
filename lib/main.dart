import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:students_connect/screens/get_inputs.dart';
import 'package:students_connect/teachers/home_screen.dart';
import 'firebase_options.dart';
import 'package:students_connect/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:students_connect/screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (cxt, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      var userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      print(userData);

                      if (userData.containsKey('role') &&
                          userData['role'] == 'teacher') {
                        return TeacherHomeScreen();
                      }
                      return HomeScreen();
                    } else {
                      return GetInputs();
                    }
                  },
                );
              }
              return AuthScreen();
            }));
  }
}
