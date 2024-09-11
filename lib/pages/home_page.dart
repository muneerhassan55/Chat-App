import 'dart:convert';

import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:chat_app/pages/firebase_helper.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
        title: Text(
          'Chat App',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatrromsnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatrromsnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromJson(
                            chatrromsnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;
                        List<String> participantskeys =
                            participants.keys.toList();
                        participantskeys.remove(widget.userModel.uid);
                        return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantskeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatRoomPage(
                                                      targetuser: targetUser,
                                                      chatRoom: chatRoomModel,
                                                      userModel:
                                                          widget.userModel,
                                                      firebaseUser: widget
                                                          .firebaseUser)));
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUser.profilepic.toString()),
                                    ),
                                    title: Text(targetUser.fullname.toString()),
                                    subtitle: Text(
                                        chatRoomModel.lastMessage.toString()),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      });
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return Center(child: Text('No chats'));
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser)));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
