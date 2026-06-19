# Zebvix Exchange — Full Security & Code Audit Report
**Date:** June 19, 2026  
**Scope:** Flutter Mobile App (`zebvix-flutter/`) + Backend API Server (Migration-Runner-Build13)  
**Auditor:** Replit Agent  
**Classification:** CONFIDENTIAL — Internal Use Only

---

## Executive Summary

This report covers a complete audit of the Zebvix Exchange platform, comprising the Flutter mobile client and the Node.js/Express backend API server. The platform is a crypto exchange targeting Indian users (INR fiat on/off ramp, KYC, PMLA compliance signals).

**Overall Assessment:**  
The codebase is architecturally sound and shows deliberate security thinking in many areas (row-level locking for double-spend prevention, HMAC webhook verification, audit logs, Zod strict validation, bcrypt, SameSite=strict cookies). However, **several critical issues must be resolved before production launch**, particularly the fake Solana address generation, simulated blockchain transactions being passed to users as real, and missing Content-Security-Policy headers.

| Severity | Count | Status |
|----------|-------|--------|
| 🔴 Critical | 4 | Must fix before launch |
| 🟠 High | 6 | Fix before launch |
| 🟡 Medium | 8 | Fix within 30 days |
| 🟢 Low / Info | 9 | Recommended improvements |

---

## Part 1 — Flutter Mobile App Audit

### ✅ Fixes Already Applied (10 issues resolved)

The following were identified and patched during this audit session:

| # | File | Fix Applied |
|---|------|-------------|
| 1 | `lib/core/api/api_client.dart` | Added `Authorization: Bearer` header injection via Interceptor; removed plain-text token debug logging |
| 2 | `lib/core/api/auth_interceptor.dart` | Implemented proper 401 token-refresh retry loop with mutex lock to prevent concurrent refresh storms |
| 3 | `lib/core/services/ws_service.dart` | Added exponential backoff reconnect (max 30s), auth token sent on connect, ping/pong heartbeat |
| 4 | `lib/main.dart` | Added `FlutterError.onError` + `PlatformDispatcher.onError` crash handlers; routed to Sentry/logger in release |
| 5 | `android/app/src/main/AndroidManifest.xml` | Removed `android:usesCleartextTraffic="true"`; enforced `networkSecurityConfig` |
| 6 | `android/app/src/main/res/xml/network_security_config.xml` | Restricted cleartext to no domains; pinned Zebvix API cert SHA-256 |
| 7 | `lib/features/wallet/withdraw_screen.dart` | Added client-side amount/address validation before API call; added confirmation dialog with fee display |
| 8 | `lib/features/trading/spot_trading_screen.dart` | Added order confirmation sheet showing estimated total + fee; debounced rapid submit taps |
| 9 | `lib/features/auth/login_screen.dart` | Added brute-force lockout UI (after 5 failed attempts, show countdown timer); masked password field enforced |
| 10 | `lib/core/widgets/app_lock_wrapper.dart` | Added biometric re-authentication prompt after 5-minute background; fallback to PIN |

### 🟡 Remaining Flutter Recommendations

#### F-01 (Medium) — Certificate Pinning: Pin Rotation Strategy Missing
**File:** `network_security_config.xml`  
The cert pin is now set, but there is no backup pin and no in-app update mechanism if the cert rotates. A cert rotation without a backup pin = all existing installs lose connectivity.  
**Fix:** Add a second SHA-256 pin (the upcoming cert) and implement a remote config kill-switch that can disable pinning in an emergency.

#### F-02 (Medium) — No Jailbreak/Root Detection
The app handles private keys and wallet operations. On a rooted device, an attacker can dump memory, hook Flutter methods, and extract session tokens.  
**Fix:** Integrate `flutter_jailbreak_detection` package. On detection, show a warning and optionally block high-risk operations (withdrawals, 2FA setup).

#### F-03 (Medium) — Screenshot Prevention on Sensitive Screens
Withdrawal, balance, and portfolio screens allow OS-level screenshot/screen recording.  
**Fix:** Add `FLAG_SECURE` on Android (`SystemChrome.setEnabledSystemUIMode` alone is insufficient). Use the `flutter_windowmanager` package:
```dart
await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
```
Apply on: wallet screen, withdraw screen, portfolio screen, seed phrase display.

#### F-04 (Low) — Deep Link Validation Missing
OAuth and email-verify deep links (`zebvix://auth/callback?token=...`) are not validated for origin. A malicious app could craft a deep link with a forged token.  
**Fix:** Validate deep-link tokens server-side within 60 seconds of issuance; mark them one-time-use.

#### F-05 (Low) — API Base URL Hardcoded in Debug Flavor
`api_client.dart` has a hardcoded debug base URL (`http://10.0.2.2:5000`). If a release build accidentally picks up the debug flavor config, it would point at a local emulator.  
**Fix:** Move base URLs to `--dart-define` build flags or flavor-specific `config.dart` files, not hardcoded strings.

---

## Part 2 — Backend API Server Audit

### 2.1 Architecture Overview

```
Express 5 (TypeScript)
├── Helmet (partial — CSP disabled)
├── CORS allowlist
├── Rate limiters (per-endpoint, Redis-backed)
├── requireAuth middleware (JWT cookie + session DB check)
├── requireRole middleware (RBAC)
├── requireKyc middleware
├── Zod strict() input validation
├── Drizzle ORM + PostgreSQL
├── Redis (rate limiting, cache, pub/sub)
├── Pino structured logging (req.log)
└── Audit log table (all admin actions)
```

**Positive Security Signals:**
- Row-level `FOR UPDATE` locking on all wallet mutation transactions (prevents double-spend) ✅
- `timingSafeEqual` for webhook HMAC verification ✅
- `bcryptjs` with cost factor 12 for passwords ✅
- Session invalidation on account freeze ✅
- KYC gate on INR withdrawals ✅
- Sanctions screening (OFAC/UN/FATF) at registration ✅
- Admin audit log on all privileged actions ✅
- `scrypt` for crypto vault key derivation ✅
- Leader election for deposit sweeper (prevents duplicate credits) ✅

---

### 🔴 CRITICAL Issues

---

#### B-C01 — FAKE Solana Addresses Generated (Wrong Curve)
**File:** `lib/hd-wallet.ts`  
**Severity:** 🔴 Critical — Users will lose deposited SOL permanently

```typescript
// CURRENT (WRONG) — secp256k1 is Bitcoin/Ethereum's curve, NOT Solana's
const child = root.derivePath(path);
const publicKey = child.publicKey; // secp256k1 33-byte compressed key
const address = bs58.encode(publicKey); // NOT a valid Solana address
```

Solana uses **ed25519**, not secp256k1. The generated addresses will be base58-encoded secp256k1 public keys that look like Solana addresses but are not. Any SOL sent to these addresses is **permanently lost** — no one holds the corresponding ed25519 private key.

The code itself has a comment acknowledging this:
> `// Replace with @noble/ed25519 for production SOL deposits`

**Fix:**
```typescript
import { derivePath } from 'ed25519-hd-key';
import { Keypair } from '@solana/web3.js';

function deriveSolanaAddress(mnemonic: string, index: number): string {
  const seed = mnemonicToSeedSync(mnemonic);
  const path = `m/44'/501'/${index}'/0'`; // BIP44 for Solana
  const { key } = derivePath(path, seed.toString('hex'));
  const keypair = Keypair.fromSeed(key);
  return keypair.publicKey.toBase58(); // valid ed25519-based Solana address
}
```
Install: `pnpm add ed25519-hd-key @solana/web3.js`

**Until fixed:** Disable SOL deposits entirely at the UI level and on the backend. Do not generate new SOL deposit addresses.

---

#### B-C02 — Simulated Blockchain Transactions (Fake TX Hashes)
**File:** `routes/web3.ts`  
**Severity:** 🔴 Critical — Regulatory and fraud liability

The `/api/web3/swap` and `/api/web3/bridge` endpoints return a `fakeTxHash()` — randomly generated hex strings that are not real on-chain transactions. Users believe they have completed a real blockchain swap/bridge, but no actual transaction exists.

```typescript
// In web3.ts
function fakeTxHash(): string {
  return '0x' + crypto.randomBytes(32).toString('hex'); // NOT a real tx
}
```

**Impact:**
- Users cannot verify the transaction on any blockchain explorer
- If the platform is audited by regulators or SEBI/FIU-IND, this constitutes misrepresentation
- Users who attempt to bridge funds are not actually bridging anything

**Fix (minimum):** Either:
1. Connect to real DEX/bridge APIs (Uniswap, LI.FI, Socket.tech) and use real tx hashes, OR
2. **Disable these endpoints immediately** and return `501 Not Implemented` with a message like `"Swap/bridge functionality is under development"`.

Do NOT return fake hashes to users even in a "demo" mode without very clear, explicit UI disclosure.

---

#### B-C03 — Content-Security-Policy Completely Disabled
**File:** `app.ts`  
**Severity:** 🔴 Critical — XSS has no browser-level defence

```typescript
app.use(helmet({
  contentSecurityPolicy: false,  // ← DISABLED
}));
```

An admin panel or user-portal running without CSP means any XSS vulnerability (stored or reflected) has zero browser mitigation. Given that the admin panel can approve withdrawals, credit balances, and restart the server, a successful XSS attack against an admin has catastrophic impact.

**Fix:**
```typescript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc:     ["'self'"],
      scriptSrc:      ["'self'"],
      styleSrc:       ["'self'", "'unsafe-inline'"],  // tighten once CSP nonces are added
      imgSrc:         ["'self'", "data:", "https:"],
      connectSrc:     ["'self'", "wss:", "https://api.zebvix.com"],
      fontSrc:        ["'self'", "https://fonts.gstatic.com"],
      objectSrc:      ["'none'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
}));
```

---

#### B-C04 — Source Code Exposed to All Admins (Including Secrets Risk)
**File:** `routes/admin-source.ts`  
**Severity:** 🔴 Critical — IP exposure and secret leakage path

The `/api/admin/source/*` endpoints allow any `admin` or `superadmin` role user to:
1. Browse the full source tree of `api-server`, `admin` frontend, `user-portal`, and `lib/db`
2. Download a ZIP of any of those directories
3. Dump the full live database schema

**Concerns:**
- Any `.env` files or inline API key references in source are served to admins
- Source code is the company's primary IP — a single compromised admin account = full source dump
- The source download is audited (logged), but logging does not prevent the leak

**Fix:**
1. Change `requireRole("admin", "superadmin")` on the source browser to `requireRole("superadmin")` only — regular admins do not need source access.
2. Add a second factor for source downloads (e.g. require re-entering password or OTP before ZIP download).
3. Ensure `.env` files and any files containing actual secrets are in `SKIP_DIRS` or explicitly blocked by extension/name.

---

### 🟠 HIGH Issues

---

#### B-H01 — JWT: No `jti` Claim (Tokens Cannot Be Individually Revoked)
**File:** `lib/jwt.ts`  
**Severity:** 🟠 High

The custom JWT implementation issues tokens without a `jti` (JWT ID) claim. If a token is stolen (e.g. via XSS), there is no way to invalidate that specific token without invalidating **all** of the user's sessions (by changing the session secret or invalidating the session row).

**Fix:** Add a `jti` UUID to every token at issuance and store it in a Redis set with TTL = token expiry. On each request, verify the `jti` is still in the set. On logout, delete the `jti`. This gives true per-token revocation.

```typescript
import { randomUUID } from 'node:crypto';

function signToken(payload: JwtPayload): string {
  const jti = randomUUID();
  const full = { ...payload, jti, iat: Math.floor(Date.now() / 1000) };
  // ... existing HMAC signing ...
  await redis.setex(`jwt:jti:${jti}`, TOKEN_TTL_SECONDS, '1');
  return token;
}

async function verifyToken(token: string): Promise<JwtPayload> {
  const payload = // ... existing verify ...
  const valid = await redis.exists(`jwt:jti:${payload.jti}`);
  if (!valid) throw new Error('Token revoked');
  return payload;
}
```

---

#### B-H02 — JWT: No `nbf` Claim (Replay Window Vulnerability)
**File:** `lib/jwt.ts`  
**Severity:** 🟠 High

Tokens do not include a `nbf` (not-before) claim. This means a token intercepted during transmission could be replayed from any point in time between issuance and expiry.

**Fix:** Add `nbf: Math.floor(Date.now() / 1000)` to the token payload and reject tokens where `nbf > now + 30` (30-second clock skew tolerance).

---

#### B-H03 — Crypto Vault: Fixed Salt in Key Derivation
**File:** `lib/crypto-vault.ts`  
**Severity:** 🟠 High

```typescript
const SALT = 'cryptox-vault-v1'; // hardcoded string, not random
const key = scryptSync(SESSION_SECRET, SALT, 32);
```

Using a fixed salt for key derivation means:
1. The security of the vault key is entirely dependent on the entropy of `SESSION_SECRET`
2. If `SESSION_SECRET` ever leaks (env var exposure, log leak, etc.), all encrypted vault data is immediately compromised with zero additional work — no need to crack anything, just re-derive
3. No key versioning — if the key needs to be rotated, all data must be re-encrypted

**Fix:**
- Generate a random 32-byte salt per-encryption-operation and store it alongside the ciphertext (`salt || iv || ciphertext || authTag`)
- For the master key derivation (wrapping key), use a randomly generated salt stored in the DB (not hardcoded)
- Add a key version field to all encrypted records to enable future rotation

---

#### B-H04 — Admin scrypt Parameters Below 2024 Recommendations
**File:** `lib/admin-vault.ts`  
**Severity:** 🟠 High

```typescript
scryptSync(secret, salt, 32, { N: 16384, r: 8, p: 1 }) // N=2^14
```

OWASP 2024 recommends `N=65536` (2^16) minimum for new systems, with `N=131072` (2^17) recommended where hardware allows. N=16384 (2^14) is below the minimum for a financial application.

**Fix:** Increase to at least `N: 65536`. Note this requires a one-time migration of all admin secrets (re-derive and re-encrypt with new parameters).

---

#### B-H05 — INR Deposit: No Amount Upper Bound / Daily Limit
**File:** `routes/inr.ts`  
**Severity:** 🟠 High (PMLA compliance risk)

```typescript
const DepositSchema = z.object({
  amountInr: z.number().min(100, "Minimum ₹100"),
  // No maximum!
```

There is no upper bound on deposit amount and no daily/monthly aggregate limit. Under PMLA 2002 (Prevention of Money Laundering Act), deposits above ₹10 lakh require enhanced due diligence and CTR filing. Without an enforced cap, a user could submit a ₹1 crore deposit request which an admin might approve without the proper CTR being triggered.

**Fix:**
```typescript
const DepositSchema = z.object({
  amountInr: z.number().min(100).max(1_000_000, "Single deposit max ₹10 lakh"),
  // ...
});
// Also: enforce 24h aggregate limit in the POST handler via a DB sum query
```

---

#### B-H06 — Admin User List: No Cursor Pagination, Returns Raw PII
**File:** `routes/admin.ts`  
**Severity:** 🟠 High

The `GET /api/admin/users` endpoint returns up to 500 users including PII (email, phone, name, KYC tier) in a single response, with no cursor-based pagination. As the user base grows:
- A compromised admin token exposes mass PII in one request
- Response size becomes a DoS vector (500 users × full profile = large payload)

**Fix:** Implement cursor-based pagination (return `nextCursor` based on last row `id`). Limit response fields to what the admin panel actually needs (avoid returning raw KYC document URLs in the list view).

---

### 🟡 MEDIUM Issues

---

#### B-M01 — Sanctions Screening: Local Static List Only
**File:** `lib/sanctions.ts`  
**Severity:** 🟡 Medium

The sanctions screening uses a hardcoded list of ~30 SDN name fragments and a static country list. The actual OFAC SDN list contains 17,000+ entries, the UN Consolidated List has 800+, and both are updated weekly.

**Current state:** The local list catches only the most prominent names. A user named after a less-prominent sanctioned individual will pass screening.

**Fix for production:**
1. Integrate OFAC SDN API: `https://sanctionssearch.ofac.treas.gov/`
2. Alternatively, use a commercial AML/KYC screening API (Dow Jones Risk, Refinitiv, Comply Advantage) — required by most Indian Payment Aggregators for PMLA compliance
3. Schedule weekly automated sync of UN, EU, and India MHA lists

---

#### B-M02 — INR Admin Approval: Filter Applied in Application Layer (Not DB)
**File:** `routes/admin-system.ts` lines 182–187  
**Severity:** 🟡 Medium

```typescript
// Fetches up to 200 rows from DB, then filters in JS:
let result = rows;
if (type   && type   !== "all") result = result.filter(r => r.tx.type   === type);
if (status && status !== "all") result = result.filter(r => r.tx.status === status);
if (search) {
  const s = String(search).toLowerCase();
  result = result.filter(r => r.email?.toLowerCase().includes(s) || ...);
}
```

Filtering after DB fetch means: (a) full table scan cost even when only 1 row is needed, (b) the `limit(200)` means filtered results may return fewer rows than requested even though more exist.

**Fix:** Move all filter conditions into the Drizzle `where()` clause before the DB query.

---

#### B-M03 — WebSocket: No Per-Connection Auth Token Validation on Upgrade
**File:** `lib/ws-service.ts` (referenced in audit)  
**Severity:** 🟡 Medium

WebSocket connections are accepted on the HTTP upgrade and then authenticated on the first message. This creates a window where an unauthenticated connection is held open consuming server resources. Under a WebSocket flood attack, this could exhaust connection limits before legitimate users can connect.

**Fix:** Validate the JWT token in the `upgrade` event handler (synchronously before the WebSocket handshake completes) and reject invalid connections at the HTTP level with a 401.

---

#### B-M04 — Redis Flush-All Available to Superadmin Without Rate Limit
**File:** `routes/redis-admin.ts` line 154  
**Severity:** 🟡 Medium

`POST /api/redis/flush-all` calls `r.flushdb()` — this instantly deletes all Redis data including rate limit counters, session tokens, order book cache, and OTP codes.

A compromised superadmin account (or an admin who is forced/tricked) can:
1. Flush all rate limit counters → allow brute force attacks
2. Flush all session data → mass log out all users
3. Flush order book cache → market data unavailable

**Fix:** Require a second confirmation token (generated by the server, valid for 60 seconds) before executing flush-all. Log the flush with the admin's IP and user agent.

---

#### B-M05 — No TOTP/2FA Enforcement for Admins
**Severity:** 🟡 Medium

Based on reading `routes/auth.ts` and `middlewares/auth.ts`, 2FA (TOTP) is available as a user feature but is not **enforced** for admin-role accounts. An admin with a weak password and no 2FA is a single point of failure for the entire platform.

**Fix:** Add middleware that checks `requiresTwoFactor` for any role of `admin` or `superadmin` and rejects requests where the current session was not 2FA-verified.

---

#### B-M06 — Error Messages Leak Stack Traces in Some Paths
**Severity:** 🟡 Medium

Several route catch blocks propagate raw `e.message` in responses. In production, this can reveal:
- Database table names
- File paths
- Internal service URLs
- ORM query details

**Fix:** In production (`NODE_ENV === 'production'`), all 500 errors should return a generic `{ error: "internal_server_error", requestId: "..." }` with the actual detail written only to the server log (Pino).

---

#### B-M07 — HD Wallet Mnemonic: Encryption Key Tied to Session Secret
**File:** `lib/hd-wallet.ts`, `lib/crypto-vault.ts`  
**Severity:** 🟡 Medium

HD wallet mnemonics are encrypted using a key derived from `SESSION_SECRET`. This means:
1. The mnemonic encryption key and the JWT signing key are derived from the same secret
2. A forced `SESSION_SECRET` rotation (e.g. after a leak) would require re-encrypting all HD wallet mnemonics — a complex, downtime-inducing operation

**Fix:** Use a **separate** environment variable (`VAULT_MASTER_KEY`) specifically for encrypting sensitive financial data. Keep JWT signing key and vault encryption key independent.

---

#### B-M08 — No Request Timeout on External Calls (Price Service, Razorpay)
**File:** `lib/razorpay.ts`, `lib/price-service.ts`  
**Severity:** 🟡 Medium

External API calls (Razorpay payment verification, price feed fetches) do not have explicit timeouts set. A slow or hung external service will hold an Express worker thread open indefinitely until the Node.js default socket timeout (which is very long).

**Fix:** Set `AbortSignal.timeout(5000)` on all `fetch()` calls to external services. For Razorpay verify calls specifically, use 10 seconds.

---

### 🟢 LOW / INFORMATIONAL

---

#### B-L01 — `admin-vault.ts` Scrypt Salt is Hardcoded (same as B-H03 but admin context)
Same pattern as B-H03, applies specifically to the admin credential vault.

#### B-L02 — INR Bank Details Endpoint Unauthenticated
`GET /api/payments/inr/bank-details` is public (no `requireAuth`). This leaks the exchange's bank account number and IFSC to anyone. Functionally this may be intentional (public deposit instructions), but should be confirmed as deliberate and the hardcoded fallback account details should be reviewed.

#### B-L03 — `admin/restart` Exits Process Without Graceful Drain
`POST /api/admin/restart` calls `process.exit(0)` after 800ms. Any in-flight requests (including active database transactions) are aborted. For a financial system, consider waiting for in-flight transactions to complete before exiting (use `server.close()` + drain).

#### B-L04 — INR History Limit is Hardcoded at 100 (No Pagination)
`GET /api/payments/inr/history` always returns the last 100 transactions with no pagination. Long-term users will silently lose older history.

#### B-L05 — Matching Engine Sweep Can Be Triggered Without Symbol Scope
`POST /api/admin/matching/sweep` without a `symbol` body scans the last 500 open orders globally. On a high-volume exchange, this can be a very expensive DB query and should require a symbol to be specified.

#### B-L06 — Sanctions Screening: Fuzzy Match Has False Positive Risk
The `softMatch` function uses a 1-character typo tolerance. Common names like "Ravi", "Ali", "Hassan" could match SDN fragments depending on context. False positives at registration would block legitimate Indian users.

#### B-L07 — Razorpay Webhook: Order Amount Validation Not Double-Checked
`routes/webhooks.ts` verifies the Razorpay HMAC signature correctly, but does not independently verify that `payment.amount` in the webhook matches the amount stored in the pending order. An amount mismatch (e.g. currency confusion between paise and rupees) could credit the wrong amount.

#### B-L08 — No Automated Deposit Confirmation Timeout
INR deposits stay in `pending` status indefinitely until an admin approves. If an admin forgets or the queue backs up, users have no visibility into the delay. A 72-hour auto-reject with email notification would improve UX and reduce support burden.

#### B-L09 — `cache/config` Endpoint is Public with No Auth
`GET /api/cache/config` returns the platform's full Redis caching topology (all key patterns, TTLs, categories) with no authentication. While not directly exploitable, it gives an attacker insight into the platform's internal architecture and caching strategy.

---

## Part 3 — Compliance & Regulatory Notes (India-Specific)

| Requirement | Status | Notes |
|-------------|--------|-------|
| PMLA 2002 — CTR ≥ ₹10 lakh | ⚠️ Partial | No automated CTR trigger; no hard deposit cap enforcement |
| PMLA 2002 — STR (Suspicious Transaction) | ⚠️ Partial | Audit logs exist but no automated STR flagging logic visible |
| RBI Virtual Currency Guidelines | ❌ Check | Confirm INR on/off ramp complies with current RBI stance |
| FIU-IND Registration | ❓ Unknown | Must register as VASP with FIU-IND before going live |
| FATF Travel Rule (VASP-to-VASP) | ❌ Missing | No Travel Rule implementation visible for transfers > $1000 |
| DPDP Act 2023 — Data Minimisation | ⚠️ Review | INR withdrawal records store full bank account numbers; confirm encryption at rest |
| KYC — Video KYC / Aadhaar eKYC | ❓ Unknown | Only document upload KYC visible; SEBI requires video KYC for certain transaction thresholds |

---

## Part 4 — Prioritised Fix Roadmap

### Phase 1 — Before Any User Funds Are Accepted (Days 1–7)

| Priority | Issue | Owner | Effort |
|----------|-------|-------|--------|
| 🔴 1 | Disable SOL deposits; fix Solana HD derivation (ed25519) | Backend | 4h |
| 🔴 2 | Disable or clearly label swap/bridge as simulated | Backend | 1h |
| 🔴 3 | Enable Content-Security-Policy in Helmet | Backend | 2h |
| 🔴 4 | Restrict source browser to `superadmin` only; add re-auth for ZIP download | Backend | 2h |
| 🟠 5 | Add `jti` + `nbf` to JWT; implement per-token revocation | Backend | 6h |
| 🟠 6 | Add INR deposit hard cap (₹10 lakh) + daily limit | Backend | 2h |

### Phase 2 — Within 30 Days of Launch

| Priority | Issue | Owner | Effort |
|----------|-------|-------|--------|
| 🟠 7 | Fix crypto-vault fixed salt → per-record random salt | Backend | 8h (+ data migration) |
| 🟠 8 | Increase admin scrypt N to 65536 | Backend | 2h |
| 🟠 9 | Enforce 2FA for admin/superadmin accounts | Backend | 4h |
| 🟠 10 | Add request timeouts on all external API calls | Backend | 2h |
| 🟡 11 | Flutter: Add jailbreak detection | Mobile | 3h |
| 🟡 12 | Flutter: Add screenshot prevention on sensitive screens | Mobile | 2h |
| 🟡 13 | Fix INR admin filter to DB-layer | Backend | 1h |
| 🟡 14 | WebSocket: validate JWT on HTTP upgrade | Backend | 3h |

### Phase 3 — Compliance (Before Scale-Up)

| Priority | Issue | Owner | Effort |
|----------|-------|-------|--------|
| 15 | Integrate live OFAC/FATF sanctions API | Backend | 2 days |
| 16 | Implement CTR auto-trigger and STR flagging | Backend | 3 days |
| 17 | FATF Travel Rule implementation | Backend | 1 week |
| 18 | FIU-IND VASP registration | Legal/Compliance | Ongoing |

---

## Appendix A — Files Audited

### Flutter
- `lib/core/api/api_client.dart`
- `lib/core/api/auth_interceptor.dart`
- `lib/core/services/ws_service.dart`
- `lib/main.dart`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/network_security_config.xml`
- `lib/features/wallet/withdraw_screen.dart`
- `lib/features/trading/spot_trading_screen.dart`
- `lib/features/auth/login_screen.dart`
- `lib/core/widgets/app_lock_wrapper.dart`

### Backend API Server
- `app.ts` — Express setup, Helmet, CORS, rate limiting, middleware chain
- `lib/auth.ts` — session management, bcrypt
- `lib/jwt.ts` — custom HMAC-HS256 JWT implementation
- `lib/crypto-vault.ts` — AES-256-GCM key derivation and encryption
- `lib/hd-wallet.ts` — HD wallet derivation (BTC, ETH, SOL, TRX, BNB)
- `lib/admin-vault.ts` — admin credential encryption
- `lib/razorpay.ts` — Razorpay payment integration
- `lib/audit.ts` — admin action audit logging
- `lib/sanctions.ts` — OFAC/UN/FATF sanctions screening
- `middlewares/auth.ts` — requireAuth, requireRole, requireKyc
- `routes/auth.ts` — registration, login, OTP, 2FA
- `routes/admin.ts` — user management, KYC approval
- `routes/admin-system.ts` — system health, INR transaction approval
- `routes/admin-source.ts` — source code browser and DB introspection
- `routes/webhooks.ts` — Razorpay webhook processing
- `routes/web3.ts` — swap, bridge (simulated)
- `routes/inr.ts` — INR deposit/withdrawal
- `routes/redis-admin.ts` — Redis management, cache config, matching engine

---

*Report generated by automated audit + manual code review. All findings should be verified by a qualified security engineer before remediation.*
