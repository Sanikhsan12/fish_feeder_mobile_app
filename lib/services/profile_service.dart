import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ! Get Data User
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // ! Simpan Data User
  Future<void> saveUserProfile(UserModel user) async {
    await users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  // ! Update Data User
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }
}
