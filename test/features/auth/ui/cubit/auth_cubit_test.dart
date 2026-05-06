import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:itc_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_state.dart';

// ==========================================
// Mock Repository
// ==========================================
class MockAuthRepository implements AuthRepository {
  bool _isAuthenticated;
  bool shouldThrowOnLogin;
  bool shouldThrowOnSignup;
  String errorMessage;
  final _authStateController = StreamController<bool>.broadcast();

  MockAuthRepository({
    bool isAuthenticated = false,
    this.shouldThrowOnLogin = false,
    this.shouldThrowOnSignup = false,
    this.errorMessage = 'خطأ تجريبي',
  }) : _isAuthenticated = isAuthenticated;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    if (shouldThrowOnLogin) {
      throw Exception(errorMessage);
    }
    _isAuthenticated = true;
    _authStateController.add(true);
  }

  @override
  Future<void> signUpWithEmailPassword(String email, String password) async {
    if (shouldThrowOnSignup) {
      throw Exception(errorMessage);
    }
    _isAuthenticated = true;
    _authStateController.add(true);
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _authStateController.add(false);
  }
}

void main() {
  // NOTE: blocTest only captures states emitted AFTER build() returns.
  // The AuthCubit constructor calls checkAuthStatus() which emits during
  // construction. For unauthenticated users, it emits AuthInitial (same
  // as super()), so BLoC de-duplicates it. For authenticated users, it
  // emits AuthSuccess which IS captured.

  // ==========================================
  // UC-1: Cold Start — No Previous Session
  // ==========================================
  group('UC-1: Cold Start — No Previous Session', () {
    blocTest<AuthCubit, AuthState>(
      'starts with AuthInitial when no user session exists',
      build: () => AuthCubit(MockAuthRepository(isAuthenticated: false)),
      // checkAuthStatus emits AuthInitial, but super() already set it,
      // so BLoC sees same-type state and de-duplicates. No new emissions.
      verify: (cubit) {
        expect(cubit.state, isA<AuthInitial>());
      },
    );
  });

  // ==========================================
  // UC-2: Login with Valid Credentials
  // ==========================================
  group('UC-2: Login with Valid Credentials', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful login',
      build: () => AuthCubit(MockAuthRepository()),
      act: (cubit) => cubit.login('test@uni.edu', 'password123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );
  });

  // ==========================================
  // UC-3: Login with Invalid Credentials
  // ==========================================
  group('UC-3: Login with Invalid Credentials', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failed login',
      build: () => AuthCubit(MockAuthRepository(
        shouldThrowOnLogin: true,
        errorMessage: 'بيانات خاطئة',
      )),
      act: (cubit) => cubit.login('wrong@uni.edu', 'wrongpass'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
      verify: (cubit) {
        final errorState = cubit.state as AuthError;
        expect(errorState.message, contains('بيانات خاطئة'));
      },
    );
  });

  // ==========================================
  // UC-4: Signup Flow — Success
  // ==========================================
  group('UC-4: Signup Flow', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful signup',
      build: () => AuthCubit(MockAuthRepository()),
      act: (cubit) => cubit.signup('new@uni.edu', 'newpass123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failed signup',
      build: () => AuthCubit(MockAuthRepository(
        shouldThrowOnSignup: true,
        errorMessage: 'البريد مسجل مسبقاً',
      )),
      act: (cubit) => cubit.signup('existing@uni.edu', 'pass123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
      verify: (cubit) {
        final errorState = cubit.state as AuthError;
        expect(errorState.message, contains('البريد مسجل مسبقاً'));
      },
    );
  });

  // ==========================================
  // UC-5: Logout
  // ==========================================
  group('UC-5: Logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthInitial] on logout from authenticated',
      build: () => AuthCubit(MockAuthRepository(isAuthenticated: true)),
      act: (cubit) => cubit.logout(),
      expect: () => [
        // AuthSuccess from constructor becomes the seed state (not captured)
        // Only transitions after act() are captured
        isA<AuthLoading>(),
        isA<AuthInitial>(),
      ],
    );
  });

  // ==========================================
  // UC-6: Session Persistence (App Restart)
  // ==========================================
  group('UC-6: Session Persistence', () {
    blocTest<AuthCubit, AuthState>(
      'state is AuthSuccess when user was previously authenticated',
      build: () => AuthCubit(MockAuthRepository(isAuthenticated: true)),
      // constructor calls checkAuthStatus → emits AuthSuccess as seed state
      // blocTest doesn't capture seed, so we verify via cubit.state
      verify: (cubit) {
        expect(cubit.state, isA<AuthSuccess>());
      },
    );
  });

  // ==========================================
  // UC-7: Empty Form Submission
  // ==========================================
  group('UC-7: Empty Form Submission', () {
    // Validation is at the UI Form level. The cubit itself does not
    // guard against empty strings — that's TextFormField's job.
    // This test verifies that IF empty strings reach the cubit, the
    // mock repo still handles it (real Supabase would throw an error).
    blocTest<AuthCubit, AuthState>(
      'empty strings still go through cubit (validation is UI-layer)',
      build: () => AuthCubit(MockAuthRepository()),
      act: (cubit) => cubit.login('', ''),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );
  });
}
