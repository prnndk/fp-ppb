import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
