import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  /// مسجّل أو ضيف: يحق له رؤية صفحات التطبيق.
  bool get hasAccess => this is AuthAuthenticated || this is AuthGuest;

  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.errorMessage});

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

class AuthGuest extends AuthState {
  const AuthGuest();
}