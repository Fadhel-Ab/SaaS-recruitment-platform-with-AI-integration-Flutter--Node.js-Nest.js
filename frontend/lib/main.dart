import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/storage/web_token_storage.dart';
import 'package:frontend/features/auth/bloc/auth_event.dart';
import 'package:frontend/features/jobs/data/jobs_api.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';

import 'app/app.dart';

import 'core/api/dio_client.dart';

import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  final dioClient = DioClient();

  final TokenStorage tokenStorage = kIsWeb
      ? WebTokenStorage()
      : SecureTokenStorage();

  // Auth
  final authApi = AuthApi(dioClient.dio);

  final authRepository = AuthRepository(authApi, tokenStorage);

  // Jobs
  final jobsApi = JobsApi(dioClient.dio);

  final jobsRepository = JobsRepository(jobsApi);

  runApp(
    RepositoryProvider(
      create: (_) => authRepository,

      child: RepositoryProvider(
        create: (_) => jobsRepository,

        child: BlocProvider(
          create: (_) =>
              AuthBloc(authRepository, tokenStorage)..add(const AuthStarted()),

          child: const RecruitmentApp(),
        ),
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
