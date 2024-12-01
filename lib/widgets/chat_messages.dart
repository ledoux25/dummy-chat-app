import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser =  FirebaseAuth.instance.currentUser! ;
    return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('message').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData == false || snapshot.data!.docs.isEmpty || snapshot.hasError) {
              return const Center(
                child :Text("No date Found")
              );
            }

            final loadedMessages = snapshot.data!.docs;
            return ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(bottom: 40, left: 13,right: 13),
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                final chatMessages = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length ? loadedMessages[index+1].data() : null ;

                final currentMesageUsername = chatMessages['userId'];
                final nextMesageUsername = nextChatMessage != null ? nextChatMessage['userId'] : null;


                final nextUserIsSame = currentMesageUsername == nextMesageUsername;
             if(nextUserIsSame){
              return MessageBubble.next(message: chatMessages['text'], isMe: authenticatedUser.uid == currentMesageUsername);
             }else{
              return MessageBubble.first(userImage: chatMessages['userImage'], username: chatMessages['username'], message: chatMessages['text'], isMe: authenticatedUser.uid == currentMesageUsername);
             }
            },);
          },
        );
  }
}