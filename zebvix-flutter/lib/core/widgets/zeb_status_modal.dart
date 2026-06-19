import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════
//  Status Type
// ═══════════════════════════════════════════════════════════
enum ZebStatusType {
  loading,
  success,
  error,
  warning,
  info,
  processing,
}

// ═══════════════════════════════════════════════════════════
//  Static helper — show modal from anywhere
// ═══════════════════════════════════════════════════════════
class ZebStatus {
  // Show non-dismissible loading
  static Future<void> loading(
    BuildContext context, {
    String title = 'Please wait...',
    String? subtitle,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.loading,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  // Dismiss current modal
  static void dismiss(BuildContext context) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  // Show success then auto-dismiss
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onDone,
    Duration autoDismiss = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.success,
        title: title,
        subtitle: subtitle,
        autoDismiss: autoDismiss,
        onDone: onDone,
      ),
    );
  }

  // Show error with retry option
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? retryLabel,
    VoidCallback? onRetry,
    VoidCallback? onDone,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.error,
        title: title,
        subtitle: subtitle,
        retryLabel: retryLabel ?? 'Try Again',
        onRetry: onRetry,
        onDone: onDone,
      ),
    );
  }

  // Show warning with confirm
  static Future<bool> warning(
    BuildContext context, {
    required String title,
    String? subtitle,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.warning,
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return result ?? false;
  }

  // Show info
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onDone,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.info,
        title: title,
        subtitle: subtitle,
        onDone: onDone,
      ),
    );
  }

  // Show processing with custom steps
  static Future<void> processing(
    BuildContext context, {
    String title = 'Processing...',
    String? subtitle,
    List<String> steps = const [],
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZebStatusModal(
        type: ZebStatusType.processing,
        title: title,
        subtitle: subtitle,
        steps: steps,
      ),
    );
  }

  // ─── Convenience wrappers for common crypto exchange activities ───

  static Future<void> orderPlacing(BuildContext context) =>
      loading(context, title: 'Placing Order...', subtitle: 'Submitting to exchange');

  static Future<void> orderSuccess(BuildContext context, {required String pair, required String side}) =>
      success(context, title: 'Order Placed!', subtitle: '$side order for $pair submitted successfully');

  static Future<void> withdrawalProcessing(BuildContext context) =>
      loading(context, title: 'Processing Withdrawal', subtitle: 'Please do not close the app');

  static Future<void> withdrawalSuccess(BuildContext context, {required String amount, required String coin}) =>
      success(context, title: 'Withdrawal Sent!', subtitle: '$amount $coin sent successfully');

  static Future<void> depositDetected(BuildContext context, {required String amount, required String coin}) =>
      success(context, title: 'Deposit Received!', subtitle: '$amount $coin confirmed');

  static Future<void> kycSubmitting(BuildContext context) =>
      loading(context, title: 'Submitting KYC', subtitle: 'Uploading documents securely...');

  static Future<void> kycSuccess(BuildContext context) =>
      success(context, title: 'KYC Submitted!', subtitle: 'Verification usually takes 1–3 business days');

  static Future<void> loginLoading(BuildContext context) =>
      loading(context, title: 'Signing in...', subtitle: 'Verifying your credentials');

  static Future<void> biometricAuth(BuildContext context) =>
      loading(context, title: 'Authenticating', subtitle: 'Use your fingerprint or Face ID');

  static Future<void> networkError(BuildContext context, {VoidCallback? onRetry}) =>
      error(context, title: 'Connection Failed', subtitle: 'Please check your internet connection', onRetry: onRetry);

  static Future<void> sessionExpired(BuildContext context) =>
      error(context, title: 'Session Expired', subtitle: 'Please log in again');

  static Future<bool> confirmWithdrawal(BuildContext context, {required String amount, required String address}) =>
      warning(context, title: 'Confirm Withdrawal', subtitle: 'Send $amount to ${address.substring(0,8)}...? This cannot be undone.');

  static Future<bool> confirm2FA(BuildContext context) =>
      warning(context, title: '2FA Required', subtitle: 'This action requires two-factor authentication.');

  static Future<void> convertSuccess(BuildContext context, {required String from, required String to}) =>
      success(context, title: 'Conversion Complete!', subtitle: '$from converted to $to successfully');

  static Future<void> copyTradingStarted(BuildContext context, {required String trader}) =>
      success(context, title: 'Copy Trading Started', subtitle: 'Now copying trades from $trader');

  static Future<void> transferSuccess(BuildContext context) =>
      success(context, title: 'Transfer Successful!', subtitle: 'Funds moved between your accounts');

  static Future<void> p2pOrderCreated(BuildContext context) =>
      success(context, title: 'P2P Order Created!', subtitle: 'Waiting for counterparty to confirm');
}

// ═══════════════════════════════════════════════════════════
//  Main Modal Widget
// ═══════════════════════════════════════════════════════════
class ZebStatusModal extends StatefulWidget {
  final ZebStatusType type;
  final String title;
  final String? subtitle;
  final Duration? autoDismiss;
  final VoidCallback? onDone;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final String? confirmLabel;
  final String? cancelLabel;
  final List<String> steps;

  const ZebStatusModal({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    this.autoDismiss,
    this.onDone,
    this.onRetry,
    this.retryLabel,
    this.confirmLabel,
    this.cancelLabel,
    this.steps = const [],
  });

  @override
  State<ZebStatusModal> createState() => _ZebStatusModalState();
}

class _ZebStatusModalState extends State<ZebStatusModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    if (widget.autoDismiss != null) {
      Future.delayed(widget.autoDismiss!, () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          widget.onDone?.call();
        }
      });
    }

    if (widget.type == ZebStatusType.processing && widget.steps.isNotEmpty) {
      _animateSteps();
    }
  }

  void _animateSteps() async {
    for (int i = 0; i < widget.steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _currentStep = i + 1);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Icon ────────────────────────────────────────────────
  Widget _buildIcon() {
    switch (widget.type) {
      case ZebStatusType.loading:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Transform.scale(
            scale: 0.9 + 0.1 * _pulseController.value,
            child: const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
        );
      case ZebStatusType.success:
        return ZoomIn(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bullish.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bullish, width: 2),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.bullish, size: 36),
          ),
        );
      case ZebStatusType.error:
        return ShakeX(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bearish.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bearish, width: 2),
            ),
            child: const Icon(Icons.close_rounded, color: AppColors.bearish, size: 36),
          ),
        );
      case ZebStatusType.warning:
        return ZoomIn(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning, width: 2),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 36),
          ),
        );
      case ZebStatusType.info:
        return ZoomIn(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 36),
          ),
        );
      case ZebStatusType.processing:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1 + 0.1 * _pulseController.value),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5 + 0.5 * _pulseController.value),
                width: 2,
              ),
            ),
            child: const Icon(Icons.sync_rounded, color: AppColors.primary, size: 36),
          ),
        );
    }
  }

  // ─── Steps list (processing mode) ───────────────────────
  Widget _buildSteps() {
    if (widget.steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.steps.length, (i) {
        final isDone = i < _currentStep;
        final isCurrent = i == _currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.bullish
                      : isCurrent
                          ? AppColors.primary
                          : AppColors.surface2,
                  border: Border.all(
                    color: isDone
                        ? AppColors.bullish
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.textTertiary,
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : isCurrent
                        ? const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : null,
              ),
              const SizedBox(width: 10),
              Text(
                widget.steps[i],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDone
                      ? AppColors.bullish
                      : isCurrent
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── Action buttons ──────────────────────────────────────
  Widget _buildActions() {
    switch (widget.type) {
      case ZebStatusType.loading:
      case ZebStatusType.processing:
        return const SizedBox.shrink();

      case ZebStatusType.success:
        if (widget.autoDismiss != null) return const SizedBox.shrink();
        return _primaryButton(
          label: 'Done',
          onTap: () {
            Navigator.of(context).pop();
            widget.onDone?.call();
          },
        );

      case ZebStatusType.error:
        return Column(
          children: [
            if (widget.onRetry != null)
              _primaryButton(
                label: widget.retryLabel ?? 'Try Again',
                color: AppColors.bearish,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onRetry?.call();
                },
              ),
            const SizedBox(height: 10),
            _ghostButton(
              label: 'Dismiss',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        );

      case ZebStatusType.warning:
        return Row(
          children: [
            Expanded(
              child: _ghostButton(
                label: widget.cancelLabel ?? 'Cancel',
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton(
                label: widget.confirmLabel ?? 'Confirm',
                color: AppColors.warning,
                onTap: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );

      case ZebStatusType.info:
        return _primaryButton(
          label: 'Got it',
          onTap: () {
            Navigator.of(context).pop();
            widget.onDone?.call();
          },
        );
    }
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }

  Widget _ghostButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: FadeInUp(
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              _buildIcon(),
              const SizedBox(height: 20),

              // Title
              Text(
                widget.title,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),

              // Subtitle
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Steps (processing mode)
              if (widget.steps.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSteps(),
              ],

              // Actions
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Inline snackbar-style toast (no dialog — lightweight)
// ═══════════════════════════════════════════════════════════
class ZebToast {
  static void show(
    BuildContext context, {
    required String message,
    ZebStatusType type = ZebStatusType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = {
      ZebStatusType.success: AppColors.bullish,
      ZebStatusType.error: AppColors.bearish,
      ZebStatusType.warning: AppColors.warning,
      ZebStatusType.info: AppColors.primary,
      ZebStatusType.loading: AppColors.textSecondary,
      ZebStatusType.processing: AppColors.primary,
    };
    final icons = {
      ZebStatusType.success: Icons.check_circle_rounded,
      ZebStatusType.error: Icons.error_rounded,
      ZebStatusType.warning: Icons.warning_amber_rounded,
      ZebStatusType.info: Icons.info_rounded,
      ZebStatusType.loading: Icons.hourglass_top_rounded,
      ZebStatusType.processing: Icons.sync_rounded,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors[type]!.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icons[type], color: colors[type], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ZebStatusType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: ZebStatusType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: ZebStatusType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: ZebStatusType.info);
}
