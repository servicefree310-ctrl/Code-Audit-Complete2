---
name: Zebvix API response shapes
description: Confirmed live response shapes for zebvix.com/api — critical mismatches with Flutter code corrected.
---

## Confirmed shapes (curl-verified, June 2026)

| Endpoint | Actual response | Flutter bug fixed |
|---|---|---|
| GET /v1/markets | `{"markets":[...], "count":N, "ts":N}` | Was reading `data['data']`, fixed to `data['markets']` |
| GET /v1/markets/gainers | `{"markets":[...], "count":N, "ts":N}` | Was reading `gainersData['gainers']`, fixed to `data['markets']` |
| GET /v1/markets/losers | `{"markets":[...], "count":N, "ts":N}` | Separate call added (was sharing gainers call) |
| GET /v1/ticker?limit=N | `{"tickers":[...], "count":N, "ts":N}` | Was cast as plain List, fixed to `data['tickers']` |
| GET /v1/ticker/:symbol | HTML 404 — does NOT exist | Fixed: use `/v1/markets?search={pair}&limit=1` instead |
| GET /v1/orderbook?symbol=X | `{"symbol","bids":[{price,qty}],"asks":[{price,qty}]}` | Was using path param, fixed to query param |
| GET /v1/coin/:symbol | `{"currentPrice":"63207.37","change24h":-1.24,"priceUsd":..., "name":...}` | Was reading `price`/`changePercent`, fixed to `currentPrice`/`change24h` |

## Auth flow shapes
- `POST /auth/login` → `{token, user}` (direct) OR `202 + {challenge}` (MFA)
- `POST /auth/register` → `{token, user}` (direct) OR `202 + {challenge}` (OTP policy)
- `POST /otp/send` → `{success: true}` — for resend/forgot-password
- `POST /otp/verify` → `{success: true}`

## Backend CORS note
Backend requires Origin/Referer header for cookie-authenticated requests.
curl without headers gets 403. Flutter web browser sends Origin automatically — so NOT a problem for the app.

**Why:** Backend has CSRF protection for cookie-based auth; Bearer token flow (mobile) does not require it.

## Fields normalized in spot_trading_screen
When fetching ticker via markets endpoint, normalize:
- `market['lastPrice']` → `ticker['price']`
- `market['change24h']` → `ticker['changePercent']`
