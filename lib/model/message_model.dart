class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  // Constructor
  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.createdon,
  });

  // Method to convert MessageModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'messageid': messageid,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdon':
          createdon?.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }

  // Method to create MessageModel object from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageid: json['messageid'],
      sender: json['sender'],
      text: json['text'],
      seen: json['seen'],
      createdon: json['createdon'] != null
          ? DateTime.parse(json['createdon'])
          : null, // Parse ISO 8601 string to DateTime
    );
  }
}
