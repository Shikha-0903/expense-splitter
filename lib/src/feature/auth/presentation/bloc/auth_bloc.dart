import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/feature/auth/data/service/auth_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authRepository;
  StreamSubscription? _authSubscription;
  final AnalyticsService _analyticsService;

  AuthBloc({
    required AuthService authRepository,
    required AnalyticsService analyticsService,
  }) : _authRepository = authRepository,
       _analyticsService = analyticsService,
       super(AuthInitial()) {
    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      add(AuthUserChanged(authState.session?.user));
    });

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthVerifyPasswordResetOtpRequested>(_onVerifyPasswordResetOtpRequested);
    on<AuthUpdatePasswordRequested>(_onUpdatePasswordRequested);
  }

  /// Clean error messages by removing common prefixes
  String _cleanErrorMessage(String error) {
    String cleaned = error;

    // Remove common exception prefixes
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring(11);
    } else if (cleaned.startsWith('Error: ')) {
      cleaned = cleaned.substring(7);
    }

    // Handle common Supabase error messages and make them user-friendly
    if (cleaned.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (cleaned.contains('Email not confirmed')) {
      return 'Please verify your email first';
    } else if (cleaned.contains('User already registered')) {
      return 'This email is already registered';
    } else if (cleaned.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    } else if (cleaned.contains('Unable to validate email address')) {
      return 'Invalid email address';
    } else if (cleaned.contains('Email rate limit exceeded')) {
      return 'Too many attempts. Please try again later';
    } else if (cleaned.contains('Token has expired')) {
      return 'Please enter correct verification code or request a new one';
    } else if (cleaned.contains('Invalid token')) {
      return 'Invalid verification code';
    } else if (cleaned.contains('Network request failed') ||
        cleaned.contains('Failed host lookup')) {
      return 'Network error. Please check your connection';
    } else if (cleaned.contains('activity is cancelled by the user')) {
      return 'Operation Cancelled by the user or due to some error';
    }
    return cleaned;
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        await _analyticsService.logLogin('email');
        await _analyticsService.setUserId(response.user!.id);
        emit(AuthAuthenticated(response.user!));
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      // ERROR - Log sign in failure
      await _analyticsService.logAuthError('signin_failed', e.toString());

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordResetOtp(event.email);

      // SUCCESS - Log OTP sent
      await _analyticsService.logOtpSent('password_reset');

      emit(AuthPasswordResetOtpSent(event.email));
    } catch (e) {
      // ERROR - Log password reset request failure
      await _analyticsService.logAuthError(
        'password_reset_request_failed',
        e.toString(),
      );

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onVerifyPasswordResetOtpRequested(
    AuthVerifyPasswordResetOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyPasswordResetOtp(
        email: event.email,
        token: event.token,
      );

      // SUCCESS - Log successful OTP verification
      await _analyticsService.logOtpVerified('password_reset', true);

      emit(AuthPasswordResetOtpVerified(event.email));
    } catch (e) {
      // ERROR - Log failed OTP verification
      await _analyticsService.logAuthError(
        'invalid_password_reset_otp',
        e.toString(),
      );
      await _analyticsService.logOtpVerified('password_reset', false);

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onUpdatePasswordRequested(
    AuthUpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.updatePassword(event.newPassword);
      emit(AuthPasswordUpdated());
    } catch (e) {
      // ERROR - Log password update failure
      await _analyticsService.logAuthError(
        'password_update_failed',
        e.toString(),
      );

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmailOtp(
        email: event.email,
        password: event.password,
      );

      await _analyticsService.logEvent('signup_attempted', {'method': 'email'});

      // SUCCESS - Log OTP sent for signup
      await _analyticsService.logOtpSent('signup');

      emit(AuthOtpSent(event.email));
    } catch (e) {
      // ERROR - Log signup failure
      await _analyticsService.logAuthError('signup_failed', e.toString());

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.verifyEmailOtp(
        email: event.email,
        token: event.token,
      );

      if (result.response.user != null) {
        await _analyticsService.logSignUp('email');
        await _analyticsService.setUserId(result.response.user!.id);

        // SUCCESS - Log successful signup OTP verification
        await _analyticsService.logOtpVerified('signup', true);

        emit(AuthAuthenticated(result.response.user!));
      } else {
        emit(const AuthError('Failed to verify OTP'));
      }
    } catch (e) {
      // ERROR - Log failed signup OTP verification
      await _analyticsService.logAuthError('invalid_signup_otp', e.toString());
      await _analyticsService.logOtpVerified('signup', false);

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.resendOtp(event.email);

      // SUCCESS - Log OTP resent
      await _analyticsService.logOtpResent('signup');

      // Stay in the same state, just show a message
      emit(AuthOtpSent(event.email));
    } catch (e) {
      // ERROR - Log OTP resend failure
      await _analyticsService.logAuthError('otp_resend_failed', e.toString());

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithGoogle();
      if (response.user != null) {
        await _analyticsService.logLogin('google');
        await _analyticsService.setUserId(response.user!.id);

        emit(AuthAuthenticated(response.user!));
      } else {
        emit(const AuthError('Failed to sign in with Google'));
      }
    } catch (e) {
      // ERROR - Log Google sign in failure
      await _analyticsService.logAuthError(
        'google_signin_failed',
        e.toString(),
      );

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();

      await _analyticsService.logSignOut();

      emit(AuthUnauthenticated());
    } catch (e) {
      // ERROR - Log sign out failure
      await _analyticsService.logAuthError('signout_failed', e.toString());

      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
