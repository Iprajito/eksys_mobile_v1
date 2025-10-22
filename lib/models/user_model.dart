class User {
  String? uid;
  String? email;
  String? name;
  String? user_group;
  String? token;

  User({
    this.uid,
    this.email,
    this.name,
    this.user_group,
    this.token,
  });

  // Factory method to convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'],
        email: json['email'],
        name: json['name'],
        user_group: json['user_group'],
        token: json['token']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'user_group': user_group,
      'token': token,
    };
  }
}
