import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String token;

  const AuthVerifyOtpRequested({required this.email, required this.token});

  @override
  List<Object?> get props => [email, token];
}

class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
}

class AuthVerifyPasswordResetOtpRequested extends AuthEvent {
  final String email;
  final String token;
  const AuthVerifyPasswordResetOtpRequested({
    required this.email,
    required this.token,
  });
}

class AuthUpdatePasswordRequested extends AuthEvent {
  final String newPassword;
  const AuthUpdatePasswordRequested(this.newPassword);
}
