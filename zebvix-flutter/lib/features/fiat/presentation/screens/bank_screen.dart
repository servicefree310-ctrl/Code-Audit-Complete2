import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeb_app_bar.dart';
import '../../../../core/widgets/zeb_button.dart';

class BankScreen extends ConsumerStatefulWidget {
  const BankScreen({super.key});

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  List<Map<String, dynamic>> _banks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(AppConstants.bankListPath);
      final data = response.data;
      setState(() {
        if (data is List) _banks = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ZebAppBar(
        title: 'Banking',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showAddBankSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _banks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_outlined, color: AppColors.textHint, size: 64),
                      const SizedBox(height: 12),
                      Text('No bank accounts added', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ZebButton(label: 'Add Bank Account', onPressed: _showAddBankSheet, isFullWidth: false),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _banks.length,
                  itemBuilder: (_, i) => _BankCard(
                    bank: _banks[i],
                    onSetPrimary: () {},
                    onDelete: () {},
                  ),
                ),
    );
  }

  void _showAddBankSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddBankSheet(onAdd: (data) async {
        try {
          final dio = ref.read(dioProvider);
          await dio.post(AppConstants.addBankPath, data: data);
          if (mounted) { Navigator.pop(context); _fetchBanks(); }
        } catch (_) {}
      }),
    );
  }
}

class _BankCard extends StatelessWidget {
  final Map<String, dynamic> bank;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  const _BankCard({required this.bank, required this.onSetPrimary, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isPrimary = bank['isPrimary'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPrimary ? AppColors.primary.withOpacity(0.3) : AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bank['bankName']?.toString() ?? '', style: AppTextStyles.bodySemiBold),
            Text('AC: ${bank['accountNumber']?.toString() ?? ''}', style: AppTextStyles.caption),
            Text('IFSC: ${bank['ifsc']?.toString() ?? ''}', style: AppTextStyles.micro),
          ])),
          Column(children: [
            if (isPrimary) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('Primary', style: AppTextStyles.micro.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ) else TextButton(onPressed: onSetPrimary, child: Text('Set Primary', style: AppTextStyles.micro.copyWith(color: AppColors.primary))),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18), onPressed: onDelete),
          ]),
        ],
      ),
    );
  }
}

class _AddBankSheet extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onAdd;
  const _AddBankSheet({required this.onAdd});

  @override
  State<_AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends State<_AddBankSheet> {
  final _bankNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Bank Account', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            TextField(controller: _bankNameCtrl, style: AppTextStyles.body,
                decoration: const InputDecoration(labelText: 'Bank Name')),
            const SizedBox(height: 10),
            TextField(controller: _accountCtrl, style: AppTextStyles.body, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Account Number')),
            const SizedBox(height: 10),
            TextField(controller: _ifscCtrl, style: AppTextStyles.body,
                decoration: const InputDecoration(labelText: 'IFSC Code')),
            const SizedBox(height: 10),
            TextField(controller: _nameCtrl, style: AppTextStyles.body,
                decoration: const InputDecoration(labelText: 'Account Holder Name')),
            const SizedBox(height: 16),
            ZebButton(
              label: 'Add Bank',
              isLoading: _isSubmitting,
              onPressed: () async {
                setState(() => _isSubmitting = true);
                await widget.onAdd({
                  'bankName': _bankNameCtrl.text,
                  'accountNumber': _accountCtrl.text,
                  'ifsc': _ifscCtrl.text,
                  'holderName': _nameCtrl.text,
                });
                setState(() => _isSubmitting = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
