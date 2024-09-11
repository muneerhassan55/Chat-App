import 'package:chat_app/main.dart';
import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController messageContrller = TextEditingController();

  void sendMessage() {
    String msg = messageContrller.text.trim();
    messageContrller.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageid)
          .set(newMessage.toJson());
      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatroomid)
          .set(widget.chatRoom.toJson());
      print('message send');
    }
  }

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
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(widget.chatRoom.chatroomid)
                    .collection("messages")
                    .orderBy('createdon', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromJson(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                widget.userModel.uid)
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'An error occured please check your internet connection'));
                    } else {
                      return Center(child: Text('Say Hi to Your new friend'));
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          )),
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
                      controller: messageContrller,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Enter text'),
                    )),
                    IconButton(
                        onPressed: () {
                          sendMessage();
                        },
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
