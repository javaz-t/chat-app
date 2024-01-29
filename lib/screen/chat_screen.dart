import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_mesages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for notification
  void  setUpPushNotification() async{
    final fcm =FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token =await fcm.getToken();
    print('token == $token');// token can use ti test the notification
    fcm.subscribeToTopic('chat');

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpPushNotification(); //init state cant be future
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('CHAT'),
        actions: [
          IconButton(onPressed:(){
            FirebaseAuth.instance.signOut();
          }, icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages()),

          NewMessages(),

        ],
      )
    );
  }
}
