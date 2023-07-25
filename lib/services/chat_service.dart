// ignore_for_file: non_constant_identifier_names

import 'package:carive/models/chat_model.dart';
import 'package:carive/services/firebase__notification_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");

  Future<void> sendTextMessage(
    String senderId,
    String receiverId,
    String message,
    String FCMToken,
  ) async {
    final senderChatCollectionReference =
        userCollectionReference.doc(senderId).collection("chats");
    final senderChatDocumentReference =
        senderChatCollectionReference.doc(receiverId);
    await senderChatDocumentReference.set(
      {
        'contactId': receiverId,
        'timeSent': DateTime.now(),
        'lastMessage': message,
        'lastMessageRead': true,
      },
    );
    final senderMessagesReference =
        senderChatDocumentReference.collection('messages');
    final senderMessageDocumentReference = senderMessagesReference.doc();
    final senderMessageId = senderMessageDocumentReference.id;

    final senderChatMessage = ChatMessageModel(
      messageId: senderMessageId,
      senderId: senderId,
      textMessage: message,
      time: Timestamp.now(),
    );

    await senderMessageDocumentReference.set(senderChatMessage.toSnapshot());

    final receiverChatCollectionReference =
        userCollectionReference.doc(receiverId).collection("chats");
    final receiverChatDocumentReference =
        receiverChatCollectionReference.doc(senderId);
    await receiverChatDocumentReference.set(
      {
        'contactId': senderId,
        'timeSent': DateTime.now(),
        'lastMessage': message,
        'lastMessageRead': false,
      },
    );
    final receiverMessagesReference =
        receiverChatDocumentReference.collection('messages');
    final receiverMessageDocumentReference = receiverMessagesReference.doc();
    final receiverMessageId = receiverMessageDocumentReference.id;

    final receiverChatMessage = ChatMessageModel(
      messageId: receiverMessageId,
      senderId: senderId,
      textMessage: message,
      time: Timestamp.now(),
    );

    await receiverMessageDocumentReference
        .set(receiverChatMessage.toSnapshot());

        
    final String senderName =
        (await userCollectionReference.doc(senderId).get()).get('name');

    FirebaseApi().sendNotification(
        FCMToken: FCMToken, message: message, title: senderName);
  }
}
