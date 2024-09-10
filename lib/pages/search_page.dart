import 'dart:math';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromJson(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
      print('Chat room alreeady created');
    } else {
      ChatRoomModel newChatroom =
          ChatRoomModel(chatroomid: uuid.v1(), lastMessage: "", participants: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      });
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toJson());
      chatRoom = newChatroom;
      print('New Chat room created');
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                label: Text('Email'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {});
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: searchController.text)
                    .where('email', isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchUser = UserModel.fromJson(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchUser);
                            if (chatRoomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          targetuser: searchUser,
                                          chatRoom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser)));
                            }
                          },
                          trailing: Icon(Icons.keyboard_arrow_right),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchUser.profilepic!),
                          ),
                          title: Text(searchUser.fullname.toString()),
                          subtitle: Text(searchUser.email.toString()),
                        );
                      } else {
                        return Text('No results found');
                      }
                    } else if (snapshot.hasError) {
                      return Text('An error occured');
                    } else {
                      return Text('No results found');
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                })
          ],
        ),
      ),
    );
  }
}
