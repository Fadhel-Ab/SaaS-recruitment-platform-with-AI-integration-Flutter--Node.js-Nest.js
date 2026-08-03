import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/storage/web_token_storage.dart';
import 'package:frontend/features/applications/data/application_api.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/auth/bloc/auth_event.dart';
import 'package:frontend/features/availability/data/availability_api.dart';
import 'package:frontend/features/availability/data/availability_repository.dart';
import 'package:frontend/features/dashboard/data/dashboard_api.dart';
import 'package:frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:frontend/features/jobs/data/jobs_api.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';
import 'package:frontend/features/search/data/search_api.dart';
import 'package:frontend/features/search/data/search_repository.dart';

import 'app/app.dart';

import 'core/api/dio_client.dart';

import 'features/auth/data/api/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  final TokenStorage tokenStorage = kIsWeb
      ? WebTokenStorage()
      : SecureTokenStorage();

  final dioClient = DioClient(tokenStorage);
  final authApi = AuthApi(dioClient.dio);
  final jobsApi = JobsApi(dioClient.dio);
  final dashboardApi = DashboardApi(dioClient.dio);
  final applicationApi = ApplicationApi(dioClient.dio);
  final availabilityApi = AvailabilityApi(dioClient.dio);
  final searchApi = SearchApi(dioClient.dio);

  final availabilityRepository = AvailabilityRepository(availabilityApi);
  final searchRepository = SearchRepository(searchApi);

  // Auth
  final authRepository = AuthRepository(authApi, tokenStorage);
  // Jobs
  final jobsRepository = JobsRepository(jobsApi);
  // dashboard
  final dashboardRepository = DashboardRepository(dashboardApi);
  // Application
  final applicationRepository = ApplicationRepository(applicationApi);
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: jobsRepository),
        RepositoryProvider.value(value: applicationRepository),
        RepositoryProvider.value(value: dashboardRepository),
        RepositoryProvider.value(value: availabilityRepository),
        RepositoryProvider.value(value: searchRepository),
      ],

      child: BlocProvider(
        create: (_) =>
            AuthBloc(authRepository, tokenStorage)..add(const AuthStarted()),

        child: const RecruitmentApp(),
      ),
    ),
  );
}

/* void main() {
  final dioClient = DioClient();

  final TokenStorage tokenStorage = kIsWeb ? WebTokenStorage() : SecureTokenStorage();

  final authApi = AuthApi(dioClient.dio);
  final jobsApi = JobsApi(dioClient.dio);

final jobsRepository = JobsRepository(jobsApi);
  final authRepository = AuthRepository(authApi, tokenStorage);

  runApp(
    RepositoryProvider.value(
      value: authRepository,

      child: BlocProvider(
        create: (_) =>
            AuthBloc(authRepository, tokenStorage)..add(const AuthStarted()),

        child: const RecruitmentApp(),
      ),
    ),
    
  );
} */
