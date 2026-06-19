import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _theme = 'Dark';
  String _language = 'English';
  String _currency = 'USD';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _priceAlerts = true;
  bool _orderAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZebAppBar(title: 'Settings'),
      body: ListView(
        children: [
          _sectionHeader('Appearance'),
          _settingTile(
            icon: Icons.dark_mode_outlined,
            label: 'Theme',
            trailing: _DropdownChip(
              value: _theme,
              options: ['Dark', 'Light', 'System'],
              onChanged: (v) => setState(() => _theme = v),
            ),
          ),
          _settingTile(
            icon: Icons.language_rounded,
            label: 'Language',
            trailing: _DropdownChip(
              value: _language,
              options: ['English', 'Hindi', 'Spanish', 'Chinese', 'Arabic'],
              onChanged: (v) => setState(() => _language = v),
            ),
          ),
          _settingTile(
            icon: Icons.attach_money_rounded,
            label: 'Currency',
            trailing: _DropdownChip(
              value: _currency,
              options: ['USD', 'INR', 'EUR', 'GBP', 'BTC'],
              onChanged: (v) => setState(() => _currency = v),
            ),
          ),
          _sectionHeader('Notifications'),
          _switchTile(icon: Icons.notifications_outlined, label: 'Push Notifications',
              value: _pushNotifications, onChanged: (v) => setState(() => _pushNotifications = v)),
          _switchTile(icon: Icons.email_outlined, label: 'Email Notifications',
              value: _emailNotifications, onChanged: (v) => setState(() => _emailNotifications = v)),
          _switchTile(icon: Icons.show_chart_rounded, label: 'Price Alerts',
              value: _priceAlerts, onChanged: (v) => setState(() => _priceAlerts = v)),
          _switchTile(icon: Icons.receipt_outlined, label: 'Order Alerts',
              value: _orderAlerts, onChanged: (v) => setState(() => _orderAlerts = v)),
          _sectionHeader('Privacy & Data'),
          _linkTile(icon: Icons.delete_sweep_outlined, label: 'Clear Cache', onTap: () {}),
          _linkTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
          _linkTile(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
          _sectionHeader('Support'),
          _linkTile(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: () => context.push('/support')),
          _linkTile(icon: Icons.info_outline_rounded, label: 'About Zebvix', onTap: () {}),
          _linkTile(icon: Icons.star_outline_rounded, label: 'Rate the App', onTap: () {}),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _settingTile({required IconData icon, required String label, required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppTextStyles.body),
      trailing: trailing,
    );
  }

  Widget _switchTile({required IconData icon, required String label, required bool value, required void Function(bool) onChanged}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppTextStyles.body),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _linkTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String value;
  final List<String> options;
  final void Function(String) onChanged;
  const _DropdownChip({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: AppTextStyles.captionSemiBold,
        dropdownColor: AppColors.surface,
        isDense: true,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}
