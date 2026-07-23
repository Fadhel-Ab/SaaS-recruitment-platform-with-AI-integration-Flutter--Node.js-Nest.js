import 'package:flutter/material.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';

class RecruitmentApp extends StatelessWidget {
  const RecruitmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recruitment Platform',

      theme: AppTheme.light,

      routerConfig: appRouter,

      debugShowCheckedModeBanner: false,
    );
  }
}