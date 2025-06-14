import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  //get the current user
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
