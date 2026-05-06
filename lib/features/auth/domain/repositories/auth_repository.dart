abstract class AuthRepository {
  Future<void> signInWithEmailPassword(String email, String password);
  Future<void> signUpWithEmailPassword(String email, String password);
  Future<void> signOut();
  bool get isAuthenticated;
  Stream<bool> get authStateChanges;
}
