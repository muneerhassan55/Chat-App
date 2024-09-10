class ChatRoomModel {
  String? chatroomid;
  List<String>? participants;

  // Constructor
  ChatRoomModel({
    this.chatroomid,
    this.participants,
  });

  // Method to convert ChatRoomModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
    };
  }

  // Method to create ChatRoomModel object from JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatroomid: json['chatroomid'],
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}
