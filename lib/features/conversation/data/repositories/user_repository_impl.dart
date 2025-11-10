import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<User>> getAllUsers() async {
    try{
      final users = await remoteDataSource.getAllUsers();
      return users;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<User> getUserById(int userId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

}