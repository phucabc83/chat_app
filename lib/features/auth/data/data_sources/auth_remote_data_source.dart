import 'package:chat_app/features/auth/data/models/user_model.dart';

import '../../../../core/service/api_service.dart';


class AuthRemoteDataSource {
  ApiService apiService;
  AuthRemoteDataSource({
    required this.apiService,
  });

  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try{
      return await apiService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      print('Error signing in: ${e.toString()}');
      throw Exception(e.toString());
   }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String name, int avatarId) async {
    try{
      await apiService.signUpWithEmailAndPassword(email, password, name,avatarId);
    } catch (e) {
      print('Error signing up: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

}