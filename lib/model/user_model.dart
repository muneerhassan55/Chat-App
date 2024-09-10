class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  // Constructor
  UserModel({
    this.uid,
    this.fullname,
    this.email,
    this.profilepic,
  });

  // Method to create UserModel object from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      fullname: json['fullname'],
      email: json['email'],
      profilepic: json['profilepic'],
    );
  }

  // Method to convert UserModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'profilepic': profilepic,
    };
  }
}
