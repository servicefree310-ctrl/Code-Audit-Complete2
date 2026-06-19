# Zebvix Exchange — Flutter App

World-class cryptocurrency exchange mobile application.  
API base: `https://zebvix.com`

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3) |
| State | Riverpod 2 (StateNotifier + FutureProvider + StreamProvider) |
| Navigation | GoRouter 13 |
| Networking | Dio 5 + Retrofit |
| WebSocket | web_socket_channel |
| Storage | flutter_secure_storage + Hive + SharedPreferences |
| Charts | fl_chart + Syncfusion Flutter Charts |
| Auth | local_auth (Face ID / Fingerprint), Google Sign-In, Sign in with Apple |
| Push | Firebase Messaging + flutter_local_notifications |
| UI | Material 3, Google Fonts (Inter), shimmer, animate_do, lottie |

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── api/                   # Dio client + interceptors
│   ├── constants/             # AppConstants (URLs, keys, enums)
│   ├── errors/                # AppException (freezed union)
│   ├── router/                # GoRouter + route names
│   ├── storage/               # SecureStorage service
│   ├── theme/                 # Colors, text styles, theme data
│   ├── utils/                 # Formatters, helpers
│   ├── websocket/             # WebSocket service
│   └── widgets/               # Shared widgets
└── features/
    ├── auth/                  # Login, Register, OTP, PIN, Biometric
    ├── home/                  # Dashboard
    ├── markets/               # Market list, Coin detail
    ├── spot_trading/          # Order book, Buy/Sell panel
    ├── futures/               # Futures trading, Leverage, Positions
    ├── wallet/                # Overview, Deposit, Withdraw, Transfer
    ├── earn/                  # Staking, Savings, Launchpad
    ├── p2p/                   # P2P marketplace + Order chat
    ├── convert/               # Instant crypto conversion
    ├── rewards/               # Referrals, Tasks, Coupons, Leaderboard
    ├── notifications/         # Push notification centre
    ├── profile/               # Profile, KYC, Security, 2FA, API Keys
    ├── settings/              # App settings, Language, Theme
    ├── support/               # Tickets + FAQ
    ├── ai_trading/            # AI-powered trading bots
    ├── auto_invest/           # DCA / Auto-invest plans
    ├── copy_trading/          # Copy top traders
    └── fiat/                  # Fiat on/off-ramp + Bank accounts
```

---

## Android Permissions

All declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Purpose |
|---|---|
| INTERNET, ACCESS_NETWORK_STATE | API + WebSocket calls |
| CAMERA | QR scan, KYC document capture |
| USE_BIOMETRIC / USE_FINGERPRINT | Fingerprint / Face login |
| READ/WRITE_EXTERNAL_STORAGE | Document upload, receipts |
| READ_MEDIA_IMAGES | Android 13+ media picker |
| POST_NOTIFICATIONS | Price alerts, order fills |
| RECEIVE_BOOT_COMPLETED | Restart scheduled alerts |
| ACCESS_FINE_LOCATION | Geo-restriction / fraud checks |
| READ_PHONE_STATE | Device ID for 2FA |
| RECEIVE_SMS / READ_SMS | OTP auto-read |
| READ_CONTACTS | P2P: send to phone contacts |
| FOREGROUND_SERVICE | Background WebSocket sync |
| REQUEST_INSTALL_PACKAGES | In-app update |
| SCHEDULE_EXACT_ALARM | Exact price alert timers |
| FLASHLIGHT | Torch during QR scan |

---

## iOS Permissions (Info.plist)

| Key | Purpose |
|---|---|
| NSCameraUsageDescription | QR scan, KYC capture |
| NSPhotoLibraryUsageDescription | Document/avatar upload |
| NSPhotoLibraryAddUsageDescription | Save QR & receipts |
| NSFaceIDUsageDescription | Face ID login |
| NSMicrophoneUsageDescription | Voice messages in P2P |
| NSLocationWhenInUseUsageDescription | Geo-compliance |
| NSLocationAlwaysAndWhenInUseUsageDescription | Background fraud detection |
| NSContactsUsageDescription | Send to contacts |
| NSCalendarsUsageDescription | Trading schedule reminders |
| NSUserTrackingUsageDescription | Referral attribution |
| NSSiriUsageDescription | Siri shortcuts |
| NFCReaderUsageDescription | Hardware wallet NFC |
| UIBackgroundModes | remote-notification, fetch, processing |

---

## Security Features

- **FLAG_SECURE** on Android — prevents screenshots in app switcher
- **Network Security Config** — certificate pinning for zebvix.com (update SHA hashes before release)
- **App Transport Security** — TLS 1.2 minimum, forward secrecy required
- **ProGuard** — code obfuscation + log stripping in release builds
- **flutter_secure_storage** — auth tokens stored in Keychain (iOS) / EncryptedSharedPreferences (Android)
- **Biometric auth** — Face ID / Touch ID / Fingerprint for login + tx confirmation

---

## Setup

### 1. Prerequisites

```bash
flutter --version     # >= 3.16
dart --version        # >= 3.0
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Code generation (run once + after model changes)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` (sealed unions for AppException, models)
- `*.g.dart` (JSON serialization, Hive adapters, Riverpod generators)

### 4. Firebase setup

- Add `google-services.json` → `android/app/`
- Add `GoogleService-Info.plist` → `ios/Runner/`
- Update the Google Sign-In reversed client ID in `ios/Runner/Info.plist`

### 5. Android signing (release)

Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=path/to/your.keystore
```

### 6. iOS

```bash
cd ios && pod install
```

Open `ios/Runner.xcworkspace` in Xcode, set your Bundle ID, Team, and capabilities:
- Sign in with Apple
- Push Notifications
- Associated Domains (zebvix.com)
- NFC Tag Reading (optional)

### 7. Run

```bash
# Debug
flutter run

# Release
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

---

## Branding

| Token | Value |
|---|---|
| Primary | `#FCD535` (Zebvix Yellow) |
| Background | `#0B0E11` |
| Surface | `#1E2329` |
| Bullish | `#0ECB81` |
| Bearish | `#F6465D` |
| Font | Inter (300 – 800) |

---

## API

Base URL: `https://zebvix.com`  
All endpoints defined in `lib/core/constants/app_constants.dart`.  
Auth token is sent as `Authorization: Bearer <token>` via `AuthInterceptor`.

---

## Certificate Pinning (Android)

Update the SHA-256 pins in `android/app/src/main/res/xml/network_security_config.xml` with your actual certificate fingerprints before shipping to production:

```bash
# Get SHA-256 from your server cert
openssl s_client -connect zebvix.com:443 | openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
```

---

## Notes

- `app_exception.freezed.dart` is pre-generated — re-run build_runner if you modify `app_exception.dart`
- Assets folders (`assets/images/`, `assets/icons/`, `assets/animations/`, `assets/fonts/`) must be populated with real assets before build
- Inter font files must be placed in `assets/fonts/` or replaced with `google_fonts` runtime fetching
