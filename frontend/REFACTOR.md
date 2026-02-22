# Masika – Refactor & Architecture

This document describes the refactor done for frontend/backend separation, deduplication, and stabilization. **User-visible behavior and UI are unchanged.**

## Architecture (Flutter app, Firebase backend)

- **UI:** `lib/features/*/presentation/screens/` — widgets only; no direct Hive/Firestore.
- **State:** `lib/shared/providers/` — Riverpod notifiers; call repositories, not storage directly where a repo exists.
- **Data:** `lib/features/*/data/` — repositories (e.g. `cycle_repository`, `health_profile_repository`, `user_repository`); Hive/Firestore access lives here or in `core/services/`.
- **Core:** `lib/core/` — theme, constants, services (Hive, Firebase, secure storage), validators, responsive config.

## What was done

1. **Single source of truth for UI colors**  
   `lib/core/theme/app_colors.dart` now includes semantic constants (e.g. `semanticMaroon`, `semanticBgScreen`, `semanticSectionGray`) with the same hex values used in doctor_portal, cycle_tracking, dashboard, auth. New or touched screens should use `AppColors.semantic*` instead of local `const Color(0xFF...)` to avoid duplication.

2. **Centralized Hive keys**  
   `lib/core/constants/hive_keys.dart` defines all cache key names (`userProfile`, `doctorProfile`, `cycleLogs`, `onboardingCompleted`, `userHealthProfile`). `app_providers`, `main.dart`, `onboarding_storage`, and `health_profile_repository` use these constants.

3. **Validators**  
   `lib/core/utils/validators.dart` provides `requiredField`, `email`, `password`, `phone`. Use them in `TextFormField.validator` and any server-bound input to keep validation consistent and secure.

4. **TODO cleanup**  
   The single TODO in `app_theme.dart` (dark theme) was resolved; `darkTheme` now returns `lightTheme` with a short comment.

## What to do next (without changing behavior)

- **Migrate screens to `AppColors.semantic*`** when editing a screen (replace local color constants with the same value from `AppColors`).
- **Use `Validators`** in all forms (login, register, doctor portal, health onboarding) so validation is consistent.
- **Keep repositories as the only place** that talk to Hive/Firestore for that feature; providers should depend on repos, not `HiveService` directly where a repo exists.
- **Add tests** for `Validators`, `HiveKeys`, repositories, and critical provider flows to reach the target coverage.

## Security

- No tokens or secrets in logs or frontend code.
- Sensitive persistence uses `SecureStorageService` where appropriate.
- All form input should be validated via `Validators` before use or send.

## Validation checklist (before release)

- [ ] UI unchanged (same colors, layout, spacing).
- [ ] All features work as before (login, onboarding, cycle, doctor portal, etc.).
- [ ] No new console errors or warnings.
- [ ] Tests pass; coverage meets project target.
- [ ] No duplicate Hive key strings or color hex values in feature code (use `HiveKeys` and `AppColors`).
