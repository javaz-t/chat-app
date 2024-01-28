import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? _selectedImage;
  bool _isAuthenticating = false; //used to show loading
  bool _isLogged = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUserName = '';
  final _form = GlobalKey<FormState>();

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    //for dp image
    if (!_isLogged && _selectedImage == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogged) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        //sign Up
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        //uploading image to firebase
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_imge') //folder creating inside firebase
            .child('${userCredential.user!.uid}.jpg');
        //upload it
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print('image Url : $imageUrl');
       await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set( {
          "user_name":_enteredUserName,
          "email":_enteredEmail,
          "image_url":imageUrl
        });
      }
      //handles error from sign up and login process
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isAuthenticating = false;
      });
      if (error.code == 'email-already-in-use') {
        // code to show it
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication Faild")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height:_isLogged==true?100:20,
            ),
            Image.asset('assets/images/chat_logo.png', height:_isLogged==true?200:100),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                margin: EdgeInsets.all(10),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            if (!_isLogged)
                              UserImagePicker(
                                onPickIMage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            if(!_isLogged)
                            TextFormField(
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length<4) {
                                  return 'user name must be atleast 4 character';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUserName = value!;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'user name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'enter a valid email addresss';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 8) {
                                  return ' not good';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                              decoration: InputDecoration(
                                labelText: 'password',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(_isLogged == true
                                      ? 'Log In'
                                      : 'Sign up')),
                            if (_isAuthenticating) CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogged = !_isLogged;
                                    });
                                  },
                                  child: Text(_isLogged == true
                                      ? 'Create an Account'
                                      : 'Alredy have an account'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
