import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ═══════════════════════════════════════════════════════════
//  PerformanceConfig — called once in main()
//  Makes the app silky smooth, no jank, no hang
// ═══════════════════════════════════════════════════════════
class PerformanceConfig {
  PerformanceConfig._();

  static Future<void> initialize() async {
    // ── 1. Image cache size ──────────────────────────────
    PaintingBinding.instance.imageCache.maximumSize = 200;         // max 200 images
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

    // ── 2. Network image cache ───────────────────────────
    CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

    // ── 3. Shader warm-up (avoids first-frame jank) ──────
    // The engine pre-compiles shaders to avoid first-draw stutter
    // This is handled by --profile / --release builds automatically

    // ── 4. GC pressure reduction ─────────────────────────
    // Use const constructors everywhere (done in widget code)
    // Avoid creating objects in build() — use cached providers

    // ── 5. Scrolling physics ─────────────────────────────
    // Set globally smooth physics
    _setScrollBehavior();

    // ── 6. Disable debug overlays in release ─────────────
    if (kReleaseMode) {
      debugPrintRebuildDirtyWidgets = false;
      debugRepaintRainbowEnabled = false;
    }
  }

  static void _setScrollBehavior() {
    // Overscroll glow effect disabled (looks dated on dark themes)
    // Handled per-widget with ScrollConfiguration
  }

  // ── Run heavy computation off main thread ─────────────
  /// Use for: JSON parsing of large order books, chart data processing
  static Future<R> compute<Q, R>(
    ComputeCallback<Q, R> callback,
    Q message,
  ) {
    return flutter_compute(callback, message);
  }

  // ── Debounce helper (for search, price inputs) ─────────
  static Debouncer debounce(Duration delay) => Debouncer(delay: delay);

  // ── Throttle helper (for WebSocket ticks) ─────────────
  static Throttler throttle(Duration interval) => Throttler(interval: interval);
}

// ── Compute alias (avoids name conflict) ─────────────────────
Future<R> flutter_compute<Q, R>(ComputeCallback<Q, R> fn, Q msg) =>
    compute<Q, R>(fn, msg);

// ═══════════════════════════════════════════════════════════
//  Debouncer — delays rapid calls (search box, etc.)
// ═══════════════════════════════════════════════════════════
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();
  void dispose() => _timer?.cancel();
}

// ═══════════════════════════════════════════════════════════
//  Throttler — limits call rate (WebSocket price ticks)
// ═══════════════════════════════════════════════════════════
class Throttler {
  final Duration interval;
  DateTime? _lastRun;

  Throttler({required this.interval});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  SmoothScrollBehavior — removes overscroll glow
// ═══════════════════════════════════════════════════════════
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Remove the blue glow on Android
    return child;
  }
}

// ═══════════════════════════════════════════════════════════
//  ZebCachedImage — performant network image wrapper
// ═══════════════════════════════════════════════════════════
class ZebCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ZebCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildError();
    }

    Widget img = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => placeholder ?? _buildPlaceholder(),
      errorWidget: (_, __, ___) => errorWidget ?? _buildError(),
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    return img;
  }

  Widget _buildPlaceholder() => Container(
    width: width,
    height: height,
    color: const Color(0xFF2B3139),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFCD535),
        ),
      ),
    ),
  );

  Widget _buildError() => Container(
    width: width,
    height: height,
    color: const Color(0xFF2B3139),
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined,
          color: Color(0xFF848E9C), size: 20),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
//  IsolateProcessor — off-main-thread data processing
//  Use for: order book sorting, chart data, portfolio calc
// ═══════════════════════════════════════════════════════════
class IsolateProcessor {
  /// Sort & process order book data off main thread
  static Future<List<Map<String, dynamic>>> processOrderBook(
    List<Map<String, dynamic>> rawData,
  ) async {
    return await compute(_sortOrderBook, rawData);
  }

  static List<Map<String, dynamic>> _sortOrderBook(
    List<Map<String, dynamic>> data,
  ) {
    // Heavy processing off main isolate
    return List<Map<String, dynamic>>.from(data)
      ..sort((a, b) {
        final priceA = double.tryParse(a['price'].toString()) ?? 0;
        final priceB = double.tryParse(b['price'].toString()) ?? 0;
        return priceB.compareTo(priceA);
      });
  }

  /// Process portfolio chart data off main thread
  static Future<List<double>> processChartData(List<dynamic> rawData) async {
    return await compute(_extractChartPoints, rawData);
  }

  static List<double> _extractChartPoints(List<dynamic> data) {
    return data
        .map((e) => double.tryParse(e[1].toString()) ?? 0.0)
        .toList();
  }

  /// Calculate P&L off main thread
  static Future<Map<String, double>> calculatePortfolioPnL(
    Map<String, dynamic> params,
  ) async {
    return await compute(_calcPnL, params);
  }

  static Map<String, double> _calcPnL(Map<String, dynamic> params) {
    final positions = params['positions'] as List? ?? [];
    double totalValue = 0;
    double totalCost = 0;

    for (final pos in positions) {
      final qty = double.tryParse(pos['quantity'].toString()) ?? 0;
      final price = double.tryParse(pos['current_price'].toString()) ?? 0;
      final avgCost = double.tryParse(pos['avg_cost'].toString()) ?? 0;
      totalValue += qty * price;
      totalCost += qty * avgCost;
    }

    final pnl = totalValue - totalCost;
    final pnlPct = totalCost > 0 ? (pnl / totalCost) * 100 : 0;

    return {
      'total_value': totalValue,
      'total_cost': totalCost,
      'pnl': pnl,
      'pnl_pct': pnlPct.toDouble(),
    };
  }
}

// ═══════════════════════════════════════════════════════════
//  MemoryManager — clear caches on low memory
// ═══════════════════════════════════════════════════════════
class MemoryManager with WidgetsBindingObserver {
  static final MemoryManager _instance = MemoryManager._();
  factory MemoryManager() => _instance;
  MemoryManager._();

  void init() => WidgetsBinding.instance.addObserver(this);
  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didHaveMemoryPressure() {
    // Clear image cache on low memory
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint('ZebMemory: cleared image cache due to memory pressure');
  }
}
