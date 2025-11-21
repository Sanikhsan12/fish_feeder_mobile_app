class UserModel {
  final String uid;
  final String name;
  final String gender;
  final String birthdate;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.gender,
    required this.birthdate,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      birthdate: map['birthdate'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'gender': gender,
      'birthdate': birthdate,
      'photoUrl': photoUrl,
    };
  }
}
