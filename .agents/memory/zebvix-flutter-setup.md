---
name: Zebvix Flutter web setup
description: How the Zebvix Flutter app runs in Replit and key setup facts.
---

## Workflow
- Name: "Zebvix Flutter Web"
- Command: `cd zebvix-flutter && flutter pub get && flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0`
- Do NOT add `--web-renderer` — flag removed in Flutter 3.32

## Backend
- Base URL: `https://zebvix.com/api` (hardcoded in `api_client.dart`)
- Do NOT modify the backend — it's on a VPS outside Replit

## Auth storage
- `SecureStorage` wraps `flutter_secure_storage`
- `saveTokens(accessToken, refreshToken)` — refreshToken not used (backend uses 14-day sessions)
- `clearAll()` on 401

## Key constants file
`zebvix-flutter/lib/core/constants/app_constants.dart` — source of truth for all API path constants
