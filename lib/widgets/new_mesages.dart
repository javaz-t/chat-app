import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController = TextEditingController();

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
   //remove keyboard
    // sent to firebase
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await  FirebaseFirestore.instance.collection('users')
        .doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "userName":userData.data()!['user_name'],
      "userImage":userData.data()!['image_url']
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 15, bottom: 15),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(hintText: 'Send message....'),
          )),
          IconButton(onPressed: _submitMessage, icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
