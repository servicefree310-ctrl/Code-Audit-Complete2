import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';

final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);

  // Gainers and losers are separate endpoints — both return {"markets": [...]}
  // Tickers returns {"tickers": [...], "count": N, "ts": N}
  final results = await Future.wait([
    dio.get(AppConstants.walletOverviewPath).catchError((_) => null),
    dio.get('${AppConstants.gainersPath}?limit=5').catchError((_) => null),
    dio.get('${AppConstants.losersPath}?limit=5').catchError((_) => null),
    dio.get('${AppConstants.tickerPath}?limit=6').catchError((_) => null),
    dio.get('${AppConstants.depositHistoryPath}?limit=5').catchError((_) => null),
  ]);

  final overview = results[0]?.data as Map<String, dynamic>? ?? {};
  final gainersData = results[1]?.data as Map<String, dynamic>? ?? {};
  final losersData = results[2]?.data as Map<String, dynamic>? ?? {};
  final tickersData = results[3]?.data as Map<String, dynamic>?;
  final transactions = (results[4]?.data as List?) ?? [];

  return {
    'totalBalance': overview['totalBalance'] ?? 0,
    'todayPnl': overview['todayPnl'] ?? 0,
    'todayPnlPercent': overview['todayPnlPercent'] ?? 0,
    'spotBalance': overview['spot'] ?? 0,
    'futuresBalance': overview['futures'] ?? 0,
    'earnBalance': overview['earn'] ?? 0,
    // Both gainers and losers endpoints return {"markets": [...]}
    'gainers': (gainersData['markets'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    'losers': (losersData['markets'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    // Tickers endpoint returns {"tickers": [...], "count": N}
    'tickers': (tickersData?['tickers'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    'recentTransactions': transactions,
  };
});
