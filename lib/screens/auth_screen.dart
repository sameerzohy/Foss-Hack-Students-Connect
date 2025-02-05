import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String username = '';

  void onSubmit() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    try {
      if (!_isLogin) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        await userCredential.user?.sendEmailVerification();
        // print();
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'name': username, 'email': email});
      } else {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message!,
          ),
        ),
      );
    }
  }

  bool _isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height, // Full screen height
          alignment: Alignment.center, // Center the content vertically
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centering
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: Card(
                  elevation: 5, // Adding some shadow for better UI
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Let it take only required height
                        children: [
                          if (_isLogin)
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 79, 78, 78),
                              ),
                            ),
                          if (!_isLogin)
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 79, 78, 78),
                              ),
                            ),
                          if (!_isLogin)
                            const SizedBox(
                              height: 20,
                            ),
                          if (!_isLogin)
                            TextFormField(
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                label: Text('Username'),
                                hintText: 'Enter your username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    width: 1.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      20), // Same or different radius
                                  borderSide: const BorderSide(
                                      width: 2.0,
                                      color: Colors
                                          .blue), // Change color & width when focused
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'enter a valid username';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                username = value!;
                              },
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              label: const Text('Email Address'),
                              hintText: 'Enter your email..',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Same or different radius
                                borderSide: const BorderSide(
                                    width: 2.0,
                                    color: Colors
                                        .blue), // Change color & width when focused
                              ),
                            ),
                            // maxLength: 50,
                            validator: (value) {
                              if (value == null ||
                                  !value.contains('@') ||
                                  value.trim().isEmpty) {
                                return 'Enter a valid email Address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              email = value!;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (!_isLogin)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      label: const Text('OTP'),
                                      hintText: 'Enter OTP..',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                          width: 1.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20), // Same or different radius
                                        borderSide: const BorderSide(
                                            width: 2.0,
                                            color: Colors
                                                .blue), // Change color & width when focused
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Verify OTP',
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                ),
                              ],
                            ),
                          if (!_isLogin) const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Password'),
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Same or different radius
                                borderSide: const BorderSide(
                                    width: 2.0,
                                    color: Colors
                                        .blue), // Change color & width when focused
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Enter a Strong Password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              password = value!;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: onSubmit,
                            child: _isLogin ? Text('Sign in') : Text('Sign up'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _form.currentState!.reset();
                                });
                              },
                              child: _isLogin
                                  ? Text('Create new Account')
                                  : Text('Already have an account?')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
