import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:chat_app/features/auth/domain/entities/user.dart' ;
import '../../../../core/service/api_service.dart';

class AuthFacebookRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService;
  AuthFacebookRepository(this._apiService);


  Future<UserCredential> signInWithFacebookWeb() async {
    final facebookProvider = FacebookAuthProvider();
    return await FirebaseAuth.instance.signInWithPopup(facebookProvider);
  }
  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult =
    await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    debugPrint('FB STATUS: ${loginResult.status}');
    debugPrint('FB MESSAGE: ${loginResult.message}');
    debugPrint('FB TOKEN: ${loginResult.accessToken?.token}');

    switch (loginResult.status) {
      case LoginStatus.success:
        final accessToken = loginResult.accessToken!;
        final credential =
        FacebookAuthProvider.credential(accessToken.token);
        return await _auth.signInWithCredential(credential);

      case LoginStatus.cancelled:
        throw Exception('Người dùng đã huỷ đăng nhập Facebook');

      case LoginStatus.failed:
        throw Exception(
            'Facebook login failed: ${loginResult.message}');

      default:
        throw Exception('Facebook login unknown error');
    }
  }

  Future<User> getUserDB({
    required String email,
    required String name,
    required String avatarUrl
  }) async {
    final user = await _apiService.fetchUserGoogle(
        email: email,
        name: name,
        avatarUrl: avatarUrl
    );

    return user;
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}