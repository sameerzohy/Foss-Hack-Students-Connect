import 'package:students_connect/widgets/message_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!.uid;
    final user = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: Text('User data not found'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('colleges')
              .doc('Chennai Institute of Technology')
              .collection('departments')
              .doc(userData['department'])
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No Messages'),
              );
            }

            final messages = snapshot.data!.docs;
            return ListView.builder(
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (cxt, index) {
                final chatMsg = messages[index].data() as Map<String, dynamic>;
                final nxtMsg = index + 1 < messages.length
                    ? messages[index + 1].data() as Map<String, dynamic>?
                    : null;
                final currUsr = chatMsg['userId'];
                final nxtUsr = nxtMsg != null ? nxtMsg['userId'] : null;
                final isSameUser = currUsr == nxtUsr;
                if (isSameUser) {
                  return MessageBubble.next(
                      message: chatMsg['text'], isMe: currUsr == currentUser);
                }
                return MessageBubble.first(
                    username: chatMsg['username'],
                    message: chatMsg['text'],
                    isMe: currUsr == currentUser);
              },
            );
          },
        );
      },
    );
  }
}
