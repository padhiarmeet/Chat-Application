import 'package:chat_application/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository extends BaseRepository {
  Future<void> saveToken(String userId, String token) async {
    await firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  Future<String?> getToken(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return doc.data()?['fcmToken'];
  }

  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String message,
    String? title,
  }) async {
    final receiverToken = await getToken(receiverId);
    if (receiverToken == null) return;

    // Call your Firebase Cloud Function to send the notification
    // You'll need to implement this cloud function
  }
}