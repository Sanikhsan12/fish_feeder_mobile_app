import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // ! instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //! register
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
