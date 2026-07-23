import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(

  initialLocation: '/login',

  routes: [

    GoRoute(
      path: '/login',

      builder: (
        context,
        state,
      ) {

        return const Scaffold(
          body: Center(
            child: Text(
              'Login Screen',
            ),
          ),
        );

      },
    ),

    GoRoute(
      path: '/dashboard',

      builder: (
        context,
        state,
      ) {

        return const Scaffold(
          body: Center(
            child: Text(
              'Dashboard',
            ),
          ),
        );

      },
    ),

  ],

);