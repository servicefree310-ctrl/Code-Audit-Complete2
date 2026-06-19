import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════
//  MainShell — premium glassmorphism floating dock
//  Fixed: route-sync, correct index mapping, futures pair,
//         wallet tab added, animated active indicator
// ═══════════════════════════════════════════════════════════
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {

  // ─── Trade menu state ─────────────────────────────────────
  bool _tradeMenuOpen = false;
  late AnimationController _tradeMenuCtrl;
  late Animation<double> _tradeMenuFade;
  late Animation<double> _tradeMenuScale;
  late AnimationController _tradeRotCtrl;

  // ─── Nav tab config ───────────────────────────────────────
  // Shell routes must exactly match GoRouter ShellRoute children order
  // Visual layout: Home | Markets | [TRADE+] | Wallet | Profile
  static const _tabRoutes = ['/home', '/markets', '/wallet', '/profile'];
  // Index 2 = trade button (not a real tab) — maps outside tabRoutes

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,              label: 'Home',    index: 0),
    _NavItem(icon: Icons.candlestick_chart_outlined, activeIcon: Icons.candlestick_chart,     label: 'Markets', index: 1),
    _NavItem(icon: null,                         activeIcon: null,                             label: '',        index: 2), // trade btn
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Wallet', index: 3),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,            label: 'Profile', index: 4),
  ];

  @override
  void initState() {
    super.initState();

    _tradeMenuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _tradeMenuFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tradeMenuCtrl, curve: Curves.easeOut),
    );
    _tradeMenuScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _tradeMenuCtrl, curve: Curves.easeOutCubic),
    );

    _tradeRotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tradeMenuCtrl.dispose();
    _tradeRotCtrl.dispose();
    super.dispose();
  }

  // ─── Compute active index from current route ──────────────
  int _activeIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/markets') || location.startsWith('/coin')) return 1;
    if (location.startsWith('/wallet') || location.startsWith('/deposit') ||
        location.startsWith('/withdraw') || location.startsWith('/transfer')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/kyc') ||
        location.startsWith('/security') || location.startsWith('/2fa') ||
        location.startsWith('/settings')) return 4;
    // earn, p2p, convert etc. keep last active tab — default to home
    return 0;
  }

  void _onTabTap(int visualIndex, BuildContext ctx) {
    HapticFeedback.selectionClick();
    _closeTradeMenu();
    switch (visualIndex) {
      case 0: ctx.go('/home');
      case 1: ctx.go('/markets');
      case 3: ctx.go('/wallet');
      case 4: ctx.go('/profile');
    }
  }

  void _toggleTradeMenu() {
    HapticFeedback.mediumImpact();
    setState(() => _tradeMenuOpen = !_tradeMenuOpen);
    if (_tradeMenuOpen) {
      _tradeMenuCtrl.forward();
      _tradeRotCtrl.forward();
    } else {
      _tradeMenuCtrl.reverse();
      _tradeRotCtrl.reverse();
    }
  }

  void _closeTradeMenu() {
    if (_tradeMenuOpen) {
      setState(() => _tradeMenuOpen = false);
      _tradeMenuCtrl.reverse();
      _tradeRotCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tradeMenuOpen ? _closeTradeMenu : null,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: widget.child,
        bottomNavigationBar: _buildDock(context),
      ),
    );
  }

  // ─── Full dock builder ────────────────────────────────────
  Widget _buildDock(BuildContext context) {
    final activeIdx = _activeIndex(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trade quick-action popup
        if (_tradeMenuOpen)
          FadeTransition(
            opacity: _tradeMenuFade,
            child: ScaleTransition(
              scale: _tradeMenuScale,
              alignment: Alignment.bottomCenter,
              child: _buildTradeMenu(context),
            ),
          ),

        // Main floating dock
        _buildFloatingDock(context, activeIdx),
      ],
    );
  }

  Widget _buildFloatingDock(BuildContext context, int activeIdx) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E25).withOpacity(0.94),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.09),
                width: 1,
              ),
            ),
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  children: [
                    _buildTab(context, _navItems[0], activeIdx),
                    _buildTab(context, _navItems[1], activeIdx),
                    _buildTradeBtn(),
                    _buildTab(context, _navItems[3], activeIdx),
                    _buildTab(context, _navItems[4], activeIdx),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tab item ─────────────────────────────────────────────
  Widget _buildTab(BuildContext context, _NavItem item, int activeIdx) {
    // Map visual index to active check
    // Visual: 0=Home, 1=Markets, 3=Wallet, 4=Profile
    // Active logic:
    final isActive = switch (item.index) {
      0 => activeIdx == 0,
      1 => activeIdx == 1,
      3 => activeIdx == 3,
      4 => activeIdx == 4,
      _ => false,
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(item.index, context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with pill highlight
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isActive ? 46 : 32,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withOpacity(0.16) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isActive ? item.activeIcon! : item.icon!,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isActive ? 10.5 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                child: Text(item.label!),
              ),
              // Dot indicator
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isActive ? 5 : 0,
                height: isActive ? 5 : 0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Center trade button ──────────────────────────────────
  Widget _buildTradeBtn() {
    return SizedBox(
      width: 72,
      child: Center(
        child: GestureDetector(
          onTap: _toggleTradeMenu,
          child: AnimatedBuilder(
            animation: _tradeRotCtrl,
            builder: (_, __) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCD535), Color(0xFFE8B800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        _tradeMenuOpen ? 0.65 : 0.4,
                      ),
                      blurRadius: _tradeMenuOpen ? 22 : 14,
                      spreadRadius: _tradeMenuOpen ? 3 : 1,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: _tradeRotCtrl.value * 0.785398, // 45°
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF0B0E11),
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Trade popup menu ─────────────────────────────────────
  Widget _buildTradeMenu(BuildContext context) {
    const actions = [
      _TradeAction(
        icon: Icons.swap_horiz_rounded,
        label: 'Spot',
        sublabel: 'Buy & Sell',
        color: Color(0xFFFCD535),
        route: '/spot/BTCUSDT',
      ),
      _TradeAction(
        icon: Icons.trending_up_rounded,
        label: 'Futures',
        sublabel: 'Leverage',
        color: Color(0xFF4A90E2),
        route: '/futures/BTCUSDT',    // ← Fixed: must include pair
      ),
      _TradeAction(
        icon: Icons.currency_exchange_rounded,
        label: 'Convert',
        sublabel: 'Instant swap',
        color: Color(0xFF0ECB81),
        route: '/convert',
      ),
      _TradeAction(
        icon: Icons.people_alt_rounded,
        label: 'P2P',
        sublabel: 'Peer-to-peer',
        color: Color(0xFF9B59B6),
        route: '/p2p',
      ),
      _TradeAction(
        icon: Icons.auto_graph_rounded,
        label: 'AI Trade',
        sublabel: 'Smart bot',
        color: Color(0xFF1DA2B4),
        route: '/ai-trading',
      ),
      _TradeAction(
        icon: Icons.content_copy_rounded,
        label: 'Copy',
        sublabel: 'Follow pros',
        color: Color(0xFFE67E22),
        route: '/copy-trading',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E25).withOpacity(0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 4, height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Quick Trade', style: AppTextStyles.captionSemiBold.copyWith(
                  color: AppColors.textPrimary, fontSize: 12,
                )),
                const Spacer(),
                GestureDetector(
                  onTap: _closeTradeMenu,
                  child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // 2×3 grid of actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.take(3).map((a) => _buildTradeAction(context, a)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.skip(3).map((a) => _buildTradeAction(context, a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeAction(BuildContext context, _TradeAction action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _closeTradeMenu();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (context.mounted) context.push(action.route);
        });
      },
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.11),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: action.color.withOpacity(0.22)),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(action.label, style: AppTextStyles.captionSemiBold.copyWith(
              color: AppColors.textPrimary, fontSize: 11.5,
            )),
            Text(action.sublabel, style: AppTextStyles.micro.copyWith(
              color: AppColors.textHint, fontSize: 9.5,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────
class _NavItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String? label;
  final int index;
  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.index,
  });
}

class _TradeAction {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final String route;
  const _TradeAction({
    required this.icon, required this.label, required this.sublabel,
    required this.color, required this.route,
  });
}
