import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication Result
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final User user;
  const AuthSuccess(this.user);
}

/// Represents a successful operation that doesn't return a user
/// (e.g., password reset email sent)
class AuthOperationSuccess extends AuthResult {
  final String message;
  const AuthOperationSuccess(this.message);
}

class AuthFailure extends AuthResult {
  final String message;
  final String? code;
  const AuthFailure(this.message, {this.code});
}

class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

/// Auth Repository - Handles all authentication operations
///
/// Implements:
/// - Google Sign-In (primary authentication method)
/// - Email + Password (optional)
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Current user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> authState() => _auth.authStateChanges();

  /// Check if user has verified email
  bool get hasVerifiedEmail => _auth.currentUser?.emailVerified ?? false;

  // ============================================
  // AUTHENTICATION CHECK
  // ============================================

  /// Check if user is logged in
  ///
  /// Returns current user if logged in, null otherwise.
  /// Does NOT create anonymous accounts - user must sign in with Google.
  AuthResult? checkLoggedIn() {
    if (_auth.currentUser != null) {
      return AuthSuccess(_auth.currentUser!);
    }
    return null;
  }

  // ============================================
  // GOOGLE SIGN-IN
  // ============================================

  /// Sign in with Google (new user or existing)
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthCancelled();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        return AuthSuccess(userCredential.user!);
      }
      return const AuthFailure('Google sign in failed');
    } on FirebaseAuthException catch (e) {
      return AuthFailure(e.message ?? 'Google sign in error', code: e.code);
    } catch (e) {
      return AuthFailure('Google sign in failed: $e');
    }
  }

  // ============================================
  // EMAIL + PASSWORD
  // ============================================

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Send verification email
        await credential.user!.sendEmailVerification();
        return AuthSuccess(credential.user!);
      }
      return const AuthFailure('Sign up failed');
    } on FirebaseAuthException catch (e) {
      return AuthFailure(e.message ?? 'Sign up error', code: e.code);
    } catch (e) {
      return AuthFailure('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return AuthSuccess(credential.user!);
      }
      return const AuthFailure('Sign in failed');
    } on FirebaseAuthException catch (e) {
      return AuthFailure(e.message ?? 'Sign in error', code: e.code);
    } catch (e) {
      return AuthFailure('Sign in failed: $e');
    }
  }

  /// Send password reset email
  /// Note: This can be called when user is NOT logged in (forgot password flow)
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Return success without requiring current user (user may be logged out)
      return const AuthOperationSuccess('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthFailure(e.message ?? 'Password reset error', code: e.code);
    } catch (e) {
      return AuthFailure('Password reset failed: $e');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  /// Sign out current user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Get user display name
  String? get displayName => _auth.currentUser?.displayName;

  /// Get user email
  String? get email => _auth.currentUser?.email;

  /// Get user photo URL
  String? get photoURL => _auth.currentUser?.photoURL;

  /// Get auth provider
  String get authProvider {
    final user = _auth.currentUser;
    if (user == null) return 'none';
    
    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') return 'google';
      if (provider.providerId == 'password') return 'email';
    }
    return 'unknown';
  }
}

/// Provider for Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authState();
});

/// Provider for auth state
final isLoggedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});
