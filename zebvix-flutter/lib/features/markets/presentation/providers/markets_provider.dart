import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class MarketsState {
  final bool isLoading;
  final List<Map<String, dynamic>> coins;
  final String? error;

  const MarketsState({
    this.isLoading = false,
    this.coins = const [],
    this.error,
  });
}

class MarketsNotifier extends StateNotifier<MarketsState> {
  final Ref _ref;
  MarketsNotifier(this._ref) : super(const MarketsState());

  Future<List<Map<String, dynamic>>> fetchMarkets({
    required int page,
    int category = 0,
    String search = '',
    String sortBy = 'volume',
  }) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      AppConstants.marketsPath,
      queryParameters: {
        'page': page,
        'limit': 20,
        if (search.isNotEmpty) 'search': search,
        'sortBy': sortBy,
        if (category > 0) 'category': ['all', 'spot', 'futures', 'etf', 'watch'][category],
      },
    );
    final data = response.data;
    // API returns {"markets": [...], "count": N, "ts": N}
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['markets'] is List) {
      return (data['markets'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}

final marketsProvider = StateNotifierProvider<MarketsNotifier, MarketsState>((ref) {
  return MarketsNotifier(ref);
});
