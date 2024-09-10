import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  ChatRoomPage(
      {super.key,
      required this.targetuser,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          centerTitle: true,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.targetuser.profilepic.toString()),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.targetuser.fullname.toString(),
                style: TextStyle(color: Colors.white),
              )
            ],
          )),
      body: Column(
        children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Flexible(
                        child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Enter text'),
                    )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
