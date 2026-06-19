import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ZebAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool centerTitle;

  const ZebAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      centerTitle: centerTitle,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      automaticallyImplyLeading: showBack,
      title: titleWidget ??
          (title != null
              ? Text(title!, style: AppTextStyles.h4)
              : null),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.borderColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
