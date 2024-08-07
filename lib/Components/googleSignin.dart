import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GooglesigninProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<Map<String, String>?> googleLogin() async {
    try {
      // Sign out from Google account to ensure account selection
      await googleSignIn.signOut();

      // Start the sign-in process
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Sign-in failed or was cancelled by the user
      }
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credentials);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          // Create user data in Firestore if not exists
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'fullName': '',
            'email': firebaseUser.email,
            'phone': '',
            'Address': '',
            'coordinates': {},
          });
        }
      }

      notifyListeners();

      return {
        'email': googleUser.email,
        'uid': firebaseUser?.uid ?? '',
      };
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null; // Sign-in failed
    }
  }
}
