import 'dart:developer';

import 'package:chat_application/data/models/user_model.dart';
import 'package:chat_application/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthRepository extends BaseRepository {

  Stream<User?> get authStateChanges  => auth.authStateChanges();

  Future<UserModel?> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());

      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw Exception("An account with the same email already exists");
      }
      final phoneNumberExists = await checkPhoneExists(formattedPhone);
      if (phoneNumberExists) {
        throw Exception("An account with the same phone already exists");
      }

      final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Failed to create User');
      }

      // Create a user object
      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: formattedPhone,
      );

      await saveUserData(user);
      return user;
    } catch (e, stackTrace) {
      log("Error in signUp: $e", stackTrace: stackTrace);
      throw e; // Ensure the exception is thrown
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('error checking email');
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final formattedPhoneNumber =
      phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());
      final querySnapshot = await firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: formattedPhoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking phone number: $e");
      return false;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        throw Exception('Failed to create User');
      }
      final userData = await getUserDaata(userCredential.user!.uid);
      return userData;

    } catch (e) {
      log("Error in signIn: $e");
      throw e; // Ensure the exception is thrown
    }
  }

  Future<void> singOut() async {
    await auth.signOut();
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection("users").doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  Future<UserModel> getUserDaata(String uid) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();
      if (!doc.exists) {
        throw Exception('User data not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}