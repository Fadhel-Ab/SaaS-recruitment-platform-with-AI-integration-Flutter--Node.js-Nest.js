import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final TokenStorage storage;

  AuthBloc(this.repository, this.storage) : super(const AuthState()) {
    on<LoginRequested>(_login);
    on<AuthStarted>(_checkAuth);
    on<RegisterRequested>(_register);
    on<LogoutRequested>(_logout);
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await repository.login(event.email, event.password);
      final user = UserModel.fromJson(result['user']);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          token: result['accessToken'],
          user: user,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, error: friendlyErrorMessage(e)));
    }
  }

  Future<void> _register(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final result = await repository.register(
        event.fullName,
        event.email,
        event.password,
        event.role.name.toUpperCase(),
      );
      final user = UserModel.fromJson(result['user']);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          token: result['accessToken'],
          user: user,
        ),
      );
      print(user);
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, error: friendlyErrorMessage(e)));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _checkAuth(AuthStarted event, Emitter<AuthState> emit) async {
    final token = await storage.readToken();
    if (token == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));

      return;
    }

    try {
      final user = await repository.getCurrentUser(token);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          user: user,
        ),
      );
    } catch (e) {
      await storage.deleteToken();

      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } finally {}
  }
}
