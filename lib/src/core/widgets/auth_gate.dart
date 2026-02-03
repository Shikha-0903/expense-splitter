import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/core/router/all/auth_routes.dart';
import 'package:expense_splitter/src/core/router/all/home_routes.dart';
import 'package:expense_splitter/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth/presentation/bloc/auth_state.dart';

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is logged in, navigate to home/dashboard
          if (context.mounted) {
            context.go(HomeRoutes.dashBoardPage);
          }
        } else if (state is AuthUnauthenticated) {
          // User is logged out, navigate to login
          if (context.mounted) {
            context.go(AuthRoutes.loginPage);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            // User is authenticated, show the home content
            return child;
          } else if (state is AuthLoading) {
            // Show loading while checking auth status
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // User is unauthenticated or error, redirect to login
            Future.microtask(() {
              if (context.mounted) {
                context.go(AuthRoutes.loginPage);
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
