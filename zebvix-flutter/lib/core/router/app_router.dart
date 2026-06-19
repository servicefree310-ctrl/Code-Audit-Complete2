import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/pin_screen.dart';
import '../../features/auth/presentation/screens/biometric_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/markets/presentation/screens/markets_screen.dart';
import '../../features/markets/presentation/screens/coin_detail_screen.dart';
import '../../features/spot_trading/presentation/screens/spot_trading_screen.dart';
import '../../features/futures/presentation/screens/futures_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/deposit_screen.dart';
import '../../features/wallet/presentation/screens/withdraw_screen.dart';
import '../../features/wallet/presentation/screens/transfer_screen.dart';
import '../../features/earn/presentation/screens/earn_screen.dart';
import '../../features/p2p/presentation/screens/p2p_screen.dart';
import '../../features/p2p/presentation/screens/p2p_order_detail_screen.dart';
import '../../features/convert/presentation/screens/convert_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/kyc_screen.dart';
import '../../features/profile/presentation/screens/security_center_screen.dart';
import '../../features/profile/presentation/screens/two_fa_screen.dart';
import '../../features/profile/presentation/screens/api_keys_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/support/presentation/screens/ticket_detail_screen.dart';
import '../../features/ai_trading/presentation/screens/ai_trading_screen.dart';
import '../../features/auto_invest/presentation/screens/auto_invest_screen.dart';
import '../../features/copy_trading/presentation/screens/copy_trading_screen.dart';
import '../../features/fiat/presentation/screens/fiat_screen.dart';
import '../../features/fiat/presentation/screens/bank_screen.dart';
import '../storage/secure_storage.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isLoggedIn = await secureStorage.isLoggedIn();
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth',
        redirect: (_, __) => '/auth/login',
        routes: [
          GoRoute(path: 'login', builder: (ctx, state) => const LoginScreen()),
          GoRoute(path: 'register', builder: (ctx, state) => const RegisterScreen()),
          GoRoute(path: 'forgot-password', builder: (ctx, state) => const ForgotPasswordScreen()),
          GoRoute(
            path: 'reset-password',
            builder: (ctx, state) {
              final token = state.uri.queryParameters['token'] ?? '';
              return ResetPasswordScreen(token: token);
            },
          ),
          GoRoute(
            path: 'otp',
            builder: (ctx, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return OtpVerificationScreen(
                email: extra?['email'] ?? '',
                type: extra?['type'] ?? 'email',
              );
            },
          ),
          GoRoute(path: 'pin', builder: (ctx, state) => const PinScreen()),
          GoRoute(path: 'biometric', builder: (ctx, state) => const BiometricScreen()),
        ],
      ),

      // Main app shell with floating dock
      // Dock tabs: Home | Markets | [Trade+] | Wallet | Profile
      // Earn is accessible via push from home quick actions (outside shell)
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/markets', builder: (_, __) => const MarketsScreen()),
          GoRoute(path: '/wallet',  builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Earn — outside shell (pushed as full-screen from home/markets)
      GoRoute(path: '/earn', builder: (_, __) => const EarnScreen()),

      // Futures — default pair redirect
      GoRoute(
        path: '/futures',
        redirect: (_, __) => '/futures/BTCUSDT',
      ),

      // Markets
      GoRoute(
        path: '/coin/:symbol',
        builder: (ctx, state) => CoinDetailScreen(symbol: state.pathParameters['symbol']!),
      ),

      // Trading
      GoRoute(
        path: '/spot/:pair',
        builder: (ctx, state) => SpotTradingScreen(pair: state.pathParameters['pair']!),
      ),
      GoRoute(
        path: '/futures/:pair',
        builder: (ctx, state) => FuturesScreen(pair: state.pathParameters['pair']!),
      ),

      // Wallet operations
      GoRoute(path: '/deposit', builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return DepositScreen(coin: extra?['coin']);
      }),
      GoRoute(path: '/withdraw', builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WithdrawScreen(coin: extra?['coin']);
      }),
      GoRoute(path: '/transfer', builder: (ctx, state) => const TransferScreen()),

      // P2P
      GoRoute(path: '/p2p', builder: (ctx, state) => const P2PScreen()),
      GoRoute(
        path: '/p2p/order/:id',
        builder: (ctx, state) => P2POrderDetailScreen(orderId: state.pathParameters['id']!),
      ),

      // Convert
      GoRoute(path: '/convert', builder: (ctx, state) => const ConvertScreen()),

      // Rewards
      GoRoute(path: '/rewards', builder: (ctx, state) => const RewardsScreen()),

      // Notifications
      GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsScreen()),

      // Profile & Security
      GoRoute(path: '/kyc', builder: (ctx, state) => const KycScreen()),
      GoRoute(path: '/security', builder: (ctx, state) => const SecurityCenterScreen()),
      GoRoute(path: '/2fa', builder: (ctx, state) => const TwoFaScreen()),
      GoRoute(path: '/api-keys', builder: (ctx, state) => const ApiKeysScreen()),

      // Settings
      GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),

      // Support
      GoRoute(path: '/support', builder: (ctx, state) => const SupportScreen()),
      GoRoute(
        path: '/support/ticket/:id',
        builder: (ctx, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!),
      ),

      // AI Trading
      GoRoute(path: '/ai-trading', builder: (ctx, state) => const AiTradingScreen()),

      // Auto Invest
      GoRoute(path: '/auto-invest', builder: (ctx, state) => const AutoInvestScreen()),

      // Copy Trading
      GoRoute(path: '/copy-trading', builder: (ctx, state) => const CopyTradingScreen()),

      // Fiat
      GoRoute(path: '/fiat', builder: (ctx, state) => const FiatScreen()),
      GoRoute(path: '/bank', builder: (ctx, state) => const BankScreen()),
    ],
  );
});
