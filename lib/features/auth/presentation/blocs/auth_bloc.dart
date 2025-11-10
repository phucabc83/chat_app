import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:chat_app/features/auth/presentation/blocs/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/service/fcm_service.dart';
import '../../../../core/service/socket_service.dart';
import '../../../../core/utils/util.dart';
import '../../../../main.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState>{
  final LoginUseCase loginUseCase;
  final SignUpUsecase signUpUseCase;
  final _storage = const FlutterSecureStorage();


  AuthBloc(this.loginUseCase,this.signUpUseCase) : super(AuthInitial()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await loginUseCase.call(event.email, event.password);
        await _storage.write(key: 'token', value: result.token);
        await _storage.write(key: 'userId', value: result.id.toString());
        await _storage.write(key: 'userName', value: result.name.toString());
        await _storage.write(key: 'avatarUrl', value: result.avatar.toString());
        Util.userId = result.id;
        Util.token = result.token!;
        Util.userName = result.name;
        Util.avatarUrl = result.avatar!;
        await sl<FcmService>().setupPush();
        emit(AuthSuccess('Đăng nhập thành công: ${result.email}'));
        print(result);
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        print('Đang đăng ký: ${event.name}, ${event.email}, ${event.password}');
        await signUpUseCase.call(event.name,event.email, event.password,event.avatarId);
        emit(AuthSuccess('Đăng ký thành công: '));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
      }
    );

  }
  }
