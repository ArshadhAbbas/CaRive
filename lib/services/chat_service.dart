import 'package:carive/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");

  Future<void> sendTextMessage(
    String senderId,
    String receiverId,
    String message,
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
        'didRead': true
      },
    );
    final senderMessagesReference =
        senderChatDocumentReference.collection('messages');
    final senderMessageDocumentReference = senderMessagesReference.doc();
    final senderMessageId = senderMessageDocumentReference.id;

    final senderChatMessage = ChatMessage(
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
        'didRead': false,
      },
    );
    final receiverMessagesReference =
        receiverChatDocumentReference.collection('messages');
    final receiverMessageDocumentReference = receiverMessagesReference.doc();
    final receiverMessageId = receiverMessageDocumentReference.id;

    final receiverChatMessage = ChatMessage(
      messageId: receiverMessageId,
      senderId: senderId,
      textMessage: message,
      time: Timestamp.now(),
    );

    await receiverMessageDocumentReference
        .set(receiverChatMessage.toSnapshot());
  }

  Future<void> markChatAsRead(String senderId, String receiverId) async {
    final receiverChatCollectionReference =
        userCollectionReference.doc(receiverId).collection("chats");
    final receiverChatDocumentReference =
        receiverChatCollectionReference.doc(senderId);

    await receiverChatDocumentReference.update({'didRead': true}).then((value) {
      print('Chat marked as read successfully');
    }).catchError((error) {
      print('Error marking chat as read: $error');
    });
  }
}
