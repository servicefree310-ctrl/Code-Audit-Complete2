import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';

class SecurityCenterScreen extends ConsumerWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZebAppBar(title: 'Security Center'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSecurityScore(),
          const SizedBox(height: 20),
          _buildSection('Account Security', [
            _SecurityItem(icon: Icons.lock_outline_rounded, label: 'Change Password', status: 'Set', statusColor: AppColors.bullish, onTap: () {}),
            _SecurityItem(icon: Icons.pin_rounded, label: 'PIN Lock', status: 'Off', statusColor: AppColors.warning, onTap: () {}),
            _SecurityItem(icon: Icons.fingerprint_rounded, label: 'Biometric Login', status: 'On', statusColor: AppColors.bullish, onTap: () {}),
            _SecurityItem(icon: Icons.shield_outlined, label: '2FA Authentication', status: 'On', statusColor: AppColors.bullish, onTap: () => context.push('/2fa')),
          ]),
          _buildSection('Advanced Security', [
            _SecurityItem(icon: Icons.phishing_rounded, label: 'Anti-Phishing Code', status: 'Set', statusColor: AppColors.bullish, onTap: () {}),
            _SecurityItem(icon: Icons.devices_rounded, label: 'Login Devices', status: 'Manage', statusColor: AppColors.primary, onTap: () {}),
            _SecurityItem(icon: Icons.history_rounded, label: 'Login History', status: 'View', statusColor: AppColors.primary, onTap: () {}),
            _SecurityItem(icon: Icons.manage_accounts_rounded, label: 'Session Management', status: 'Manage', statusColor: AppColors.primary, onTap: () {}),
          ]),
          _buildSection('Withdrawal Security', [
            _SecurityItem(icon: Icons.location_on_outlined, label: 'Withdrawal Whitelist', status: 'Off', statusColor: AppColors.warning, onTap: () {}),
            _SecurityItem(icon: Icons.key_outlined, label: 'API Keys', status: 'Manage', statusColor: AppColors.primary, onTap: () => context.push('/api-keys')),
          ]),
        ],
      ),
    );
  }

  Widget _buildSecurityScore() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A2035), Color(0xFF1E2329)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70, height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: 0.7, backgroundColor: AppColors.surfaceLight, color: AppColors.bullish, strokeWidth: 6),
                Text('70', style: AppTextStyles.h4.copyWith(color: AppColors.bullish)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Security Score', style: AppTextStyles.h5),
            const SizedBox(height: 4),
            Text('Good. Enable 2FA and anti-phishing for max protection.', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: 0.7, backgroundColor: AppColors.surfaceLight, color: AppColors.bullish, borderRadius: BorderRadius.circular(4)),
          ])),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor, width: 0.5)),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;
  const _SecurityItem({required this.icon, required this.label, required this.status, required this.statusColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: AppTextStyles.micro.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
