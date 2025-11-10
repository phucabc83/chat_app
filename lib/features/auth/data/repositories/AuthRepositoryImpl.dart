import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async{

    try{
      final userModel = await remoteDataSource.signInWithEmailAndPassword(email, password);
      return userModel.toEntity();
    }catch(e){
      print('Error signing in: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
  @override
  Future<void> signOut() async{
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password, String name,int avatarId) async{
    try{
      await remoteDataSource.signUpWithEmailAndPassword(email, password, name,avatarId);
    }catch(e){
      print('Error signing up: ${e.toString()}');
      throw Exception(e.toString());
    }
  }













}