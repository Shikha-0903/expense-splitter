import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/all/auth_routes.dart';
import '../../../../core/router/all/home_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(_controller);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showFieldError();
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignInRequested(email: email, password: password),
    );
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _showFieldError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Please fill in all fields'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2000),
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
          // Navigate to dashboard after successful login
          if (context.mounted) {
            context.go(HomeRoutes.dashBoardPage);
          }
        } else if (state is AuthError) {
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
                    // ─── TOP DECORATIVE BLOBS ───
                    SizedBox(
                      height: 0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -60,
                            right: -40,
                            child: _decorBlob(
                              120,
                              isDark
                                  ? AppTheme.premiumPurple.withAlpha(40)
                                  : AppTheme.classicLavender.withAlpha(60),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: -50,
                            child: _decorBlob(
                              90,
                              isDark
                                  ? AppTheme.premiumIndigo.withAlpha(30)
                                  : AppTheme.lightLavender.withAlpha(80),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── LOGO AREA ───
                    SizedBox(height: size.height * 0.08),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (ctx, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child!,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // App icon pill
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.floatingShadow,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.splitscreen,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Expense Splitter',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.midnightBlue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Split smartly, settle easily',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

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
                                  _buildInputField(
                                    context,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    label: 'Email',
                                    hint: 'you@example.com',
                                    icon: Icons.email_rounded,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                    nextFocus: _passwordFocus,
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  _buildInputField(
                                    context,
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    label: 'Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_rounded,
                                    isDark: isDark,
                                    obscure: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500],
                                        size: 22,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    onDone: _onLoginPressed,
                                  ),
                                  const SizedBox(height: 10),

                                  // Remember + Forgot row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Remember me
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _rememberMe = !_rememberMe,
                                        ),
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: _rememberMe
                                                    ? AppTheme.premiumPurple
                                                    : (isDark
                                                          ? const Color(
                                                              0xFF2D3748,
                                                            )
                                                          : Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: _rememberMe
                                                      ? AppTheme.premiumPurple
                                                      : (isDark
                                                            ? Colors.white
                                                                  .withAlpha(50)
                                                            : AppTheme
                                                                  .mutedLavender),
                                                  width: 1.8,
                                                ),
                                              ),
                                              child: _rememberMe
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.check_rounded,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Remember me',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Forgot password
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: navigate to forgot password
                                        },
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.premiumPurple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // ─── LOGIN BUTTON ───
                                  _GradientLoginButton(
                                    onPressed: _onLoginPressed,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ─── BOTTOM: Google + Sign Up ───
                    SlideTransition(
                      position: _bottomSlide,
                      child: FadeTransition(
                        opacity: _formOpacity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          child: Column(
                            children: [
                              // Divider with text
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.white.withAlpha(30)
                                          : Colors.grey.withAlpha(60),
                                      height: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'or continue with',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.white.withAlpha(30)
                                          : Colors.grey.withAlpha(60),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Google sign in
                              _GoogleButton(
                                isDark: isDark,
                                onPressed: _onGoogleSignIn,
                              ),

                              const SizedBox(height: 28),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.push(AuthRoutes.registrationPage);
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.premiumPurple,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  Widget _decorBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildInputField(
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

// ─── GRADIENT LOGIN BUTTON (with BLoC loading state) ───────────────────────
class _GradientLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientLoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev is AuthLoading || curr is AuthLoading,
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
                highlightColor: Colors.white.withAlpha(20),
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
                          'Sign In',
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

// ─── GOOGLE SIGN IN BUTTON ──────────────────────────────────────────────────
class _GoogleButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const _GoogleButton({required this.isDark, required this.onPressed});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev is AuthLoading || curr is AuthLoading,
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _pressed ? 0.96 : 1.0,
            _pressed ? 0.96 : 1.0,
            1.0,
          ),
          height: 52,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withAlpha(30)
                  : AppTheme.lightLavender,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(widget.isDark ? 30 : 12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : widget.onPressed,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              splashColor: AppTheme.premiumPurple.withAlpha(20),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppTheme.premiumPurple,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google SVG-style icon using a Text widget
                          // Replace with your google_sign_in icon asset if available
                          Icon(
                            Icons
                                .language, // placeholder — swap with google icon
                            color: AppTheme.premiumPurple,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.white
                                  : AppTheme.midnightBlue,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
