import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseService({
    required this.auth,
    required this.firestore,
  });
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});
