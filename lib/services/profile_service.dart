import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ! Get Data User
  Future<UserModel?> getUserProfile(String uid) async {
    final query = await users.where('uid', isEqualTo: uid).limit(1).get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // ! Simpan Data User
  Future<void> saveUserProfile(UserModel user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  // ! Update Data User
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    final query = await users.where('uid', isEqualTo: uid).limit(1).get();
    if (query.docs.isNotEmpty) {
      await users.doc(query.docs.first.id).update(data);
    }
  }
}
