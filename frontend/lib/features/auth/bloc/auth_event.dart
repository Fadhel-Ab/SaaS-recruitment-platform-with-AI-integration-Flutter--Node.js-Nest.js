import 'package:equatable/equatable.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Login button pressed
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}


class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;

  const RegisterRequested({required this.fullName, required this.email, required this.password, required this.role});

  @override
  List<Object?> get props => [fullName, email, password, role];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
