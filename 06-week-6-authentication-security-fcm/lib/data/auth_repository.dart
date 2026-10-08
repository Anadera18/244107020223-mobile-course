class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

/// Mock auth repository, ready to be swapped for Firebase Auth.
class AuthRepository {
  // REPLACE this method body with FirebaseAuth.instance.signInWithEmailAndPassword
  // or GoogleSignIn once a Firebase backend is ready. The rest of the app
  // (TokenStore, Dio interceptor, route guard) stays identical.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    // Simulated tokens. A real backend returns a signed JWT that is verified
    // server-side; the client never parses or trusts it.
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  /// In production this is an HTTPS POST whose BODY carries the refresh token
  /// (never a URL query string).
  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token missing');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
