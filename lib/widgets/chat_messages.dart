import 'dart:io';


import 'package:chat_app/widgets/bubble_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('no msg '));
          }
          if (chatSnapshot.hasError) {
            return const Center(child: Text('something went wrong... '));
          }
          final loadedMessages = chatSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 30 ,left: 25,right: 15),
            reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();
          /*    print('loasded msg lenth :${loadedMessages.length}');//no of msg s
              print('index = ${index.toString()}');
                print('loadedMessages[index].data()[text]= ${loadedMessages[index].data()['text']}'); //print msg
              print('loadedMessages[index]= ${loadedMessages[index]}');//Instance of '_JsonQueryDocumentSnapshot'
              print('loadedMessages[index].data()= ${loadedMessages[index].data()}'); //{createdAt: Timestamp(), userImage: , text: Hiii, userName:, userId: }*/
              final nextChatMessage = index + 1 <loadedMessages.length ?loadedMessages[index+1].data():null;
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId = nextChatMessage != null ? nextChatMessage['userId']:null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if(nextUserIsSame){
                return MessageBubble.next(message: chatMessage['text'], isMe: authenticatedUser!.uid==currentMessageUserId);
              }else{
                return MessageBubble.first(userImage: chatMessage['userImage'], username: chatMessage['userName'], message: chatMessage['text'], isMe: authenticatedUser!.uid==currentMessageUserId);
              }



              return  Text(loadedMessages[index].data()['text']
                );
              });
        });
  }
}
