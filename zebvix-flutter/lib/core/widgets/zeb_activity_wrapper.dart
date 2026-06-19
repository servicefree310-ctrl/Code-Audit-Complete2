import 'package:flutter/material.dart';
import 'zeb_status_modal.dart';
import '../errors/app_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════
//  Activity wrapper — wraps any async action with status UI
// ═══════════════════════════════════════════════════════════
// Usage:
//   await ZebActivity.run(
//     context,
//     loadingTitle: 'Placing order...',
//     successTitle: 'Order placed!',
//     action: () => apiClient.placeOrder(params),
//     onSuccess: (result) { /* use result */ },
//   );

class ZebActivity {
  static Future<T?> run<T>(
    BuildContext context, {
    required Future<T> Function() action,
    String loadingTitle = 'Processing...',
    String? loadingSubtitle,
    String successTitle = 'Done!',
    String? successSubtitle,
    String? errorTitle,
    bool showSuccess = true,
    bool autoDismissSuccess = true,
    Duration successDuration = const Duration(seconds: 2),
    void Function(T result)? onSuccess,
    void Function(Object error)? onError,
    VoidCallback? onRetry,
    List<String> processingSteps = const [],
  }) async {
    // Show loading modal
    if (processingSteps.isNotEmpty) {
      ZebStatus.processing(context, title: loadingTitle, subtitle: loadingSubtitle, steps: processingSteps);
    } else {
      ZebStatus.loading(context, title: loadingTitle, subtitle: loadingSubtitle);
    }

    try {
      final result = await action();

      // Dismiss loading
      if (context.mounted) ZebStatus.dismiss(context);

      // Show success
      if (showSuccess && context.mounted) {
        await ZebStatus.success(
          context,
          title: successTitle,
          subtitle: successSubtitle,
          autoDismiss: autoDismissSuccess ? successDuration : null,
        );
      }

      onSuccess?.call(result);
      return result;
    } catch (e) {
      // Dismiss loading
      if (context.mounted) ZebStatus.dismiss(context);

      // Derive error message
      String errTitle = errorTitle ?? 'Something went wrong';
      String? errSubtitle;

      if (e is AppException) {
        errSubtitle = e.message;
        if (e is _UnauthorizedException) errTitle = 'Session Expired';
        if (e is _NetworkException) {
          errTitle = 'Connection Error';
          errSubtitle = 'Check your internet connection and try again.';
        }
      } else {
        errSubtitle = e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString();
      }

      if (context.mounted) {
        await ZebStatus.error(
          context,
          title: errTitle,
          subtitle: errSubtitle,
          onRetry: onRetry,
        );
      }

      onError?.call(e);
      return null;
    }
  }

  // Shorthand for trading actions
  static Future<T?> trade<T>(
    BuildContext context, {
    required Future<T> Function() action,
    required String pair,
    required String side, // BUY / SELL
    void Function(T result)? onSuccess,
  }) {
    return run<T>(
      context,
      action: action,
      loadingTitle: 'Placing $side Order',
      loadingSubtitle: 'Submitting $pair order to exchange...',
      successTitle: '$side Order Placed!',
      successSubtitle: '$pair order submitted successfully',
      processingSteps: ['Validating balance', 'Submitting order', 'Confirming fill'],
      onSuccess: onSuccess,
    );
  }

  // Shorthand for withdrawal
  static Future<T?> withdraw<T>(
    BuildContext context, {
    required Future<T> Function() action,
    required String amount,
    required String coin,
    void Function(T result)? onSuccess,
  }) {
    return run<T>(
      context,
      action: action,
      loadingTitle: 'Processing Withdrawal',
      loadingSubtitle: 'Do not close the app...',
      successTitle: 'Withdrawal Sent!',
      successSubtitle: '$amount $coin sent successfully',
      processingSteps: ['Verifying address', 'Deducting balance', 'Broadcasting to network'],
      onSuccess: onSuccess,
    );
  }

  // Shorthand for KYC upload
  static Future<T?> kycUpload<T>(
    BuildContext context, {
    required Future<T> Function() action,
    void Function(T result)? onSuccess,
  }) {
    return run<T>(
      context,
      action: action,
      loadingTitle: 'Submitting KYC',
      loadingSubtitle: 'Uploading documents securely...',
      successTitle: 'KYC Submitted!',
      successSubtitle: 'Verification takes 1–3 business days',
      processingSteps: ['Encrypting documents', 'Uploading files', 'Creating verification request'],
      onSuccess: onSuccess,
    );
  }

  // Shorthand for P2P order
  static Future<T?> p2p<T>(
    BuildContext context, {
    required Future<T> Function() action,
    required String type, // BUY / SELL
    void Function(T result)? onSuccess,
  }) {
    return run<T>(
      context,
      action: action,
      loadingTitle: 'Creating P2P Order',
      successTitle: 'P2P Order Created!',
      successSubtitle: 'Waiting for counterparty to confirm',
      processingSteps: ['Checking availability', 'Reserving funds', 'Creating order'],
      onSuccess: onSuccess,
    );
  }

  // Shorthand for convert
  static Future<T?> convert<T>(
    BuildContext context, {
    required Future<T> Function() action,
    required String from,
    required String to,
    void Function(T result)? onSuccess,
  }) {
    return run<T>(
      context,
      action: action,
      loadingTitle: 'Converting $from → $to',
      successTitle: 'Conversion Complete!',
      successSubtitle: '$from converted to $to successfully',
      processingSteps: ['Fetching rate', 'Executing swap', 'Updating balance'],
      onSuccess: onSuccess,
    );
  }
}

// ─── Dummy type references to avoid import clash ─────────
typedef _NetworkException = Object;
typedef _UnauthorizedException = Object;
