class UserModel {
  final String uid;

  UserModel({
    required this.uid,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid
    );
  }
}
