import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageEditingController = TextEditingController();

  @override
  void dispose() {
    _messageEditingController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final msg = _messageEditingController.text;
    // print(msg);

    if (msg.trim().isEmpty) {
      _messageEditingController.clear();
      return;
    }

    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    // print(userData['name']);
    // print('-----');

    FirebaseFirestore.instance
        .collection('colleges')
        .doc('Chennai Institute of Technology')
        .collection('departments')
        .doc(userData['department'])
        .collection('chat')
        .add({
      'text': msg,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData['name']
    });
    _messageEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 5,
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageEditingController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a Message..'),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
