import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Handles all authentication logic (Email, Google, Facebook, Apple)
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Returns the currently signed-in Firebase user.
  User? getCurrentUser() => _firebaseAuth.currentUser;

  /// Returns a stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Register a new user with email and password.
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Sign in with Google.
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? gUser = await _googleSignIn.authenticate();
      if (gUser == null) return null;

      final gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

      final userCred = await _firebaseAuth.signInWithCredential(credential);
      return userCred.user;
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Sign in with Facebook.
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        return await _firebaseAuth.signInWithCredential(facebookCredential);
      } else if (result.status == LoginStatus.cancelled) {
        throw 'Facebook sign-in cancelled';
      } else {
        throw 'Facebook sign-in failed: ${result.message}';
      }
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Sign in with Apple (iOS only).
  Future<User?> signInWithApple() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        throw 'Apple Sign-In is not supported on this platform';
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCred = await _firebaseAuth.signInWithCredential(credential);
      return userCred.user;
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw getErrorMessage(e);
    }
  }

  /// Signs out from all providers (Firebase, Google, Facebook).
  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    // Only try to sign out from providers that might have active sessions
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors from providers that weren't used
      if (kDebugMode) {
        print('Google sign-out error (likely no user signed in): $e');
      }
    }

    try {
      await _facebookAuth.logOut();
    } catch (e) {
      // Ignore errors from providers that weren't used
      if (kDebugMode) {
        print('Facebook sign-out error (likely no user signed in): $e');
      }
    }
  }

  /// Converts FirebaseAuth/Google/Facebook/Apple errors into readable messages.
  String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'This sign-in method is not allowed.';
        case 'network-request-failed':
          return 'A network error occurred. Please check your connection.';
        default:
          return 'Authentication error: ${error.message}';
      }
    } else if (error is String) {
      return error;
    } else {
      return 'An unknown error occurred.';
    }
  }
}
