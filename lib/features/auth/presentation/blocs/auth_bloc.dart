import 'package:chat_app/features/auth/domain/repositories/auth_fb_repository.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_gg_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:chat_app/features/auth/presentation/blocs/auth_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/service/fcm_service.dart';
import '../../../../core/service/socket_service.dart';
import '../../../../core/utils/util.dart';
import '../../../../main.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUsecase signUpUseCase;
  final _storage = const FlutterSecureStorage();
  final AuthGoogleRepository authGoogleRepository;
  final AuthFacebookRepository authFacebookRepository;

  AuthBloc(this.loginUseCase, this.signUpUseCase, this.authGoogleRepository,this.authFacebookRepository)
    : super(AuthInitial()) {
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
        await signUpUseCase.call(
          event.name,
          event.email,
          event.password,
          event.avatarId,
        );
        emit(AuthSuccess('Đăng ký thành công: '));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthGoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authGoogleRepository.signInWithGoogle();

        if(result.user == null){
          emit(
            AuthFailure('Đăng nhập Google thất bại: Không nhận được thông tin người dùng.')
          );
          return;
        }

        final user = await authGoogleRepository.getUserDB(email: result.user!.email!, name: result.user!.displayName ?? result.user!.email!, avatarUrl: result.user!.photoURL ?? 'https://placehold.co/100x100/png?text=${result.user!.displayName ?? result.user!.email!}');


        await _storage.write(key: 'token', value: user.token);
        await _storage.write(key: 'userId', value: user.id.toString());
        await _storage.write(key: 'userName', value: user.name.toString());
        await _storage.write(key: 'avatarUrl', value: user.avatar.toString());

        Util.userId = user.id;
        Util.token = user.token!;
        Util.userName = user.name;
        Util.avatarUrl = user.avatar!;


        debugPrint(
          'user login : $user'
        );
        await sl<FcmService>().setupPush();
        emit(AuthSuccess('Đăng nhập thành công: ${result.user!.email}'));

      } catch (e) {
        debugPrint(
          'Lỗi đăng nhập Google: ${e.toString()}'
        );
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthFacebookSignInEvent>((event, emit) async {
      emit(AuthLoading());
      final UserCredential result;
      try {
        if (kIsWeb) {
          result = await authFacebookRepository.signInWithFacebookWeb();
        } else {
          result = await authFacebookRepository.signInWithFacebook();
        }
        if(result.user == null){
          emit(
              AuthFailure('Đăng nhập Facebook thất bại: Không nhận được thông tin người dùng.')
          );
          return;
        }

        final fbUser = result.user!;

        final email = fbUser.email ??
            'fb_${fbUser.uid}@facebook.com';

        final name = fbUser.displayName ??
            'Facebook User';

        final avatar = fbUser.photoURL ??
            'https://placehold.co/100x100/png?text=FB';

        final user = await authGoogleRepository.getUserDB(email: email, name: name, avatarUrl: avatar);


        await _storage.write(key: 'token', value: user.token);
        await _storage.write(key: 'userId', value: user.id.toString());
        await _storage.write(key: 'userName', value: user.name.toString());
        await _storage.write(key: 'avatarUrl', value: user.avatar.toString());

        Util.userId = user.id;
        Util.token = user.token!;
        Util.userName = user.name;
        Util.avatarUrl = user.avatar!;


        debugPrint(
            'user login : $user'
        );
        await sl<FcmService>().setupPush();
        emit(AuthSuccess('Đăng nhập thành công: ${result.user!.email}'));

      } catch (e) {
        debugPrint(
            'Lỗi đăng nhập Facebook: ${e.toString()}'
        );
        emit(AuthFailure(e.toString()));
      }
    });  }
}
