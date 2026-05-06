import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itc_chat/features/auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
    _authSubscription = _authRepository.authStateChanges.listen((isAuthenticated) {
      if (isAuthenticated) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  void checkAuthStatus() {
    if (_authRepository.isAuthenticated) {
      emit(AuthSuccess());
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailPassword(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signup(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmailPassword(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthInitial());
  }
}
