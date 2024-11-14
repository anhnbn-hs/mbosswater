import 'package:go_router/go_router.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/page/guarantee_activate_page.dart';
import 'package:mbosswater/features/home/home_page.dart';
import 'package:mbosswater/features/login/presentation/page/login_page.dart';
import 'package:mbosswater/features/qrcode_scanner/presentation/page/qrcode_scanner_page.dart';
import 'package:mbosswater/features/recovery/presentation/page/change_password_page.dart';
import 'package:mbosswater/features/recovery/presentation/page/forgot_password_page.dart';
import 'package:mbosswater/features/splash/presentation/page/splash_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => ChangePasswordPage(),
    ),
    GoRoute(
      path: '/ah',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const QrcodeScannerPage(),
    ),
    GoRoute(
      path: '/guarantee-active',
      builder: (context, state) {
        final data = state.extra as Product?;
        return GuaranteeActivatePage(product: data);
      },
    ),
  ],
);
