import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_all_user_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersCubit extends Cubit<UsersState> {
  final FetchAllUserUseCase userUseCase;

  UsersCubit({required this.userUseCase}) : super(const UsersState());

  Future<void> loadAllUsers() async {
    try{
      emit(state.copyWith(loading: true, error: null));
      final users = await userUseCase.execute();
      print(users);
      emit(state.copyWith(loading: false, users: users, error: null));
    }catch(e){
      emit(UsersState(error: e.toString(), loading: false));
    }
  }
}

class UsersState extends Equatable {
  final bool loading;
  final List<User> users;
  final String? error;

  const UsersState({
    this.users = const [],
    this.error,
    this.loading = false,
  });

  UsersState copyWith({
    List<User>? users,
    String? error,
    bool? loading,
  }) {
    return UsersState(
      users: users ?? this.users,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading, users, error];

  @override
  String toString() {
    return 'UsersState(loading: $loading, users: $users, error: $error)';
  }
}