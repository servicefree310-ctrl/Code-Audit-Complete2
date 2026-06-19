class AppConstants {
  AppConstants._();

  static const String appName = 'Zebvix';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://zebvix.com';
  static const String wsUrl = 'wss://zebvix.com/ws';

  // API paths
  static const String apiPrefix = '/api';

  // Auth
  static const String loginPath = '/user/login';
  static const String registerPath = '/user/register';
  static const String forgotPasswordPath = '/user/forgot-password';
  static const String resetPasswordPath = '/user/reset-password';
  static const String verifyOtpPath = '/user/verify-otp';
  static const String resendOtpPath = '/user/resend-otp';
  static const String verifyEmailPath = '/user/verify-email';
  static const String verifyPhonePath = '/user/verify-phone';
  static const String refreshTokenPath = '/user/refresh-token';
  static const String logoutPath = '/user/logout';
  static const String googleLoginPath = '/user/google-login';
  static const String appleLoginPath = '/user/apple-login';

  // Profile
  static const String profilePath = '/user/profile';
  static const String updateProfilePath = '/user/profile/update';
  static const String changePasswordPath = '/user/change-password';
  static const String deleteAccountPath = '/user/delete-account';

  // KYC
  static const String kycStatusPath = '/user/kyc/status';
  static const String kycSubmitPath = '/user/kyc/submit';
  static const String kycDocumentPath = '/user/kyc/document';

  // Security
  static const String setup2faPath = '/user/2fa/setup';
  static const String verify2faPath = '/user/2fa/verify';
  static const String disable2faPath = '/user/2fa/disable';
  static const String apiKeysPath = '/user/api-keys';
  static const String loginHistoryPath = '/user/login-history';
  static const String sessionsPath = '/user/sessions';
  static const String antiPhishingPath = '/user/anti-phishing';
  static const String withdrawWhitelistPath = '/user/withdraw-whitelist';

  // Markets
  static const String marketsPath = '/market/list';
  static const String tickerPath = '/market/ticker';
  static const String coinDetailPath = '/market/coin';
  static const String orderBookPath = '/market/orderbook';
  static const String recentTradesPath = '/market/trades';
  static const String candlesPath = '/market/candles';
  static const String trendingPath = '/market/trending';
  static const String gainersLosersPath = '/market/gainers-losers';
  static const String priceAlertsPath = '/market/price-alerts';

  // Wallet
  static const String walletOverviewPath = '/wallet/overview';
  static const String walletBalancePath = '/wallet/balance';
  static const String depositAddressPath = '/wallet/deposit/address';
  static const String depositHistoryPath = '/wallet/deposit/history';
  static const String withdrawPath = '/wallet/withdraw';
  static const String withdrawHistoryPath = '/wallet/withdraw/history';
  static const String transferPath = '/wallet/transfer';
  static const String transferHistoryPath = '/wallet/transfer/history';
  static const String addressBookPath = '/wallet/address-book';
  static const String networkListPath = '/wallet/networks';

  // Spot Trading
  static const String spotOrderPath = '/trading/spot/order';
  static const String spotOrdersPath = '/trading/spot/orders';
  static const String spotOpenOrdersPath = '/trading/spot/orders/open';
  static const String spotOrderHistoryPath = '/trading/spot/orders/history';
  static const String spotTradeHistoryPath = '/trading/spot/trades';
  static const String spotCancelOrderPath = '/trading/spot/order/cancel';

  // Futures
  static const String futuresOrderPath = '/trading/futures/order';
  static const String futuresPositionsPath = '/trading/futures/positions';
  static const String futuresOpenOrdersPath = '/trading/futures/orders/open';
  static const String futuresOrderHistoryPath = '/trading/futures/orders/history';
  static const String futuresFundingRatePath = '/trading/futures/funding-rate';
  static const String futuresLeveragePath = '/trading/futures/leverage';
  static const String futuresCancelOrderPath = '/trading/futures/order/cancel';

  // Earn
  static const String earnProductsPath = '/earn/products';
  static const String earnSubscribePath = '/earn/subscribe';
  static const String earnRedeemPath = '/earn/redeem';
  static const String earnHistoryPath = '/earn/history';
  static const String earnPortfolioPath = '/earn/portfolio';

  // Auto Invest
  static const String autoInvestPlansPath = '/auto-invest/plans';
  static const String autoInvestPortfolioPath = '/auto-invest/portfolio';
  static const String autoInvestDepositPath = '/auto-invest/deposit';
  static const String autoInvestWithdrawPath = '/auto-invest/withdraw';
  static const String autoInvestHistoryPath = '/auto-invest/history';

  // P2P
  static const String p2pOffersPath = '/p2p/offers';
  static const String p2pCreateOfferPath = '/p2p/offers/create';
  static const String p2pOrdersPath = '/p2p/orders';
  static const String p2pChatPath = '/p2p/chat';
  static const String p2pDisputePath = '/p2p/dispute';
  static const String p2pPaymentMethodsPath = '/p2p/payment-methods';
  static const String p2pMerchantPath = '/p2p/merchant';

  // Fiat
  static const String fiatDepositPath = '/fiat/deposit';
  static const String fiatWithdrawPath = '/fiat/withdraw';
  static const String fiatHistoryPath = '/fiat/history';
  static const String bankListPath = '/fiat/banks';
  static const String addBankPath = '/fiat/bank/add';

  // Convert
  static const String convertPreviewPath = '/convert/preview';
  static const String convertPath = '/convert/execute';
  static const String convertHistoryPath = '/convert/history';

  // Rewards & Referral
  static const String referralInfoPath = '/rewards/referral';
  static const String referralHistoryPath = '/rewards/referral/history';
  static const String rewardsTasksPath = '/rewards/tasks';
  static const String rewardsCouponsPath = '/rewards/coupons';
  static const String dailyCheckInPath = '/rewards/check-in';
  static const String leaderboardPath = '/rewards/leaderboard';

  // AI Trading
  static const String aiDashboardPath = '/ai/dashboard';
  static const String aiStrategiesPath = '/ai/strategies';
  static const String aiSignalsPath = '/ai/signals';
  static const String aiSubscribePath = '/ai/subscribe';
  static const String aiStartPath = '/ai/start';
  static const String aiStopPath = '/ai/stop';
  static const String aiHistoryPath = '/ai/history';

  // Copy Trading
  static const String copyTradersPath = '/copy-trading/traders';
  static const String copyFollowPath = '/copy-trading/follow';
  static const String copyUnfollowPath = '/copy-trading/unfollow';
  static const String copyPortfolioPath = '/copy-trading/portfolio';
  static const String copyHistoryPath = '/copy-trading/history';

  // Notifications
  static const String notificationsPath = '/notifications';
  static const String notificationReadPath = '/notifications/read';
  static const String notificationPrefsPath = '/notifications/preferences';

  // Support
  static const String supportTicketsPath = '/support/tickets';
  static const String createTicketPath = '/support/tickets/create';
  static const String faqPath = '/support/faq';

  // News
  static const String newsPath = '/news';
  static const String announcementsPath = '/announcements';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String pinKey = 'pin_code';
  static const String biometricKey = 'biometric_enabled';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String currencyKey = 'currency';
  static const String onboardingKey = 'onboarding_done';

  // Pagination
  static const int pageSize = 20;

  // Cache durations
  static const Duration marketCacheDuration = Duration(seconds: 30);
  static const Duration tickerCacheDuration = Duration(seconds: 5);

  // WebSocket events
  static const String wsTicker = 'ticker';
  static const String wsOrderBook = 'orderbook';
  static const String wsTrades = 'trades';
  static const String wsCandles = 'candles';
  static const String wsPositions = 'positions';
  static const String wsOrders = 'orders';
  static const String wsBalance = 'balance';
  static const String wsNotification = 'notification';
}
