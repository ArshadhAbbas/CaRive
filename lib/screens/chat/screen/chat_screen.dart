import 'package:carive/models/user_model.dart';
import 'package:carive/screens/chat/chat_room_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/chat_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  late Stream<QuerySnapshot> chatsStream;
  final auth = AuthService();

  @override
  void initState() {
    super.initState();
    // Retrieve the chats for the current user
    String currentUserId = auth.auth.currentUser!.uid;
    chatsStream = userCollectionReference
        .doc(currentUserId)
        .collection('chats')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: chatsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<DocumentSnapshot> chatDocuments = snapshot.data!.docs;

            if (chatDocuments.isEmpty) {
              return Center(
                child: Text(
                  'No chats found.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: chatDocuments.length,
              itemBuilder: (context, index) {
                DocumentSnapshot chatDocument = chatDocuments[index];
                String contactId = chatDocument.id;

                return StreamBuilder<DocumentSnapshot>(
                  stream: userCollectionReference.doc(contactId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    UserModel chatUser =
                        UserModel.fromDocumentSnapshot(snapshot.data!);

                    Timestamp? timeSent =
                        chatDocument.get('timeSent') as Timestamp?;
                    String lastMessage = chatDocument.get('lastMessage');
                    String timeSentText = '';

                    if (timeSent != null) {
                      DateTime dateTime = timeSent.toDate();
                      DateTime currentDate = DateTime.now();
                      DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                      DateFormat timeFormat = DateFormat('hh:mm a');
                      String formattedDate = dateFormat.format(dateTime);
                      String formattedTime = timeFormat.format(dateTime);

                      if (dateTime.year == currentDate.year &&
                          dateTime.month == currentDate.month &&
                          dateTime.day == currentDate.day) {
                        // If the chat occurred today, show only the time
                        timeSentText = formattedTime;
                      } else {
                        // If the chat occurred on any other date, show the full date
                        timeSentText = formattedDate;
                      }
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(chatUser.image),
                      ),
                      title: Text(
                        chatUser.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: TextStyle(color: themeColorblueGrey),
                      ),
                      trailing: Text(
                        timeSentText,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        await ChatService().markChatAsRead(
                          auth.auth.currentUser!.uid,
                          contactId,
                        );

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            userImage: chatUser.image,
                            userName: chatUser.name,
                            userId: chatUser.id,
                          ),
                        ));
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
