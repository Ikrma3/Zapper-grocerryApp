import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GooglesigninProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<String?> googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null)
        return null; // Sign-in failed or was cancelled by the user
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credentials);
      notifyListeners();
      return googleUser.email;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null; // Sign-in failed
    }
  }
}
