// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:carive/models/chat_model.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/chat_service.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    Key? key,
    required this.userImage,
    required this.userName,
    required this.userId,
    required this.fcmToken,
  });

  final String userImage;
  final String userName;
  final String userId;
  // ignore: prefer_typing_uninitialized_variables
  final fcmToken;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final chatService = ChatService();
  final auth = AuthService();
  final messageController = TextEditingController();
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  UserDatabaseService userDatabaseService = UserDatabaseService();
  final currentUser = AuthService().auth.currentUser;

  @override
  void initState() {
    super.initState();
    // Set the last message as read for the receiver
    String currentUserId = AuthService().auth.currentUser!.uid;
    DocumentReference chatReference = userCollectionReference
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.userId);

    // Check if the chat document exists before updating
    chatReference.get().then((chatSnapshot) {
      if (chatSnapshot.exists) {
        chatReference.update({'lastMessageRead': true});
      }
    }).catchError((error) {});
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScaffold(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: themeColorGreen,
            leading: Wrap(
              direction: Axis.vertical,
              alignment: WrapAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.userImage),
                ),
              ],
            ),
            title: Text(widget.userName),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(auth.auth.currentUser!.uid)
                  .collection("chats")
                  .doc(widget.userId)
                  .collection("messages")
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessageModel.fromSnapshot(doc))
                    .toList();

                // Group the messages by date
                final groupedMessages = groupBy(
                    messages,
                    (message) => DateFormat("dd MMM yyyy")
                        .format(message.time.toDate()));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      final date = groupedMessages.keys.elementAt(index);
                      final messagesForDate =
                          groupedMessages.values.elementAt(index);

                      // Build the date card
                      final dateCard = Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white
                            ),
                          ),
                        ),
                      );

                      // Build the message bubbles for the current date
                      final messageBubbles = messagesForDate.reversed
                          .map((message) => _buildMessageBubble(
                                message.senderId,
                                message.textMessage,
                                message.time,
                              ))
                          .toList();

                      return Column(
                        children: [
                          dateCard,
                          ...messageBubbles,
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: themeColorGrey,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: themeColorGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: themeColorGreen),
                      ),
                      hintText: "Type message here...",
                      hintStyle: TextStyle(color: themeColorblueGrey),
                    ),
                  ),
                ),
                wSizedBox10,
                CircleAvatar(
                  radius: 25,
                  backgroundColor: themeColorGreen,
                  child: IconButton(
                    onPressed: () async {
                      if (await isProfileCreated()) {
                        if (messageController.text != '') {
                          chatService.sendTextMessage(
                            auth.auth.currentUser!.uid,
                            widget.userId,
                            messageController.text.trim(),
                            widget.fcmToken,
                          );
                        } else {
                          showErrorDialogue(context, "Please type something",
                              "Cannot be empty");
                        }
                      } else {
                        showErrorDialogue(
                            context, "Create profie to chat", "CreateProfile");
                      }
                      messageController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    String senderId,
    String textMessage,
    Timestamp time,
  ) {
    final isCurrentUser = senderId == auth.auth.currentUser!.uid;
    final dateTime = DateFormat.jm().format(time.toDate());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isCurrentUser ? themeColorGrey : themeColorGreen,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textMessage,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateTime.toString(),
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isProfileCreated() async {
    if (currentUser != null) {
      final userData = await userDatabaseService.getUserData(currentUser!.uid);
      final data = userData.data() as Map<String, dynamic>?;

      if (data != null) {
        final name = data['name'] as String?;
        return name != null && name.isNotEmpty;
      }
    }
    return false;
  }
}
