import 'package:chat_app/screen/auath.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main()async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 await FirebaseAppCheck.instance.activate();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home:StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){
       if(snapshot.connectionState==ConnectionState.waiting){
         return const SplashScreen();
       }
        // token from the backend will store in the device ,if token is there it will directly go to the chat page
        if(snapshot.hasData){
          return const ChatScreen();
        }
        return const AuthScreen();
      })


    );
  }
}
