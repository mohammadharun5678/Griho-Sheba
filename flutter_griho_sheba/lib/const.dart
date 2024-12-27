import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_griho_sheba/Home_page.dart';

String SavedUsername = '';
String savedEmail = '';
String savedPhone = '';

class FirebaseRelated {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> fetchServiceDetails() async {
    try {
      // Fetch the service details from Firebase
      final DatabaseEvent event =
          await _databaseReference.child('serviceDetails').once();
      final Map<String, dynamic> serviceDetails =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      return serviceDetails;
    } catch (e) {
      print('Error fetching data: $e');
      return {}; // Return an empty map if there's an error
    }
  }

  // Sign Up User
  Future<void> signUpUser(String email, String password, BuildContext context,
      String userName, String phoneNoo) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted && userCredential.user != null) {
        // Save the email and username to the database
        await saveUsernameToDatabase(
          userCredential.user!.uid,
          email,
          userName,
          phoneNoo,
        );

        showSnackBar(context, "Sign Up Complete!");
        SavedUsername = userName;
        savedEmail = email;
        savedPhone = phoneNoo;
        print('Sign up successful for email: $email');
        if (context.mounted) {
          navigateToPage(context, HomePage());
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        print('Firebase Auth Exception: ${e.code}, ${e.message}');
        if (e.code == 'email-already-in-use') {
          showSnackBar(context, "Email Already In Use.");
        } else if (e.code == 'invalid-email') {
          showSnackBar(context, "Invalid Email");
        } else if (e.code == 'weak-password') {
          showSnackBar(context, 'Password is too weak.');
        } else {
          showSnackBar(context, 'Sign up failed: ${e.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> fetchUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DatabaseReference userRef =
          _databaseReference.child('Users').child(currentUser.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        SavedUsername = userData['username'] ?? '';
        savedEmail = userData['email'] ?? '';
        savedPhone = userData['phoneno'] ?? '';
      } else {
        print("No user data found.");
      }
    }
  }

  //Sign In User
  Future<void> signInUser(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted && userCredential.user != null) {
        showSnackBar(context, "Sign In Complete");

        if (context.mounted) {
          navigateToPage(context, HomePage());
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          showSnackBar(context, "User Not Found");
        } else if (e.code == 'invalid-email') {
          showSnackBar(context, "Invalid Email");
        } else {
          showSnackBar(context, 'Sign in failed: ${e.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Try Again");
      }
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        showSnackBar(context, "An Email has been sent!");
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found') {
          showSnackBar(context, "User Not Found");
        } else if (e.code == 'invalid-email') {
          showSnackBar(context, "Invalid Email");
        } else {
          showSnackBar(context, 'Error: ${e.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Something is wrong");
      }
    }
  }

  Future<void> saveUsernameToDatabase(
      String userId, String email, String userName, String phone) async {
    await _databaseReference.child('Users').child(userId).set({
      'email': email,
      'username': userName,
      'phoneno': phone,
    });
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    ),
  );
}

void navigateToPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
