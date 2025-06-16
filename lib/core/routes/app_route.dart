import 'package:go_router/go_router.dart';

import '../../features/daily-readings/presentation/screens/home_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/register/register_page.dart';
import '../../pages/register_update/register_update_page.dart';
import 'route_name.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/register-update',
      name: RouteNames.registerUpdate,
      builder: (context, state) => const RegisterUpdatePage(),
    ),
    GoRoute(
      path: '/home',
      name: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
