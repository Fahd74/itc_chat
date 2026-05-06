import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itc_chat/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  @override
  Future<void> signUpWithEmailPassword(String email, String password) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  @override
  Stream<bool> get authStateChanges => _supabaseClient.auth.onAuthStateChange.map(
        (event) => event.session != null,
      );
}
