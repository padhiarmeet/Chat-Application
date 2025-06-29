import 'package:chat_application/data/models/chat_message.dart';
import 'package:chat_application/data/models/chat_room_model.dart';
import 'package:chat_application/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'notification_repository.dart';


class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection('chatRooms');
  CollectionReference getChatRoomMessages(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).collection('messages');
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUserId, String otherUserId) async {
    // Prevent creating a chat room with yourself
    if (currentUserId == otherUserId) {
      throw Exception("Cannot create a chat room with yourself");
    }

    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join("_");

    final roomDoc = await _chatRooms.doc(roomId).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }

    final currentUserData =
        (await firestore.collection("users").doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firestore.collection("users").doc(otherUserId).get()).data()
            as Map<String, dynamic>;
    final participantsName = {
      currentUserId: currentUserData['fullName']?.toString() ?? "",
      otherUserId: otherUserData['fullName']?.toString() ?? "",
    };

    final newRoom = ChatRoomModel(
        id: roomId,
        participants: users,
        participantsName: participantsName,
        lastReadTime: {
          currentUserId: Timestamp.now(),
          otherUserId: Timestamp.now(),
        });

    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String reciverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    //batch
    final batch = firestore.batch();

    //get message sub collection

    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();

    await _notificationRepository.sendNotification(
      senderId: senderId,
      receiverId: reciverId,
      message: content,
    );


    //chatmessage

    final message = ChatMessage(
        id: messageDoc.id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: reciverId,
        type: type,
        status: MessageStatus.sent,
        content: content,
        timestamp: Timestamp.now(),
        readBy: [senderId]);


    //add message to collection
    batch.set(messageDoc, message.toMap());

    //update chatRoom
    batch.update(_chatRooms.doc(chatRoomId), {
      'lastMessage': content,
      'lastMessageSenderId': senderId,
      'lastMessageTime': message.timestamp,
    });
    await batch.commit();
  }

  //a -> b
  Stream<List<ChatMessage>> getMessages(String chatRoomId,
      {DocumentSnapshot? lastDocument}) {
    var query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  Future<List<ChatMessage>> getMoreMessages(String chatRoomId,
      {required DocumentSnapshot lastDocument}) async {
    final query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapshot = await query.get();

    return snapshot.docs.map((e) => ChatMessage.fromFirestore(e)).toList();
  }

  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _chatRooms
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => ChatRoomModel.fromFirestore(e),
              )
              .toList(),
        );
  }

  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessages(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markMessageAsRead(String chatRoomId, String userID) async {
    try {
      final batch = firestore.batch();

      //to get all unread messages

      final unreadMessages = await getChatRoomMessages(chatRoomId)
          .where('receiverId', isEqualTo: userID)
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .get();

      print(
          '---------------------------------found ${unreadMessages.docs.length} unread messages');

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userID]),
          'status': MessageStatus.read.toString()
        });
      }
      await batch.commit();
    } catch (e) {
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$e');
    }
  }

  Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return {
        'isOnline': data?['isOnline'] ?? false,
        'lastSeen': data?['lastSeen'],
      };
    });
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await firestore.collection("users").doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

    Future<void> updateTypingStatus(
      String chatRoomId, String userId, bool isTyping) async {
    try {
      final doc = await _chatRooms.doc(chatRoomId).get();
      if (!doc.exists) {
        print("chat room does not exist");
        return;
      }
      await _chatRooms.doc(chatRoomId).update({
        'isTyping': isTyping,
        'typingUserId': isTyping ? userId : null,
      });
    } catch (e) {
      print("error updating typing status");
    }
  }

  Stream<Map<String, dynamic>> getTypingStatus(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return {
          'isTyping': false,
          'typingUserId': null,
        };
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        "isTyping": data['isTyping'] ?? false,
        "typingUserId": data['typingUserId'],
      };
    });
  }


  final NotificationRepository _notificationRepository;

  ChatRepository({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

}
