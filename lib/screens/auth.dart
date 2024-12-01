import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var isUplaoding = false;

  var _isLogin = true;

  void _submit() async {
    final isvalid = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (!_isLogin && _selectedImage == null || !isvalid) {
      return;
    }

    try {
      setState(() {
        isUplaoding = true;
      });
      if (_isLogin) {
        final UserCredential userCredential =
            await firebase.signInWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

      // final storageRef = FirebaseStorage.instance.ref().child("user_images").child('${userCredentials.user!.uid}.jpg');

      // await storageRef.putFile(_selectedImage!);

      // final imageUrl = await storageRef.getDownloadURL();
      // print(imageUrl);

      FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
        'userName' : _enteredUsername,
        'email' : _enteredEmail,
        'image_url' : 'https://res.cloudinary.com/ddqkpyo5u/image/upload/v1732030549/5c7729ab-0c5f-459d-8d0a-7c36572fdfe5.png' 
      });
      }

    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed')));

          setState(() {
            isUplaoding = false;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, left: 20, right: 20, bottom: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) =>
                                    _selectedImage = pickedImage,
                              ),
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 4) {
                                  return 'Please enter a longer username';
                                }


                                return null;
                              },
                              onSaved: (newValue) => _enteredUsername = newValue!,
                              decoration: const InputDecoration(
                                  labelText: "UserName"),
                                  enableSuggestions: false,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                            ),
                            if(!_isLogin)
                                                        TextFormField(
                              validator: (value) {
                                
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains("@")) {
                                  return 'Please enter a valid email adress';
                                } 'Please enter a longer username';
                                

                                return null;
                              },
                              onSaved: (newValue) => _enteredEmail = newValue!,
                              decoration: const InputDecoration(
                                  labelText: "Email Adress"),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.trim().length < 5) {
                                  return 'Please enter a longer password';
                                }

                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredPassword = newValue!;
                              },
                              decoration:
                                  const InputDecoration(labelText: "Password"),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              obscureText: true,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if(isUplaoding)
                            const CircularProgressIndicator(),
                            if(!isUplaoding)
                            ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? "Login" : "Signup")),
                            if(!isUplaoding)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'Alrady Have account'))
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
