import 'package:equatable/equatable.dart';
import '../../../user/domain/entities/user.dart';

// Base Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Login States
abstract class LoginState extends AuthState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Register States
abstract class RegisterState extends AuthState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final User user;
  final String message;

  const RegisterSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Profile Update States
abstract class ProfileUpdateState extends AuthState {
  const ProfileUpdateState();
}

class ProfileUpdateInitial extends ProfileUpdateState {
  const ProfileUpdateInitial();
}

class ProfileUpdateLoading extends ProfileUpdateState {
  const ProfileUpdateLoading();
}

class ProfileUpdateSuccess extends ProfileUpdateState {
  final User user;
  final String message;

  const ProfileUpdateSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class ProfileUpdateFailure extends ProfileUpdateState {
  final String message;

  const ProfileUpdateFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Current User State
abstract class CurrentUserState extends AuthState {
  const CurrentUserState();
}

class CurrentUserInitial extends CurrentUserState {
  const CurrentUserInitial();
}

class CurrentUserLoading extends CurrentUserState {
  const CurrentUserLoading();
}

class CurrentUserLoaded extends CurrentUserState {
  final User? user;

  const CurrentUserLoaded({this.user});

  @override
  List<Object?> get props => [user];
}

class CurrentUserError extends CurrentUserState {
  final String message;

  const CurrentUserError({required this.message});

  @override
  List<Object?> get props => [message];
}
