// lib/src/core/di/init_dependencies.main.dart

import 'package:get_it/get_it.dart';

import '../../feature/auth/data/service/auth_service.dart';
import '../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../analytics/analytics_service.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initAnalytics();
}

void _initAuth() {
  serviceLocator
    ..registerFactory(() => AuthService())
    ..registerFactory(
      () => AuthBloc(
        authRepository: serviceLocator(),
        analyticsService: serviceLocator(),
      ),
    );
}

void _initAnalytics() {
  serviceLocator.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(),
  );
}
