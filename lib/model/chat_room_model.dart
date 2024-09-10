class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;

  // Constructor
  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
  });

  // Method to convert ChatRoomModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastMessage': lastMessage,
    };
  }

  // Method to create ChatRoomModel object from JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
        chatroomid: json['chatroomid'],
        participants: json['participants'],
        lastMessage: json['lastMessage']);
  }
}
