import 'package:equatable/equatable.dart';
import '../../../../auth/domain/entities/user.dart';

abstract class UsersOnlineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersOnlineInitial extends UsersOnlineState {}

class UsersOnlineLoading extends UsersOnlineState {}

class UsersOnlineLoaded extends UsersOnlineState {
  final List<User> users;

  UsersOnlineLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersOnlineError extends UsersOnlineState {
  final String message;

  UsersOnlineError(this.message);

  @override
  List<Object?> get props => [message];
}
