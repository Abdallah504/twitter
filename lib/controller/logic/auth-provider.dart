import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter/view/screens/home-screen.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _person;  // Nullable user object

  User? get person => _person; // Getter for the user

  /// **Sign in with Google and store user data in Firestore**
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        _person = user; // Store user data in provider
        notifyListeners();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// **Save user data to Firestore**
  Future<void> _saveUserToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "username": user.displayName?.toLowerCase().replaceAll(" ", "") ?? "",
        "email": user.email ?? "",
        "profilePic": user.photoURL ?? "",
        "bio": "Hey there! I'm using this app.",
        "followers": [],
        "following": [],
      });
    }
  }

  /// **Sign Out**
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _person = null;
    notifyListeners();
  }
}
