import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_splitter/src/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = supabase;

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  bool get isLoggedIn {
    return currentUser != null;
  }

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      if (response.user!.emailConfirmedAt == null) {
        await _supabase.auth.signOut();
        throw Exception(
          'Please verify your email first. Check your inbox for the verification code.',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailOtp({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<({AuthResponse response, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      final user = response.user;
      bool isNewUser = false;

      if (user != null) {
        final created = DateTime.tryParse(user.createdAt) ?? DateTime.now();
        final lastSignIn =
            DateTime.tryParse(user.lastSignInAt ?? '') ?? created;
        final firstSignIn =
            user.lastSignInAt == null ||
            lastSignIn.difference(created).inSeconds.abs() < 10;
        final singleIdentity = (user.identities?.length ?? 0) <= 1;
        isNewUser = firstSignIn && singleIdentity;
      }

      return (response: response, isNewUser: isNewUser);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, emailRedirectTo: null);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to resend OTP: ${e.toString()}');
    }
  }

  // Sign in with Google using ID Token - FIXED
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['GOOGLE_CLIENT_ID'];
      if (webClientId == null || webClientId.isEmpty) {
        throw Exception('Missing GOOGLE_CLIENT_ID in .env');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: webClientId);

      // Sign out first to ensure clean state
      try {
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google sign out error (ignored): $e');
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user == null) {
        throw Exception('Failed to authenticate with Supabase');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      try {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.disconnect();
      } catch (_) {}
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email, redirectTo: null);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset OTP: ${e.toString()}');
    }
  }

  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  String? get authToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  String? get userId {
    return _supabase.auth.currentUser?.id;
  }

  Exception _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return Exception('Invalid email or password');
        } else if (e.message.contains('Email not confirmed')) {
          return Exception(
            'Please verify your email with the OTP code sent to your inbox',
          );
        } else if (e.message.contains('User already registered')) {
          return Exception(
            'This email is already registered. Please login instead.',
          );
        }
        return Exception(e.message);
      case '422':
        return Exception('Invalid email format');
      case '429':
        return Exception('Too many requests. Please try again later');
      default:
        return Exception(e.message);
    }
  }

  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  static String? getAuthToken() {
    return supabase.auth.currentSession?.accessToken;
  }

  static String? getUserId() {
    return supabase.auth.currentUser?.id;
  }
}
