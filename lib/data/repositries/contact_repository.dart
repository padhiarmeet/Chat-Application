import 'package:chat_application/data/models/user_model.dart';
import 'package:chat_application/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisterContacts() async {
    try {
      // Check if permission is granted
      bool isGranted = await FlutterContacts.requestPermission();
      if (!isGranted) {
        print("Permission denied!");
        return [];
      }

      // Get device contacts with phone numbers
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

// Extract phone numbers and process them to get last 10 digits
      final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) {
        // Get full phone number with only digits
        String fullNumber = contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');

        // Extract last 10 digits
        String last10Digits = fullNumber.length > 10
            ? fullNumber.substring(fullNumber.length - 10)
            : fullNumber;

        return {
          'name': contact.displayName,
          'phoneNumber': fullNumber,
          'last10Digits': last10Digits,
          'photo': contact.photo,
        };
      })
          .toList();

      print("Device Contacts: $phoneNumbers");

// Get all users from Firestore
      final userSnapshot = await firestore.collection('users').get();
      final registeredUsers =
      userSnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      print("-----Registered Users: $registeredUsers");

// Match users with registered users using last 10 digits
      final matchContacts = phoneNumbers.where((contact) {
        final contactLast10 = contact['last10Digits'];

        print('-----------------Phone Number: ${contact['phoneNumber']}, Last 10: $contactLast10');

        return registeredUsers.any((user) {
          // Extract last 10 digits from user's phone number
          String userNumber = user.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          String userLast10 = userNumber.length > 10
              ? userNumber.substring(userNumber.length - 10)
              : userNumber;

          // Compare last 10 digits and check not current user
          return userLast10 == contactLast10 && user.uid != currentUserId;
        });
      }).map((contact) {
        final contactLast10 = contact['last10Digits'];

        // Find matching user based on last 10 digits
        final registeredUser = registeredUsers.firstWhere((user) {
          String userNumber = user.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          String userLast10 = userNumber.length > 10
              ? userNumber.substring(userNumber.length - 10)
              : userNumber;

          return userLast10 == contactLast10;
        });

        return {
          'id': registeredUser.uid,
          'name': contact['name'],
          'phoneNumber': contact['phoneNumber'],
          'photo': contact['photo']
        };
      }).toList();

      print("----------------------------Matched Contacts: $matchContacts");

      return matchContacts;
    } catch (e) {
      print('Error getting registered users: $e');
      return [];
    }
  }
}