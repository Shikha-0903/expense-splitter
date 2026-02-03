import 'dart:async';
import 'package:expense_splitter/src/core/router/all/home_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  String? _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword() {
    final pw = _passwordController.text;
    if (pw.isEmpty) return 'Password is required';
    if (pw.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validateConfirm() {
    if (_confirmPasswordController.text.isEmpty) {
      return 'Confirm your password';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _onRegisterPressed() {
    final emailErr = _validateEmail();
    final pwErr = _validatePassword();
    final confirmErr = _validateConfirm();

    if (emailErr != null || pwErr != null || confirmErr != null) {
      _showSnackBar(emailErr ?? pwErr ?? confirmErr!, isError: true);
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          // Navigate to OTP verification page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(email: state.email),
            ),
          );
        } else if (state is AuthError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        //resizeToAvoidBottomInsets: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.offWhite, AppTheme.softLavender],
                  ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.paddingOf(context).top,
                child: Column(
                  children: [
                    // ─── DECORATIVE BLOBS ───
                    SizedBox(
                      height: 0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -40,
                            left: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.premiumIndigo.withAlpha(35)
                                    : AppTheme.classicLavender.withAlpha(55),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: -20,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.premiumPurple.withAlpha(30)
                                    : AppTheme.lightLavender.withAlpha(70),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── HEADER with back ───
                    SizedBox(height: size.height * 0.04),
                    FadeTransition(
                      opacity: _headerOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            // Back button
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      isDark ? 30 : 12,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.midnightBlue,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Step indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.premiumPurple.withAlpha(30),
                                    AppTheme.premiumIndigo.withAlpha(30),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Step 1 of 2',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.premiumPurple,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // ─── TITLE ───
                    FadeTransition(
                      opacity: _headerOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.8,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.midnightBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Join the smart way to split expenses',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // ─── FORM CARD ───
                    SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formOpacity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withAlpha(230)
                                  : Colors.white.withAlpha(240),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.cardShadow,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withAlpha(20)
                                    : AppTheme.lightLavender.withAlpha(120),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email
                                  _buildField(
                                    context,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    label: 'Email Address',
                                    hint: 'you@example.com',
                                    icon: Icons.email_rounded,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                    nextFocus: _passwordFocus,
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  _buildField(
                                    context,
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    label: 'Password',
                                    hint: 'Min. 6 characters',
                                    icon: Icons.lock_rounded,
                                    isDark: isDark,
                                    obscure: _obscurePassword,
                                    suffixIcon: _eyeIcon(
                                      _obscurePassword,
                                      isDark,
                                      () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    nextFocus: _confirmFocus,
                                  ),
                                  const SizedBox(height: 14),

                                  // Confirm Password
                                  _buildField(
                                    context,
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmFocus,
                                    label: 'Confirm Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    isDark: isDark,
                                    obscure: _obscureConfirm,
                                    suffixIcon: _eyeIcon(
                                      _obscureConfirm,
                                      isDark,
                                      () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                    onDone: _onRegisterPressed,
                                  ),
                                  const SizedBox(height: 24),

                                  // ─── REGISTER BUTTON ───
                                  _RegisterButton(
                                    onPressed: _onRegisterPressed,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ─── BOTTOM: Sign in link ───
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.premiumPurple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _eyeIcon(bool obscure, bool isDark, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
        size: 22,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    FocusNode? nextFocus,
    VoidCallback? onDone,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: nextFocus != null
          ? TextInputAction.next
          : TextInputAction.done,
      /*onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onDone?.call();
        }
      },*/
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : AppTheme.midnightBlue,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : AppTheme.mutedLavender,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppTheme.premiumPurple, size: 22),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withAlpha(30) : AppTheme.lightLavender,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withAlpha(30) : AppTheme.lightLavender,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.premiumPurple,
            width: 2.2,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF111827)
            : AppTheme.softLavender.withAlpha(60),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

// ─── REGISTER BUTTON ────────────────────────────────────────────────────────
class _RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RegisterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p is AuthLoading || c is AuthLoading,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isLoading ? 0.7 : 1.0,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? LinearGradient(
                      colors: [
                        AppTheme.premiumPurple.withAlpha(150),
                        AppTheme.deepLavender.withAlpha(150),
                      ],
                    )
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.premiumPurple.withAlpha(80),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isLoading ? null : onPressed,
                splashColor: Colors.white.withAlpha(40),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP VERIFICATION PAGE
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _remainingSeconds = 30;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    // Add listeners on focus nodes to auto-advance
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _onOtpInput(int index, String value) {
    if (value.length == 1) {
      // Move to next
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // All filled — verify
        _verifyOtp();
      }
    } else if (value.isEmpty) {
      // Backspace — go to previous
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
        _otpControllers[index - 1].clear();
      }
    }
  }

  String _getOtpString() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _verifyOtp() {
    if (_isVerifying) return; // ← ADD THIS

    final otp = _getOtpString();
    if (otp.length < 6) {
      _showSnackBar('Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isVerifying = true); // ← ADD THIS

    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(email: widget.email, token: otp),
    );
  }

  void _resendOtp() {
    if (!_canResend) return;
    context.read<AuthBloc>().add(AuthResendOtpRequested(email: widget.email));
    _startTimer();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to dashboard after successful verification
          if (context.mounted) {
            context.go(HomeRoutes.dashBoardPage);
          }
        } else if (state is AuthError) {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              duration: const Duration(milliseconds: 2500),
            ),
          );
        } else if (state is AuthOtpSent) {
          // OTP resent successfully — restart timer
          _showSnackBar('Verification code resent!');
        }
      },
      child: Scaffold(
        //resizeToAvoidBottomInsets: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.offWhite, AppTheme.softLavender],
                  ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.paddingOf(context).top,
                child: Column(
                  children: [
                    // ─── BLOBS ───
                    SizedBox(
                      height: 0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -50,
                            right: -30,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.premiumPurple.withAlpha(35)
                                    : AppTheme.classicLavender.withAlpha(50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // ─── HEADER ───
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      isDark ? 30 : 12,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.midnightBlue,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.premiumPurple.withAlpha(30),
                                    AppTheme.premiumIndigo.withAlpha(30),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Step 2 of 2',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.premiumPurple,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // ─── SHIELD ICON ───
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.premiumPurple.withAlpha(30),
                                    AppTheme.premiumIndigo.withAlpha(30),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: AppTheme.premiumPurple,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.6,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.midnightBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                'We sent a 6-digit code to\n${widget.email}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[500],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // ─── OTP INPUT BOXES ───
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (i) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: i == 2 || i == 3 ? 4 : 3,
                                ),
                                child: _OtpBox(
                                  controller: _otpControllers[i],
                                  focusNode: _otpFocusNodes[i],
                                  isDark: isDark,
                                  hasSeparator: i == 2,
                                  onInput: (val) => _onOtpInput(i, val),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── RESEND TIMER ───
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                            if (_canResend)
                              GestureDetector(
                                onTap: _resendOtp,
                                child: const Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.premiumPurple,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Resend in ${_remainingSeconds}s',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ─── VERIFY BUTTON ───
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: _VerifyButton(onPressed: _verifyOtp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SINGLE OTP BOX ─────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool hasSeparator;
  final Function(String) onInput;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.hasSeparator,
    required this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            final focused = focusNode.hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 58,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF111827)
                    : AppTheme.softLavender.withAlpha(60),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: focused
                      ? AppTheme.premiumPurple
                      : (isDark
                            ? Colors.white.withAlpha(25)
                            : AppTheme.lightLavender),
                  width: focused ? 2.2 : 1.5,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: AppTheme.premiumPurple.withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                /*buildCounterWidget: (context,
                    {required baseStyle,
                      required errorText,
                      required isFocused,
                      required currentLength,
                      required maxLength}) =>
                const SizedBox(),*/
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.midnightBlue,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onInput,
              ),
            );
          },
        ),
        // Separator dash
        if (hasSeparator)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 16,
              height: 2.5,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[600]
                    : AppTheme.mutedLavender.withAlpha(120),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── VERIFY BUTTON ──────────────────────────────────────────────────────────
class _VerifyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _VerifyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p is AuthLoading || c is AuthLoading,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isLoading ? 0.7 : 1.0,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? LinearGradient(
                      colors: [
                        AppTheme.premiumPurple.withAlpha(150),
                        AppTheme.deepLavender.withAlpha(150),
                      ],
                    )
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.premiumPurple.withAlpha(80),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isLoading ? null : onPressed,
                splashColor: Colors.white.withAlpha(40),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
