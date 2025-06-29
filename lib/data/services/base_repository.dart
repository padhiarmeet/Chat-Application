import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class BaseRepository {

  final FirebaseAuth auth= FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;

  String get uid => currentUser?.uid ?? "";
  bool get isAuthenticated =>currentUser != null;
  
}