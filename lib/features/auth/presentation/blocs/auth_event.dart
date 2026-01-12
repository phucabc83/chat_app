abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final int avatarId;

  AuthSignUpEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.avatarId,
  });
}
class AuthGoogleSignInEvent extends AuthEvent {}
class AuthFacebookSignInEvent extends AuthEvent {}

class AuthSignOutEvent extends AuthEvent {}