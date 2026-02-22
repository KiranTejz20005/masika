// ============================================================
// MASIKA APP STRUCTURE
// ============================================================
//
// This app follows a Clean Architecture pattern:
//
// FRONTEND (lib/features/)
//   ├── auth/              - Authentication screens (login, register)
//   ├── dashboard/         - Main dashboard screens
//   ├── doctor_portal/    - Doctor portal screens
//   ├── cycle_tracking/   - Period/cycle tracking screens
//   ├── health_insights/  - AI health insights
//   ├── health_onboarding/- Health profile onboarding
//   ├── shop/             - E-commerce/shop screens
//   ├── cart/             - Shopping cart
//   ├── orders/           - Order management
//   ├── rewards/          - Rewards system
//   ├── reports/          - Health reports
//   ├── consultation/     - Doctor consultations
//   ├── insights/         - Health insights
//   ├── videos/           - Video content
//   ├── notifications/   - Notifications
//   ├── onboarding/       - App onboarding
//   └── splash/           - Splash screen
//
// BACKEND (lib/backend/)
//   ├── services/
//   │   ├── auth_service.dart     - Auth (Supabase when configured)
//   │   └── database_service.dart - Database (Supabase when configured)
//   ├── models/
//   │   └── auth_result.dart      - Auth result (userId)
//   └── repositories/
//       ├── user_repository.dart   - User data operations
//       └── doctor_repository.dart - Doctor data operations
//
// CORE (lib/core/)
//   ├── theme/             - App theming (colors, typography, spacing)
//   ├── constants/        - App constants
//   ├── services/         - Core services (Supabase, Hive, PDF, etc.)
//   ├── utils/            - Utilities
//   └── localization/    - Localization
//
// SHARED (lib/shared/)
//   ├── models/           - Data models
//   ├── providers/        - Riverpod providers
//   └── widgets/          - Reusable widgets
//
// ============================================================

export 'models/auth_result.dart';
export 'services/auth_service.dart';
export 'services/database_service.dart';
export 'repositories/user_repository.dart';
export 'repositories/doctor_repository.dart';
