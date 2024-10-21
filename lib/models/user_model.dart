class UserModel {
  final String uid;
  final String name;
  final Map<String, int> frequencyValues;

  UserModel({
    required this.uid,
    required this.name,
    required this.frequencyValues,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      frequencyValues: Map<String, int>.from(data),
    );
  }
}
