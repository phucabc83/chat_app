import 'package:chat_app/core/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:chat_app/features/auth/domain/entities/user.dart' ;
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogleRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('User cancelled Google sign-in');
    }

    // Lấy token
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    // Tạo credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Đăng nhập Firebase
    return await FirebaseAuth.instance
        .signInWithCredential(credential);
  }

  Future<User> getUserDB({required String email,required String name,required String avatarUrl}) async {
    final user = await _apiService.fetchUserGoogle(email: email, name: name, avatarUrl: avatarUrl);

    return user;
  }



  Future<void> signOut() async {
    await _auth.signOut();
  }
}
