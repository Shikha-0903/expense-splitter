import 'package:expense_splitter/src/feature/auth/presentation/pages/login_page.dart';
import 'package:expense_splitter/src/feature/auth/presentation/pages/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRoutes {
  static const String loginPage = '/login-page';
  static const String registrationPage = '/registration-page';

  static final routes = <GoRoute>[
    GoRoute(
      path: loginPage,
      name: 'login',
      pageBuilder: (context, state) => MaterialPage(child: const LoginPage()),
    ),
    GoRoute(
      path: registrationPage,
      name: 'registration',
      pageBuilder: (context, state) =>
          MaterialPage(child: const RegisterPage()),
    ),
  ];
}
