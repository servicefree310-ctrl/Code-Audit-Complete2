import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String price(double value, {int decimals = 2, String? currency}) {
    if (value >= 1000) {
      return NumberFormat('#,##0.${List.filled(decimals, '0').join()}').format(value);
    } else if (value >= 1) {
      return NumberFormat('0.${List.filled(decimals, '0').join()}').format(value);
    } else if (value >= 0.01) {
      return NumberFormat('0.0000').format(value);
    } else {
      return NumberFormat('0.00000000').format(value);
    }
  }

  static String compact(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }

  static String percent(double value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String crypto(double value, String symbol) {
    final formatted = value >= 1
        ? value.toStringAsFixed(4)
        : value.toStringAsFixed(8);
    return '$formatted $symbol';
  }

  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  static String dateTime(DateTime dt) => DateFormat('MMM d, yyyy HH:mm').format(dt);

  static String time(DateTime dt) => DateFormat('HH:mm:ss').format(dt);

  static String shortDate(DateTime dt) => DateFormat('MM/dd').format(dt);

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return date(dt);
  }

  static String truncateAddress(String address, {int chars = 6}) {
    if (address.length <= chars * 2) return address;
    return '${address.substring(0, chars)}...${address.substring(address.length - chars)}';
  }

  static String orderSide(String side) => side.toUpperCase();

  static String mask(String value, {int visible = 4}) {
    if (value.length <= visible) return value;
    return '${'*' * (value.length - visible)}${value.substring(value.length - visible)}';
  }
}
