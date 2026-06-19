# Zebvix Exchange — Full Setup, Build & Deploy Guide

> Complete step-by-step commands for every developer workflow:
> local setup → GitHub → build → release → Play Store / App Store

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone from GitHub](#2-clone-from-github)
3. [First-time Local Setup](#3-first-time-local-setup)
4. [Firebase Setup](#4-firebase-setup)
5. [Android Signing Setup](#5-android-signing-setup)
6. [iOS Setup](#6-ios-setup)
7. [Running the App](#7-running-the-app)
8. [Code Generation](#8-code-generation)
9. [Building for Release](#9-building-for-release)
10. [GitHub Workflow](#10-github-workflow)
11. [Uploading to Play Store / App Store](#11-uploading-to-stores)
12. [Common Commands Reference](#12-common-commands-reference)
13. [Troubleshooting](#13-troubleshooting)
14. [Status Modal Usage](#14-status-modal-usage)

---

## 1. Prerequisites

Install these before anything else:

### Flutter SDK

```bash
# macOS (via Homebrew)
brew install --cask flutter

# Linux
sudo snap install flutter --classic

# Windows — download installer from:
# https://docs.flutter.dev/get-started/install/windows

# Verify installation
flutter --version       # must be >= 3.16
flutter doctor          # check all dependencies ✓
```

### Git

```bash
# macOS
xcode-select --install   # includes git

# Linux
sudo apt install git

# Windows
# Download from https://git-scm.com

git --version
```

### Android Studio (for Android builds)

```bash
# Download from https://developer.android.com/studio
# After install, open it and:
# 1. Install Android SDK (API 34)
# 2. Install Android Build-Tools 34.0.0
# 3. Install NDK 25.1.8937393
# 4. Set ANDROID_HOME environment variable

# macOS/Linux
export ANDROID_HOME=$HOME/Library/Android/sdk     # macOS
export ANDROID_HOME=$HOME/Android/Sdk             # Linux
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add to ~/.zshrc or ~/.bashrc permanently
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

### Xcode (macOS only — for iOS builds)

```bash
# Install from Mac App Store (Xcode 15+)
# Then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version   # should show 15.x
```

### CocoaPods (macOS only)

```bash
sudo gem install cocoapods
pod --version     # should show 1.14+
```

### Firebase CLI (for Firebase setup)

```bash
npm install -g firebase-tools
firebase login
firebase --version
```

### FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire --version
```

---

## 2. Clone from GitHub

### Option A — HTTPS (recommended for beginners)

```bash
git clone https://github.com/YOUR_USERNAME/zebvix-exchange.git
cd zebvix-exchange
```

### Option B — SSH (recommended for regular developers)

```bash
# First add your SSH key to GitHub if not done:
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub   # copy this and paste in GitHub → Settings → SSH Keys

git clone git@github.com:YOUR_USERNAME/zebvix-exchange.git
cd zebvix-exchange
```

### Option C — GitHub CLI

```bash
# Install gh first: https://cli.github.com
gh repo clone YOUR_USERNAME/zebvix-exchange
cd zebvix-exchange
```

---

## 3. First-time Local Setup

Run these in order after cloning:

```bash
# Step 1: Get all Flutter packages
flutter pub get

# Step 2: Verify Flutter can see your devices
flutter devices

# Step 3: Run code generation (REQUIRED — generates .freezed.dart & .g.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Step 4: Check for any issues
flutter analyze

# Step 5 (optional): Run tests
flutter test
```

---

## 4. Firebase Setup

Zebvix uses Firebase for push notifications, analytics, and crash reporting.

### Step 1 — Create Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → Name it `zebvix-exchange`
3. Enable Google Analytics

### Step 2 — Configure apps automatically (recommended)

```bash
# From project root:
flutterfire configure --project=zebvix-exchange

# This will:
# - Create google-services.json for Android
# - Create GoogleService-Info.plist for iOS
# - Update lib/firebase_options.dart automatically
```

### Step 3 — Manual placement (if needed)

```bash
# Android
cp google-services.json android/app/google-services.json

# iOS
cp GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
```

### Step 4 — Enable Firebase services in console

- **Authentication** → Email/Password, Google, Apple
- **Cloud Messaging** → Enable FCM
- **Crashlytics** → Enable crash reporting
- **Analytics** → Already enabled with project

### Step 5 — Update iOS Info.plist

Open `ios/Runner/Info.plist` and replace:
```
com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID
```
with the `REVERSED_CLIENT_ID` value from `GoogleService-Info.plist`.

---

## 5. Android Signing Setup

Required before building a release APK/AAB.

### Step 1 — Generate a keystore

```bash
keytool -genkey -v \
  -keystore ~/zebvix-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias zebvix

# You'll be prompted for passwords and info — SAVE THESE SAFELY
```

### Step 2 — Create key.properties

```bash
# Create android/key.properties (DO NOT commit this file — it's in .gitignore)
cat > android/key.properties << 'EOF'
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=zebvix
storeFile=/Users/YOUR_NAME/zebvix-release.jks
EOF
```

### Step 3 — Verify signing config in build.gradle

The `android/app/build.gradle` already reads `key.properties` automatically.

---

## 6. iOS Setup

### Step 1 — Install pods

```bash
cd ios
pod install
cd ..
```

### Step 2 — Open in Xcode

```bash
open ios/Runner.xcworkspace
# Always open .xcworkspace, NOT .xcodeproj
```

### Step 3 — Configure in Xcode

1. Select **Runner** in project navigator
2. **General** tab:
   - Bundle Identifier: `com.zebvix.exchange`
   - Display Name: `Zebvix Exchange`
3. **Signing & Capabilities** tab:
   - Team: Select your Apple Developer Team
   - Provisioning Profile: Automatic
4. **Capabilities** → Add:
   - ✅ Push Notifications
   - ✅ Sign In with Apple
   - ✅ Associated Domains → `applinks:zebvix.com`
   - ✅ Background Modes → Remote notifications, Background fetch
   - ✅ NFC Tag Reading (optional)

### Step 4 — Apple Developer Portal

1. Register App ID `com.zebvix.exchange`
2. Enable Push Notifications capability
3. Create APNs key and upload to Firebase Console
4. Create Distribution certificate + Provisioning Profile

---

## 7. Running the App

### Development (debug mode)

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (web — limited features)
flutter run -d chrome

# Run with specific flavor
flutter run --flavor production

# Run with hot reload (default in debug mode)
# Press 'r' to hot reload, 'R' to hot restart, 'q' to quit
```

### Run on emulator

```bash
# Android — start emulator from Android Studio AVD Manager, then:
flutter run

# iOS — start simulator:
open -a Simulator
flutter run

# Or specify:
flutter run -d "iPhone 15 Pro"
flutter run -d "Pixel 8"
```

### Debug on physical device

```bash
# Android — enable Developer Options + USB Debugging on device
flutter run   # it auto-detects

# iOS — trust the device when prompted on device
flutter run
```

---

## 8. Code Generation

Run this every time you modify a model, provider, or freezed class:

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode — auto-rebuilds on file change (for development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### What gets generated

| Source file | Generated file | Purpose |
|---|---|---|
| `*.dart` with `@freezed` | `*.freezed.dart` | Sealed unions, copyWith |
| `*.dart` with `@JsonSerializable` | `*.g.dart` | JSON encode/decode |
| `*.dart` with `@riverpod` | `*.g.dart` | Riverpod providers |
| `*.dart` with `@HiveType` | `*.g.dart` | Hive offline adapters |

---

## 9. Building for Release

### Android — Debug APK

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Android — Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# With split ABI (smaller size — separate apk per CPU)
flutter build apk --release --split-per-abi
# Output: app-arm64-v8a-release.apk  (most modern phones)
#         app-armeabi-v7a-release.apk (older phones)
#         app-x86_64-release.apk      (emulators)
```

### Android — App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# Use this for Play Store upload (smaller install size for users)
```

### iOS — Release (Xcode archive)

```bash
# Build iOS release
flutter build ios --release

# Then archive via Xcode:
# Product → Archive → Distribute App → App Store Connect
```

### iOS — IPA (for TestFlight or Ad Hoc)

```bash
flutter build ipa --release
# Output: build/ios/ipa/zebvix.ipa
```

### Build with obfuscation (recommended for production)

```bash
# Android
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# iOS
flutter build ios --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios
```

---

## 10. GitHub Workflow

### Initial push (first time)

```bash
# Initialize git (if not already done)
git init
git branch -M main

# Add all files
git add .

# First commit
git commit -m "feat: initial Zebvix Exchange Flutter project"

# Create repo on GitHub first (github.com → New Repository → zebvix-exchange)
# Then:
git remote add origin https://github.com/YOUR_USERNAME/zebvix-exchange.git
git push -u origin main
```

### Daily development workflow

```bash
# 1. Pull latest changes before starting work
git pull origin main

# 2. Create a feature branch
git checkout -b feature/spot-trading-improvements

# 3. Make your changes, then stage them
git add .
# Or stage specific files:
git add lib/features/spot_trading/

# 4. Commit with descriptive message
git commit -m "feat(spot): add one-click order buttons"

# 5. Push your branch
git push origin feature/spot-trading-improvements

# 6. Open Pull Request on GitHub
# github.com → your repo → Compare & pull request
```

### Commit message conventions

```
feat:     New feature
fix:      Bug fix
docs:     Documentation change
style:    Formatting, no logic change
refactor: Code restructure, no feature change
test:     Adding tests
chore:    Build process, dependencies

Examples:
git commit -m "feat(auth): add biometric login support"
git commit -m "fix(wallet): correct withdrawal amount validation"
git commit -m "feat(p2p): implement real-time order chat"
git commit -m "fix(markets): websocket reconnection on network drop"
```

### Tagging releases

```bash
# Tag a release version
git tag -a v1.0.0 -m "Release v1.0.0 — initial launch"
git push origin v1.0.0

# View all tags
git tag

# Checkout specific release
git checkout v1.0.0
```

### Useful Git commands

```bash
# View status
git status

# View commit history (pretty)
git log --oneline --graph --all

# Undo last commit (keep changes)
git reset HEAD~1 --soft

# Discard all local changes (DANGER)
git checkout .

# Stash changes temporarily
git stash
git stash pop      # restore

# View diff before committing
git diff

# Show specific commit
git show <commit-hash>

# Search commit messages
git log --grep="wallet"

# Update .gitignore and remove cached files
git rm -r --cached .
git add .
git commit -m "chore: update .gitignore"
```

---

## 11. Uploading to Stores

### Google Play Store

```bash
# Step 1: Build AAB
flutter build appbundle --release

# Step 2: Upload
# Go to play.google.com/console
# Create app → Production → Create new release
# Upload: build/app/outputs/bundle/release/app-release.aab

# OR use Fastlane (automated):
# gem install fastlane
# fastlane supply --aab build/app/outputs/bundle/release/app-release.aab \
#   --track production \
#   --json-key google-play-key.json
```

### Apple App Store

```bash
# Step 1: Build IPA
flutter build ipa --release

# Step 2: Upload via Xcode
open ios/Runner.xcworkspace
# Product → Archive → Distribute App → App Store Connect → Upload

# OR via Transporter app (Mac App Store)
# OR via xcrun altool:
xcrun altool --upload-app \
  -f build/ios/ipa/zebvix.ipa \
  -u "your-apple-id@email.com" \
  -p "@keychain:app-specific-password" \
  --type ios

# Step 3: Go to appstoreconnect.apple.com
# My Apps → Zebvix → TestFlight (beta) or App Store (production)
```

---

## 12. Common Commands Reference

### Flutter essentials

```bash
flutter --version                              # SDK version
flutter doctor                                 # Check environment
flutter devices                                # List connected devices
flutter pub get                                # Install dependencies
flutter pub upgrade                            # Upgrade packages
flutter pub outdated                           # Check outdated packages
flutter clean                                  # Clean build cache
flutter run                                    # Run debug
flutter run --release                          # Run release
flutter run --profile                          # Run profile (performance)
flutter build apk --release                    # Build Android APK
flutter build appbundle --release              # Build Android AAB
flutter build ios --release                    # Build iOS
flutter build ipa --release                    # Build iOS IPA
flutter test                                   # Run unit tests
flutter test --coverage                        # Run with coverage
flutter analyze                                # Static analysis
flutter format lib/                            # Format code
flutter pub run build_runner build             # Code generation
flutter pub run build_runner watch             # Watch mode codegen
flutter pub run build_runner clean             # Clean generated files
flutter logs                                   # View device logs
flutter install                                # Install on device
flutter screenshot                             # Take screenshot
flutter symbolize                              # Symbolize stack traces
```

### Dart essentials

```bash
dart --version                                 # Dart version
dart analyze                                   # Analyze Dart files
dart format lib/                               # Format Dart files
dart doc                                       # Generate documentation
dart compile exe lib/main.dart                 # Compile to native
dart pub global activate flutterfire_cli      # Activate FlutterFire CLI
dart pub global activate flutter_gen           # Asset code generation
```

### Android (ADB) commands

```bash
adb devices                                    # List connected Android devices
adb logcat                                     # View Android logs
adb logcat | grep flutter                      # Filter Flutter logs
adb install build/app/outputs/apk/release/app-release.apk
adb uninstall com.zebvix.exchange
adb shell pm list packages | grep zebvix
adb shell dumpsys activity | grep zebvix      # View running activities
adb reverse tcp:8080 tcp:8080                  # Port forwarding (dev API)
adb shell input keyevent 82                    # Open dev menu (debug)
adb bugreport                                  # Full bug report
```

### iOS (xcrun / simctl) commands

```bash
# Simulator
xcrun simctl list devices                      # List simulators
xcrun simctl boot "iPhone 15 Pro"              # Boot simulator
xcrun simctl install booted build/ios/ipa/zebvix.ipa
xcrun simctl launch booted com.zebvix.exchange
xcrun simctl log stream --device booted --predicate 'subsystem contains "zebvix"'

# Real device
xcrun devicectl list devices                   # iOS 17+ (Xcode 15)
ideviceinstaller -i build/ios/ipa/zebvix.ipa   # Install IPA
```

### Git quick reference

```bash
git clone <url>                                # Clone repository
git pull origin main                           # Pull latest
git push origin <branch>                       # Push branch
git checkout -b <branch>                       # Create + switch branch
git checkout main                              # Switch to main
git merge <branch>                             # Merge branch
git branch -d <branch>                         # Delete local branch
git push origin --delete <branch>              # Delete remote branch
git stash / git stash pop                      # Temp save changes
git log --oneline                              # View history
git diff                                       # View changes
git blame <file>                               # Who changed what
git bisect start/bad/good                      # Binary search for bug
```

---

## 13. Troubleshooting

### ❌ `flutter pub get` fails

```bash
# Clear pub cache
flutter pub cache clean
flutter pub get

# Or force upgrade
flutter pub upgrade --major-versions
```

### ❌ Build runner errors

```bash
# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ Android Gradle build fails

```bash
# Clean and rebuild
flutter clean
cd android && ./gradlew clean
cd ..
flutter pub get
flutter build apk --release

# If "NDK not found":
# Open Android Studio → SDK Manager → SDK Tools → NDK → Install 25.1.8937393

# If Java version mismatch:
# Android Studio → Preferences → Build Tools → Gradle → Gradle JDK → select JDK 17
```

### ❌ iOS CocoaPods errors

```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..

# If still failing:
sudo gem update cocoapods
pod repo update
pod install
```

### ❌ `flutter doctor` shows issues

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Xcode command-line tools
sudo xcode-select --reset
sudo xcode-select --switch /Applications/Xcode.app

# VSCode Flutter extension: install "Flutter" by Dart Code
# Android Studio: install Flutter plugin
```

### ❌ App crashes on launch (release build)

```bash
# Check for obfuscation issues — symbolize crash
flutter symbolize \
  --input=crash.txt \
  --debug-info=build/debug-info/android/

# Check ProGuard kept classes
# Review android/app/proguard-rules.pro
```

### ❌ WebSocket not connecting

```bash
# Ensure network_security_config.xml has ws.zebvix.com
# Check INTERNET permission in AndroidManifest.xml
# In debug mode, check if VPN is blocking WebSocket
```

### ❌ Biometric auth not working

```bash
# Android: must use minSdk 23+ (already set)
# Emulators don't support biometrics — test on real device
# iOS Simulator: supports Face ID simulation (Features → Face ID → Enrolled)
```

### ❌ Push notifications not working

```bash
# Verify google-services.json / GoogleService-Info.plist is in place
# Check Firebase project has FCM enabled
# Android: check POST_NOTIFICATIONS permission (Android 13+)
# iOS: run on real device (not simulator)
# Check notification channel ID matches in AndroidManifest.xml
```

---

## 14. Status Modal Usage

The `ZebStatusModal` provides loading, success, error, warning, info, and processing states.

### Quick usage (ZebStatus helpers)

```dart
import 'package:zebvix/core/widgets/zeb_status_modal.dart';

// Loading (non-dismissible)
ZebStatus.loading(context, title: 'Placing Order...');

// Dismiss
ZebStatus.dismiss(context);

// Success (auto-dismisses after 2s)
await ZebStatus.success(context, title: 'Order Placed!', subtitle: 'BTC/USDT order confirmed');

// Error with retry button
await ZebStatus.error(context, title: 'Payment Failed', subtitle: 'Insufficient balance', onRetry: () { /* retry */ });

// Warning / Confirm dialog
final confirmed = await ZebStatus.warning(context, title: 'Confirm Withdrawal', subtitle: 'Send 0.5 BTC to bc1q...?');
if (confirmed) { /* proceed */ }

// Info
await ZebStatus.info(context, title: 'Market Closed', subtitle: 'Trading resumes in 2 hours');

// Processing with steps
ZebStatus.processing(context, title: 'Processing Withdrawal', steps: ['Verifying address', 'Deducting balance', 'Broadcasting']);
```

### Crypto-specific convenience methods

```dart
// Withdrawal confirm
final ok = await ZebStatus.confirmWithdrawal(context, amount: '0.5 BTC', address: 'bc1qxy...');

// Order placed
await ZebStatus.orderSuccess(context, pair: 'BTC/USDT', side: 'BUY');

// KYC
ZebStatus.kycSubmitting(context);
await ZebStatus.kycSuccess(context);

// Network error
await ZebStatus.networkError(context, onRetry: () => fetchData());

// Session expired
await ZebStatus.sessionExpired(context);

// Convert
await ZebStatus.convertSuccess(context, from: '1000 USDT', to: '0.0156 BTC');
```

### Full activity wrapper (recommended for API calls)

```dart
import 'package:zebvix/core/widgets/zeb_activity_wrapper.dart';

// Generic action
await ZebActivity.run(
  context,
  action: () => apiClient.placeOrder(params),
  loadingTitle: 'Placing Order...',
  successTitle: 'Order Placed!',
  onSuccess: (result) => print(result),
  onRetry: () => placeOrder(),
);

// Trading shorthand
await ZebActivity.trade(
  context,
  action: () => apiClient.placeSpotOrder(side: 'BUY', pair: 'BTC/USDT', amount: 0.5),
  pair: 'BTC/USDT',
  side: 'BUY',
  onSuccess: (order) => updatePortfolio(order),
);

// Withdrawal shorthand
await ZebActivity.withdraw(
  context,
  action: () => apiClient.withdraw(coin: 'BTC', amount: 0.1, address: address),
  amount: '0.1',
  coin: 'BTC',
);

// KYC shorthand
await ZebActivity.kycUpload(
  context,
  action: () => apiClient.submitKyc(documents),
  onSuccess: (_) => router.go('/home'),
);

// P2P shorthand
await ZebActivity.p2p(
  context,
  action: () => apiClient.createP2pOrder(params),
  type: 'BUY',
);

// Convert shorthand
await ZebActivity.convert(
  context,
  action: () => apiClient.convert(from: 'USDT', to: 'BTC', amount: 1000),
  from: '1000 USDT',
  to: 'BTC',
);
```

### Toast / Snackbar

```dart
import 'package:zebvix/core/widgets/zeb_status_modal.dart';

ZebToast.success(context, 'Copied to clipboard!');
ZebToast.error(context, 'Invalid address format');
ZebToast.warning(context, 'Low balance warning');
ZebToast.info(context, 'Market data refreshed');
```

---

## Environment Variables / Secrets

| Secret | Where to set | Purpose |
|---|---|---|
| Firebase config | `google-services.json` / `GoogleService-Info.plist` | Push, analytics, crash |
| Keystore password | `android/key.properties` (local only) | APK signing |
| Apple cert | Xcode / App Store Connect | iOS signing |
| Google Sign-In client ID | `android/app/build.gradle` / `Info.plist` | Social login |

> ⚠️ **Never commit** `key.properties`, `*.jks`, `google-services.json`, or `GoogleService-Info.plist` to Git.
> These are already added to `.gitignore`.

---

*Generated for Zebvix Exchange Flutter Project — API: https://zebvix.com*
