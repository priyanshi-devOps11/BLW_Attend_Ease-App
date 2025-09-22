class AuthService {
  String? _currentUserEmail;

  /// Stream of user auth state (signed in/out)
  Stream<String?> get userChanges async* {
    yield _currentUserEmail; // simple one-shot stream
  }

  /// Get current user (email as identifier)
  String? get currentUser => _currentUserEmail;

  /// Get current user (method form)
  String? getCurrentUser() {
    return _currentUserEmail;
  }

  /// Sign up with email & password (local mock)
  Future<String?> signUp(String email, String password) async {
    // In a real backend, save credentials securely (e.g., database).
    _currentUserEmail = email;
    return _currentUserEmail;
  }

  /// Sign in with email & password (local mock)
  Future<String?> signIn(String email, String password) async {
    // Normally, you'd validate credentials against a database.
    _currentUserEmail = email;
    return _currentUserEmail;
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUserEmail = null;
  }

  /// Reset password (mock)
  Future<void> resetPassword(String email) async {
    // In real implementation, send reset link/email via backend.
    // Here it's just a placeholder.
    return;
  }
}
