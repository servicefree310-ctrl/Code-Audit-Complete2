import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';

final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);

  final results = await Future.wait([
    dio.get(AppConstants.walletOverviewPath).catchError((_) => null),
    dio.get('${AppConstants.gainersLosersPath}?limit=5').catchError((_) => null),
    dio.get('${AppConstants.tickerPath}?limit=6').catchError((_) => null),
    dio.get('${AppConstants.walletBalancePath}').catchError((_) => null),
    dio.get('${AppConstants.depositHistoryPath}?limit=5').catchError((_) => null),
  ]);

  final overview = results[0]?.data as Map<String, dynamic>? ?? {};
  final gainersData = results[1]?.data as Map<String, dynamic>? ?? {};
  final tickers = (results[2]?.data as List?) ?? [];
  final balance = results[3]?.data as Map<String, dynamic>? ?? {};
  final transactions = (results[4]?.data as List?) ?? [];

  return {
    'totalBalance': overview['totalBalance'] ?? balance['totalUSDT'] ?? 0,
    'todayPnl': overview['todayPnl'] ?? 0,
    'todayPnlPercent': overview['todayPnlPercent'] ?? 0,
    'spotBalance': balance['spot'] ?? 0,
    'futuresBalance': balance['futures'] ?? 0,
    'earnBalance': balance['earn'] ?? 0,
    'gainers': gainersData['gainers'] ?? [],
    'losers': gainersData['losers'] ?? [],
    'tickers': tickers,
    'recentTransactions': transactions,
  };
});
