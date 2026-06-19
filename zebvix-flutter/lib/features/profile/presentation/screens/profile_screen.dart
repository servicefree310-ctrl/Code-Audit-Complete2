import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await ref.read(secureStorageProvider).getUserData();
    setState(() => _userData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A2035), Color(0xFF0B0E11)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              child: Text(
                                (_userData?['name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userData?['name']?.toString() ?? 'User',
                                      style: AppTextStyles.h4),
                                  Text(_userData?['email']?.toString() ?? '',
                                      style: AppTextStyles.caption),
                                  const SizedBox(height: 4),
                                  _kycBadge(_userData?['kycLevel']?.toString() ?? '0'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatBadge(label: 'UID', value: _userData?['uid']?.toString() ?? '--'),
                            const SizedBox(width: 16),
                            _StatBadge(label: 'Referrals', value: _userData?['referrals']?.toString() ?? '0'),
                            const SizedBox(width: 16),
                            _StatBadge(label: 'Level', value: 'VIP ${_userData?['vipLevel'] ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSection('Account', [
                _MenuItem(icon: Icons.person_outline_rounded, label: 'Personal Info', onTap: () {}),
                _MenuItem(icon: Icons.verified_user_outlined, label: 'KYC Verification',
                    badge: _userData?['kycLevel']?.toString() ?? 'L0',
                    badgeColor: AppColors.warning, onTap: () => context.push('/kyc')),
                _MenuItem(icon: Icons.account_balance_outlined, label: 'Banking', onTap: () => context.push('/bank')),
                _MenuItem(icon: Icons.card_giftcard_rounded, label: 'Referral & Rewards',
                    onTap: () => context.push('/rewards')),
              ]),
              _buildSection('Security', [
                _MenuItem(icon: Icons.security_rounded, label: 'Security Center',
                    onTap: () => context.push('/security')),
                _MenuItem(icon: Icons.shield_outlined, label: '2FA Settings',
                    badge: 'On', badgeColor: AppColors.bullish, onTap: () => context.push('/2fa')),
                _MenuItem(icon: Icons.key_outlined, label: 'API Keys', onTap: () => context.push('/api-keys')),
                _MenuItem(icon: Icons.phone_iphone_outlined, label: 'Login Devices', onTap: () {}),
              ]),
              _buildSection('Trading', [
                _MenuItem(icon: Icons.auto_graph_rounded, label: 'AI Trading', onTap: () => context.push('/ai-trading')),
                _MenuItem(icon: Icons.people_alt_outlined, label: 'Copy Trading', onTap: () => context.push('/copy-trading')),
                _MenuItem(icon: Icons.savings_outlined, label: 'Auto Invest', onTap: () => context.push('/auto-invest')),
              ]),
              _buildSection('Preferences', [
                _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push('/settings')),
                _MenuItem(icon: Icons.headset_mic_outlined, label: 'Support', onTap: () => context.push('/support')),
                _MenuItem(icon: Icons.info_outline_rounded, label: 'About Zebvix', onTap: () {}),
              ]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _kycBadge(String level) {
    final colors = {'0': AppColors.error, '1': AppColors.warning, '2': AppColors.bullish};
    final labels = {'0': 'Unverified', '1': 'Basic KYC', '2': 'Advanced KYC'};
    final color = colors[level] ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(labels[level] ?? 'Unverified',
          style: AppTextStyles.micro.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro),
        Text(value, style: AppTextStyles.captionSemiBold),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.badge, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              if (badge != null) Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge!, style: AppTextStyles.micro.copyWith(color: badgeColor ?? AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
