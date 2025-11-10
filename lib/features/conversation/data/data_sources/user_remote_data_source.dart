import 'package:chat_app/core/service/api_service.dart';

import '../../../auth/domain/entities/user.dart';

class UserRemoteDataSource {
  final ApiService apiService;
  UserRemoteDataSource(this.apiService);

  Future<List<User>> getAllUsers() async {
    try {
      final List<User> users = await apiService.getAllUsers();
      print('Fetched ${users.length} users');
      return users;
    } catch (e) {
      print('Error fetching users: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}