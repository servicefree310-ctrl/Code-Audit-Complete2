class AppConstants {
  AppConstants._();

  static const String appName = 'Zebvix';
  static const String appVersion = '1.0.0';

  // Base URLs — API is mounted at /api on the VPS
  static const String baseUrl = 'https://zebvix.com';
  static const String apiBaseUrl = 'https://zebvix.com/api'; // used by Dio
  static const String wsUrl = 'wss://zebvix.com/ws';

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String loginVerifyPath = '/auth/login/verify';
  static const String registerVerifyPath = '/auth/register/verify';
  static const String challengeSendPath = '/auth/challenge/send';
  static const String authPolicyPath = '/auth/policy';
  static const String verifyContactPath = '/auth/verify-contact';
  static const String logoutPath = '/auth/logout';
  static const String mePath = '/auth/me';

  // Legacy aliases kept for screen compatibility
  static const String verifyOtpPath = '/auth/login/verify';
  static const String resendOtpPath = '/auth/challenge/send';
  static const String verifyEmailPath = '/auth/verify-contact';
  static const String verifyPhonePath = '/auth/verify-contact';
  // No refresh-token endpoint on this backend (14-day session tokens).
  // Calls to this path will get 404 — AuthInterceptor clears session on 401.
  static const String refreshTokenPath = '/auth/me'; // safe no-op fallback

  // ── OTP ─────────────────────────────────────────────────────────────────
  static const String otpSendPath = '/otp/send';
  static const String otpVerifyPath = '/otp/verify';
  // Legacy aliases
  static const String forgotPasswordPath = '/otp/send';
  static const String resetPasswordPath = '/otp/verify';

  // ── Profile & Security ───────────────────────────────────────────────────
  static const String profilePath = '/auth/me';
  static const String updateProfilePath = '/security/me';
  static const String securityPath = '/security/me';
  static const String changePasswordPath = '/security/me';
  static const String deleteAccountPath = '/security/me';
  static const String loginPrefsPath = '/security/login-prefs';
  static const String setup2faPath = '/security/2fa/enable';
  static const String verify2faPath = '/security/2fa/enable';
  static const String disable2faPath = '/security/2fa/disable';
  static const String revokeSessionsPath = '/security/sessions/revoke-others';
  static const String sessionsPath = '/security/sessions/revoke-others';
  static const String apiKeysPath = '/account/api-keys';
  // These features not yet in backend — screen shows "coming soon" gracefully on 404
  static const String loginHistoryPath = '/auth/me';
  static const String antiPhishingPath = '/security/me';
  static const String withdrawWhitelistPath = '/security/me';

  // ── KYC ─────────────────────────────────────────────────────────────────
  static const String kycStatusPath = '/kyc/my';
  static const String kycSubmitPath = '/kyc/submit';
  static const String kycDocumentPath = '/kyc/submit';
  static const String kycSettingsPath = '/kyc/settings';

  // ── Markets (public v1 API) ──────────────────────────────────────────────
  static const String marketsPath = '/v1/markets';
  static const String tickerPath = '/v1/ticker';
  static const String tickerAllPath = '/v1/ticker/all';
  static const String coinDetailPath = '/v1/coin';
  static const String orderBookPath = '/v1/orderbook';
  static const String orderbookSymbolPath = '/orderbook';
  static const String recentTradesPath = '/v1/trades';
  static const String candlesPath = '/klines';
  static const String trendingPath = '/v1/markets/trending';
  static const String gainersPath = '/v1/markets/gainers';
  static const String losersPath = '/v1/markets/losers';
  // Legacy alias: screen calls gainersLosersPath — returns gainers (losers endpoint separate)
  static const String gainersLosersPath = '/v1/markets/gainers';
  static const String priceAlertsPath = '/alerts/me';
  static const String searchPath = '/v1/markets/search';

  // ── Wallet ───────────────────────────────────────────────────────────────
  static const String walletOverviewPath = '/wallets';
  static const String walletBalancePath = '/wallets';
  static const String depositAddressPath = '/deposit-address';
  static const String depositHistoryPath = '/crypto-deposits';
  static const String withdrawPath = '/crypto-withdrawals';
  static const String withdrawHistoryPath = '/crypto-withdrawals';
  static const String transferPath = '/transfer';
  static const String transferHistoryPath = '/transfers';
  static const String networkListPath = '/v1/networks';
  static const String withdrawFeesPath = '/v1/withdraw-fees';
  static const String depositFeesPath = '/v1/deposit-fees';
  // No address-book endpoint on backend yet
  static const String addressBookPath = '/wallets';

  // ── Spot Trading ─────────────────────────────────────────────────────────
  static const String spotOrderPath = '/orders';
  static const String spotOrdersPath = '/orders';
  static const String spotOpenOrdersPath = '/orders';       // add ?status=open at call site
  static const String spotOrderHistoryPath = '/orders';
  static const String spotTradeHistoryPath = '/trades';
  static const String spotCancelOrderPath = '/orders';      // append /:id/cancel at call site

  // ── Futures ──────────────────────────────────────────────────────────────
  static const String futuresOrderPath = '/orders';
  static const String futuresPositionsPath = '/futures/positions';
  static const String futuresOpenOrdersPath = '/orders';
  static const String futuresOrderHistoryPath = '/orders';
  static const String futuresFundingRatePath = '/v1/futures/funding-rate';
  static const String futuresMarketsPath = '/v1/futures/markets';
  static const String futuresContractsPath = '/v1/futures/contracts';
  static const String futuresLeveragePath = '/v1/futures/contracts'; // no exact match
  static const String futuresCancelOrderPath = '/orders';  // append /:id/cancel at call site

  // ── Earn ─────────────────────────────────────────────────────────────────
  static const String earnProductsPath = '/earn/products';
  static const String earnSubscribePath = '/earn/subscribe';
  static const String earnRedeemPath = '/earn/positions';   // append /:id/redeem at call site
  static const String earnPositionsPath = '/earn/positions';
  static const String earnHistoryPath = '/earn/positions';
  static const String earnPortfolioPath = '/earn/summary';
  static const String earnSummaryPath = '/earn/summary';

  // ── Auto Invest ──────────────────────────────────────────────────────────
  static const String autoInvestPlansPath = '/auto-invest/account';
  static const String autoInvestPortfolioPath = '/auto-invest/summary';
  static const String autoInvestAccountPath = '/auto-invest/account';
  static const String autoInvestSummaryPath = '/auto-invest/summary';
  static const String autoInvestDepositPath = '/auto-invest/deposit';
  static const String autoInvestWithdrawPath = '/auto-invest/withdraw';
  static const String autoInvestHistoryPath = '/auto-invest/trades';
  static const String autoInvestTradesPath = '/auto-invest/trades';

  // ── P2P ──────────────────────────────────────────────────────────────────
  static const String p2pOffersPath = '/p2p/offers';
  static const String p2pCreateOfferPath = '/p2p/offers';  // POST to same path
  static const String p2pOrdersPath = '/p2p/offers/mine';
  static const String p2pChatPath = '/p2p/orders';         // append /:id/messages at call site
  static const String p2pDisputePath = '/p2p/orders';      // append /:id/dispute at call site
  static const String p2pPaymentMethodsPath = '/p2p/payment-methods';
  static const String p2pMerchantPath = '/p2p/merchant';

  // ── Fiat / INR ───────────────────────────────────────────────────────────
  static const String fiatDepositPath = '/payments/inr/deposit';
  static const String fiatWithdrawPath = '/payments/inr/withdraw';
  static const String fiatHistoryPath = '/payments/inr/history';
  static const String fiatBankDetailsPath = '/payments/inr/bank-details';
  static const String bankListPath = '/payments/inr/bank-details';
  static const String fiatBalancePath = '/payments/inr/balance';
  static const String razorpayOrderPath = '/inr-deposits/razorpay/order';
  static const String razorpayVerifyPath = '/inr-deposits/razorpay/verify';
  // No add-bank endpoint — INR bank details are sent per-withdrawal request
  static const String addBankPath = '/payments/inr/bank-details';

  // ── Convert ──────────────────────────────────────────────────────────────
  static const String convertPreviewPath = '/convert/quote'; // legacy alias
  static const String convertQuotePath = '/convert/quote';
  static const String convertPath = '/convert/execute';
  static const String convertHistoryPath = '/convert/history';

  // ── Rewards & Referral ───────────────────────────────────────────────────
  static const String referralInfoPath = '/v1/referral/info';
  static const String referralHistoryPath = '/v1/referral/statistics';
  static const String referralStatisticsPath = '/v1/referral/statistics';
  // No tasks/coupons/check-in endpoints in backend yet — will return 404 gracefully
  static const String rewardsTasksPath = '/v1/referral/info';
  static const String rewardsCouponsPath = '/v1/referral/info';
  static const String dailyCheckInPath = '/v1/referral/info';
  static const String leaderboardPath = '/leagues';

  // ── AI Trading ───────────────────────────────────────────────────────────
  static const String aiDashboardPath = '/ai-trading/pnl-summary';
  static const String aiPlansPath = '/ai-trading/plans';
  static const String aiStrategiesPath = '/ai-trading/plans';
  static const String aiSubscriptionsPath = '/ai-trading/subscriptions';
  static const String aiSubscribePath = '/ai-trading/subscribe';
  static const String aiStartPath = '/ai-trading/subscribe';  // subscribe = start
  static const String aiStopPath = '/ai-trading/subscriptions'; // append /:id/cancel at call site
  static const String aiStatementPath = '/ai-trading/statement';
  static const String aiHistoryPath = '/ai-trading/statement';
  static const String aiPnlPath = '/ai-trading/pnl-summary';
  static const String aiSignalsPath = '/v1/ai/signals';

  // ── Copy Trading ─────────────────────────────────────────────────────────
  static const String copyTradersPath = '/copy/leaderboard';
  static const String copyFollowPath = '/copy/follow';
  static const String copyUnfollowPath = '/copy/relations'; // append /:id/stop at call site
  static const String copyMePath = '/copy/me/profile';
  static const String copyPortfolioPath = '/copy/me/profile';
  static const String copyHistoryPath = '/copy/me/following';
  static const String copyFollowingPath = '/copy/me/following';
  static const String copyFollowersPath = '/copy/me/followers';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notificationsPath = '/notifications/me';
  static const String notificationReadPath = '/notifications/me'; // append /:id/read at call site
  static const String notificationReadAllPath = '/notifications/me/read-all';
  static const String notificationUnreadCountPath = '/notifications/me/unread-count';
  static const String notificationPrefsPath = '/notifications/me'; // no prefs endpoint yet

  // ── Support ──────────────────────────────────────────────────────────────
  static const String supportTicketsPath = '/support/tickets';
  static const String createTicketPath = '/support/tickets'; // POST to same path
  static const String faqPath = '/support/faqs';
  static const String supportFaqPath = '/support/faqs';
  static const String supportThreadsPath = '/support/threads';

  // ── News & Content ───────────────────────────────────────────────────────
  static const String newsPath = '/content/news';
  static const String announcementsPath = '/content/announcements';
  static const String bannersPath = '/content/banners';
  static const String promotionsPath = '/content/promotions';
  static const String siteConfigPath = '/content/site-config';

  // ── Ledger / Finance ─────────────────────────────────────────────────────
  static const String ledgerPath = '/ledger';
  static const String ledgerSummaryPath = '/ledger/summary';

  // ── Exchange ─────────────────────────────────────────────────────────────
  static const String exchangeFeaturesPath = '/exchange/features';

  // ── Health ───────────────────────────────────────────────────────────────
  static const String healthPath = '/healthz';

  // ── Storage keys ─────────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  // refreshTokenKey kept for any legacy reads — storage now ignores writes to it
  static const String refreshTokenKey = 'access_token'; // points to same slot
  static const String userDataKey = 'user_data';
  static const String pinKey = 'pin_code';
  static const String biometricKey = 'biometric_enabled';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String currencyKey = 'currency';
  static const String onboardingKey = 'onboarding_done';

  // ── Pagination ───────────────────────────────────────────────────────────
  static const int pageSize = 20;

  // ── Cache durations ──────────────────────────────────────────────────────
  static const Duration marketCacheDuration = Duration(seconds: 30);
  static const Duration tickerCacheDuration = Duration(seconds: 5);

  // ── WebSocket events ─────────────────────────────────────────────────────
  static const String wsTicker = 'ticker';
  static const String wsOrderBook = 'orderbook';
  static const String wsTrades = 'trades';
  static const String wsCandles = 'candles';
  static const String wsPositions = 'positions';
  static const String wsOrders = 'orders';
  static const String wsBalance = 'balance';
  static const String wsNotification = 'notification';
}
