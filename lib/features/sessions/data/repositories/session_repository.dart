import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_model.dart';

class SessionRepository {
  final FirebaseFirestore _firestore;

  SessionRepository(this._firestore);

  /// Returns a stream of sessions for a specific college.
  /// Filters out deleted sessions.
  Stream<List<Session>> getSessionsStream(String collegeId) {
    return _firestore
        .collection('colleges')
        .doc(collegeId)
        .collection('sessions')
        .where('isDeleted', isEqualTo: false)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
    });
  }

  /// Adds a new session.
  /// If [isActive] is true, it deactivates all other sessions for this college.
  Future<void> addSession(String collegeId, Session session) async {
    // 1. Backend Validation
    if (session.endDate.isBefore(session.startDate)) {
      throw Exception('End date must be after start date');
    }

    final sessionsRef = _firestore.collection('colleges').doc(collegeId).collection('sessions');

    // 2. Prepare Audit Fields
    final sessionData = session.toMap();
    sessionData['createdAt'] = FieldValue.serverTimestamp();
    sessionData['updatedAt'] = FieldValue.serverTimestamp();
    // createdBy is assumed to be set in the model passed in, logic usually in provider/service

    // 3. Transaction
    return _firestore.runTransaction((transaction) async {
      // If we are activating this session, we must deactivate others.
      // Since we can't query inside transaction efficiently in client SDK for "all active",
      // we rely on a pre-fetch or just best-effort read. 
      // STRICT PATTERN:
      // We will query for currently active sessions first (optimistic), then lock them in transaction.
      
      if (session.isActive) {
         // Query for current active session(s) - usually just one.
         // Note: This query happens OUTSIDE the transaction on the Query object, 
         // but we then GET the docs inside.
         final activeQuerySnapshot = await sessionsRef
             .where('isActive', isEqualTo: true)
             .where('isDeleted', isEqualTo: false)
             .get();
        
         for (var doc in activeQuerySnapshot.docs) {
           // Read it into transaction to lock it
           final freshSnap = await transaction.get(doc.reference);
           if (freshSnap.exists && (freshSnap.data() as Map)['isActive'] == true) {
             transaction.update(doc.reference, {
               'isActive': false, 
               'updatedAt': FieldValue.serverTimestamp()
             });
           }
         }
      }

      // Add the new session
      final newDocRef = sessionsRef.doc(); 
      transaction.set(newDocRef, sessionData);
    });
  }

  /// Updates an existing session.
  /// If [isActive] is set to true, it deactivates all other sessions.
  Future<void> updateSession(String collegeId, Session session) async {
     // 1. Backend Validation
    if (session.endDate.isBefore(session.startDate)) {
      throw Exception('End date must be after start date');
    }

    final sessionsRef = _firestore.collection('colleges').doc(collegeId).collection('sessions');
    final sessionRef = sessionsRef.doc(session.id);

    return _firestore.runTransaction((transaction) async {
      // If setting to active, deactivate others
      if (session.isActive) {
         final activeQuerySnapshot = await sessionsRef
             .where('isActive', isEqualTo: true)
             .where('isDeleted', isEqualTo: false)
             .get();

        for (var doc in activeQuerySnapshot.docs) {
          if (doc.id == session.id) continue; // Skip self

          final freshSnap = await transaction.get(doc.reference);
          if (freshSnap.exists && (freshSnap.data() as Map)['isActive'] == true) {
             transaction.update(doc.reference, {
               'isActive': false, 
               'updatedAt': FieldValue.serverTimestamp()
             });
          }
        }
      }

      // Update the target session
      final data = session.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      // Remove fields we don't want to overwrite blindly if they rely on server timestamp, 
      // strictly speaking toMap has DateTime, but FieldValue is better for updates.
      // But we mapped it.
      
      transaction.update(sessionRef, data);
    });
  }

  /// Soft deletes a session.
  Future<void> deleteSession(String collegeId, String sessionId) async {
    await _firestore
        .collection('colleges')
        .doc(collegeId)
        .collection('sessions')
        .doc(sessionId)
        .update({
          'isDeleted': true,
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
