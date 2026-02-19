# 🌸 Masika - Premium Menstrual Wellness Platform

<div align="center">

![Masika Logo](assets/logo.png)

**Personalized cycle tracking, AI-driven insights, and holistic wellness support**

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red)]()

</div>

---

## 📱 Overview

**Masika** is a production-ready, premium Flutter mobile application designed for menstrual health tracking and wellness support. Built with a cohesive, emotionally supportive design language, the app provides personalized insights, cycle-synced lifestyle recommendations, educational content, and e-commerce features.

### **Key Highlights:**
- 🎨 **Premium UI/UX** - Cohesive design system with warm, calming aesthetics
- 🤖 **AI Coach** - Personalized wellness guidance (mock engine, ML-ready)
- 📊 **Cycle Tracking** - Comprehensive logging with offline support
- 🛍️ **Integrated Shop** - Wellness products with secure payments
- 📚 **Educational Content** - Videos and articles by phase
- 🌍 **Multilingual** - English, Hindi, Telugu, Bengali (24+ ready)
- 📄 **PDF Reports** - Export health insights
- 🏆 **Rewards System** - Points for engagement

---

## ✨ Features

### **1. Cycle Tracking & Management**
- Log period start/end dates with calendar interface
- Track symptoms with multi-select options
- Record mood states throughout cycle
- Log flow intensity levels
- View history with edit capability
- Offline-first with Hive + Firestore sync
- Phase-aware color coding

### **2. Personalized Dashboard**
- **Masika Coach Card** - AI-driven daily messages
- **Today's Schedule** - Cycle-synced activities (workout, nutrition, rest)
- **Recommendations Grid** - Shop products, articles, wellness tips
- **Cycle Day Indicator** - Current day and phase display
- **Quick Actions** - FAB for instant cycle logging

### **3. Health Insights (Mock AI Engine)**
- Rule-based health recommendations
- Manual hemoglobin input for analysis
- Structured report generation:
  - Health summary
  - Possible causes
  - What it means
  - Action recommendations
  - When to consult doctor
- Medical disclaimer included
- PDF export with share capability

### **4. E-Commerce Shop**
- Product catalog (pads, supplements, wellness drinks)
- Detailed product pages with descriptions
- Shopping cart with quantity management
- Razorpay payment gateway (sandbox mode)
- Order history tracking
- Rewards points integration

### **5. Video Library**
- Categorized content (hygiene, nutrition, cycle education)
- Language-based filtering
- Watch history tracking
- Rewards for video completion
- Curated wellness content

### **6. Doctor Consultation**
- Doctor selection interface
- Time slot booking system
- Add consultation notes
- Appointment history
- Mock booking (video call ready for integration)

### **7. Rewards System**
- Earn points for:
  - Daily cycle logging
  - Product purchases
  - Video watching
- Points history with reasons
- Redeem screen for discounts
- Future: Unlock premium features

### **8. Multilingual Support**
- Dynamic language switching
- JSON-based translations
- Currently supported:
  - English (en)
  - Hindi (hi)
  - Telugu (te)
  - Bengali (bn)
- Architecture supports 24+ languages
- All UI text localized

---

## 🎨 Design System

### **Premium Visual Language**

**Philosophy:** Warm, calming, and emotionally supportive design that reflects the wellness context of menstrual health.

#### **Color Palette:**
```
🟥 Primary: #8B1538 (Deep Burgundy)
   - Brand identity, CTAs, active states

🟪 Secondary: #FF6B9D (Vibrant Pink)
   - Highlights, icons, delightful moments

🌸 Accent: #EAA0B7 (Soft Rose)
   - Subtle touches, backgrounds

⬜ Surfaces: #FFFFFF (White) / #FAF8F9 (Off-white)
   - Cards and screen backgrounds

Phase Colors:
🟣 Follicular: #E8D4F8 (Purple)
🟡 Ovulation: #FFF4CC (Yellow)
🟪 Luteal: #FFE8EE (Pink)
🔴 Menstrual: #FFCDD2 (Red)
```

#### **Typography:**
**Primary Font:** Plus Jakarta Sans (modern, clean, readable)
**Secondary Font:** Playfair Display (elegant, decorative)

**Text Hierarchy:**
- Display (48-36px) - Hero sections
- Headline (32-24px) - Page titles
- Title (22-16px) - Card headers
- Body (16-14px) - Content
- Label (14-11px) - Form labels
- Button (16-12px) - Action text

#### **Spacing System:**
**Base Unit:** 4px for pixel-perfect layouts
**Values:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80px

#### **Shadows:**
- Multi-layered shadows for realistic depth
- Colored shadows for branded elements
- Subtle shadows for cards (2-4px offset)
- Strong shadows for modals (8-12px offset)

---

## 🏗️ Architecture

### **Clean Architecture Principles**

```
lib/
├── core/                    # Core business logic
│   ├── constants/           # App constants, Firestore collection names
│   ├── localization/        # i18n support with JSON files
│   ├── services/            # External services (Firebase, Hive, AI, PDF, Payment)
│   ├── theme/               # ✨ Complete design system
│   │   ├── app_colors.dart      # 30+ color tokens
│   │   ├── app_typography.dart  # 21 text styles
│   │   ├── app_spacing.dart     # Spacing & sizing system
│   │   ├── app_shadows.dart     # Shadow definitions
│   │   └── app_theme.dart       # Main theme configuration
│   └── utils/               # Validators and utilities
│
├── features/                # Feature modules (feature-first structure)
│   ├── auth/                # Authentication & user management
│   │   ├── data/                # User repository
│   │   └── presentation/        # Login, profile screens
│   ├── onboarding/          # First-time user experience
│   │   └── presentation/        # Splash, personalization, radical care
│   ├── dashboard/           # Main dashboard & home
│   │   ├── presentation/
│   │   │   ├── screens/         # Dashboard, shell
│   │   │   └── widgets/         # Coach card, schedule card, recommendation card
│   ├── cycle_tracking/      # Menstrual cycle logging
│   │   ├── data/                # Cycle repository
│   │   └── presentation/        # Log, history, calendar screens
│   ├── health_insights/     # AI-style health recommendations
│   │   └── presentation/        # Insight screen, report generation
│   ├── insights/            # Educational articles
│   │   └── presentation/        # Article list, detail screens
│   ├── shop/                # E-commerce module
│   │   └── presentation/        # Product list, detail screens
│   ├── cart/                # Shopping cart
│   │   └── presentation/        # Cart screen, checkout
│   ├── orders/              # Order management
│   │   └── presentation/        # Order history
│   ├── videos/              # Educational video library
│   │   └── presentation/        # Video list with filters
│   ├── consultation/        # Doctor booking
│   │   └── presentation/        # Consultation screen
│   ├── rewards/             # Rewards & points
│   │   └── presentation/        # Points screen, redeem
│   ├── reports/             # PDF report export
│   │   └── presentation/        # Reports screen
│   └── splash/              # Splash screen
│       └── presentation/        # Animated splash
│
├── shared/                  # Shared resources
│   ├── models/              # Data models (10+ models)
│   │   ├── user_profile.dart
│   │   ├── cycle_log.dart
│   │   ├── product.dart
│   │   ├── schedule_item.dart
│   │   ├── recommendation.dart
│   │   └── [others].dart
│   ├── providers/           # Riverpod state providers
│   │   └── app_providers.dart   # Global state
│   └── widgets/             # Reusable UI components
│       ├── premium_button.dart  # ✨ Premium button
│       ├── premium_card.dart    # ✨ Premium card
│       ├── premium_input.dart   # ✨ Premium input
│       ├── loading_widget.dart  # Loading states
│       ├── empty_state_widget.dart # Empty states
│       ├── app_card.dart        # Legacy card
│       ├── primary_button.dart  # Legacy button
│       └── section_header.dart  # Section headers
│
└── main.dart                # App entry point
```

---

## 🔧 Tech Stack

### **Framework & Language:**
- **Flutter:** 3.10.4+ (latest stable)
- **Dart:** 3.0+ with null safety
- **Material 3:** Modern design system

### **State Management:**
- **Riverpod:** 2.6.1 - Reactive state management
- **StateNotifier:** Complex state logic
- **ProviderScope:** Global state container

### **Backend & Storage:**
- **Firebase Core:** 3.15.0 - Platform initialization
- **Firebase Auth:** 5.3.0 - Phone OTP, email auth
- **Cloud Firestore:** 5.4.0 - NoSQL database
- **Firebase Storage:** 12.3.0 - Media storage
- **Hive:** 2.2.3 - Local NoSQL database
- **Hive Flutter:** 1.1.0 - Flutter integration
- **Secure Storage:** 9.2.2 - Encrypted local storage

### **UI & Design:**
- **Google Fonts:** 6.2.1 - Premium typography
- **Flutter Animate:** 4.5.0 - Smooth animations
- **Material 3:** Built-in components

### **Features:**
- **Razorpay Flutter:** 1.4.0 - Payment gateway (sandbox)
- **PDF:** 3.11.1 - Document generation
- **Printing:** 5.13.0 - PDF sharing
- **UUID:** 4.5.1 - Unique ID generation
- **Intl:** 0.20.2 - Date formatting

---

## 🚀 Getting Started

### **Prerequisites:**
- Flutter SDK 3.10.4 or higher
- Android Studio / VS Code with Flutter extension
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)
- Firebase account

### **Installation Steps:**

#### **1. Clone Repository:**
```bash
git clone <repository-url>
cd masika
```

#### **2. Install Dependencies:**
```bash
flutter pub get
```

#### **3. Firebase Configuration:**

**For Android:**
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app to project
3. Download `google-services.json`
4. Place in `android/app/`

**For iOS:**
1. Add iOS app to Firebase project
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/`

**Enable Firebase services:**
- Authentication (Phone, Email providers)
- Cloud Firestore
- Firebase Storage

#### **4. Run Application:**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

#### **5. Build Release:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📖 Usage Guide

### **First Time Setup:**

1. **Launch App** → See animated splash screen (3s)
2. **Personalization** → Learn about features
3. **Radical Care** → Brand philosophy
4. **Welcome Screen** → Login or continue as guest
5. **Dashboard** → Start tracking!

### **Guest Mode:**
- Instant access without signup
- All features available
- Data stored locally
- Optional account creation later

### **Cycle Logging:**
1. Tap **➕ button** in bottom nav
2. Select start/end dates
3. Choose symptoms
4. Log mood and flow
5. Save → Syncs automatically

### **Health Insights:**
1. Navigate to **Insights** tab
2. View AI-generated recommendations
3. Enter hemoglobin (optional)
4. Generate detailed report
5. Export to PDF and share

### **Shopping:**
1. Browse **Shop** tab
2. View product details
3. Add to cart
4. Checkout with Razorpay
5. Track order status

---

## 🎯 Key Components

### **Premium Components:**

#### **PremiumButton:**
```dart
PremiumButton(
  text: 'Continue',
  onPressed: () {},
  type: ButtonType.primary,  // primary, secondary, outline, text
  size: ButtonSize.large,    // small, medium, large
  icon: Icons.arrow_forward,
  isLoading: false,
  fullWidth: true,
)
```

#### **PremiumCard:**
```dart
PremiumCard(
  type: CardType.elevated,  // elevated, flat, gradient
  onTap: () {},
  child: Column(
    children: [
      Text('Title', style: AppTypography.titleMedium),
      Text('Description', style: AppTypography.bodyMedium),
    ],
  ),
)
```

#### **PremiumInput:**
```dart
PremiumInput(
  label: 'EMAIL ADDRESS',
  hint: 'Enter your email',
  prefixIcon: Icons.email_outlined,
  controller: _emailController,
  validator: (value) => Validators.email(value),
)
```

---

## 🎨 Design System

### **Using Design Tokens:**

```dart
// Import design system
import 'package:masika/core/theme/app_colors.dart';
import 'package:masika/core/theme/app_typography.dart';
import 'package:masika/core/theme/app_spacing.dart';
import 'package:masika/core/theme/app_shadows.dart';

// Use in widgets
Container(
  color: AppColors.primary,
  padding: EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.cardShadow,
  ),
  child: Text(
    'Welcome',
    style: AppTypography.titleLarge.copyWith(
      color: AppColors.textOnPrimary,
    ),
  ),
)
```

### **Design System Benefits:**
- ✅ **Consistency:** Same look & feel across all screens
- ✅ **Maintainability:** Change once, update everywhere
- ✅ **Type Safety:** Compile-time checks, no typos
- ✅ **Scalability:** Easy to add new variants
- ✅ **Professional:** Industry-standard approach

---

## 🗂️ Project Structure

### **Features Module (Feature-First):**
Each feature is self-contained with:
- **data/** - Repositories, data sources
- **domain/** - Business logic (if complex)
- **presentation/** - UI screens and widgets

### **Shared Resources:**
- **models/** - Data classes with JSON serialization
- **providers/** - Riverpod state management
- **widgets/** - Reusable UI components

### **Core Services:**
- **firebase_service.dart** - Firebase initialization
- **hive_service.dart** - Local database
- **ai_insight_service.dart** - Mock AI engine (ML-ready)
- **payment_service.dart** - Razorpay integration
- **pdf_service.dart** - Report generation
- **secure_storage_service.dart** - Encrypted storage

---

## 🔐 Security & Privacy

### **Data Security:**
- 🔒 **Encrypted Storage** - Sensitive data with `flutter_secure_storage`
- 🔒 **Firebase Rules** - Firestore security rules
- 🔒 **HTTPS Only** - All API calls encrypted
- 🔒 **Token Management** - Secure auth token handling

### **Privacy Features:**
- 🛡️ **Guest Mode** - No data collection
- 🛡️ **Local-First** - Data stored on device
- 🛡️ **Optional Sync** - User controls cloud backup
- 🛡️ **Disclaimers** - Clear medical & privacy notices
- 🛡️ **Data Export** - PDF reports owned by user

---

## 🌍 Internationalization

### **Language Files:**
```
assets/lang/
├── en.json  # English (default)
├── hi.json  # Hindi
├── te.json  # Telugu
└── bn.json  # Bengali
```

### **Adding New Language:**

**Step 1:** Create language file:
```bash
cp assets/lang/en.json assets/lang/ta.json  # Tamil example
```

**Step 2:** Translate all keys:
```json
{
  "login": "உள்நுழைய",
  "register": "பதிவு செய்யவும்",
  "welcome_back": "மீண்டும் வரவேற்கிறோம்",
  ...
}
```

**Step 3:** Add locale to `app_localizations.dart`:
```dart
static const supportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('te'),
  Locale('bn'),
  Locale('ta'),  // Add new locale
];
```

---

## 🔄 State Management

### **Riverpod Providers:**

#### **Global State:**
```dart
localeProvider           // App language
userProfileProvider      // User data with Hive cache
navIndexProvider         // Bottom navigation
```

#### **Feature State:**
```dart
cycleLogsProvider        // Cycle tracking data
cartProvider             // Shopping cart items
rewardsProvider          // Points & rewards
ordersProvider           // Order history
appointmentsProvider     // Consultation bookings
```

### **Usage Example:**
```dart
// Read state
final profile = ref.watch(userProfileProvider);

// Update state
ref.read(userProfileProvider.notifier).setProfile(newProfile);

// Listen to changes
ref.listen(cartProvider, (previous, next) {
  // React to cart changes
});
```

---

## 🔥 Firebase Integration

### **Collections Schema:**

#### **users/**
```typescript
{
  id: string
  name: string
  age: number
  languageCode: string
  cycleLength: number
  periodDuration: number
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### **cycles/**
```typescript
{
  id: string
  userId: string
  startDate: timestamp
  endDate: timestamp?
  symptoms: string[]
  mood: string
  flowIntensity: string
  notes: string?
  createdAt: timestamp
}
```

#### **products/**
```typescript
{
  id: string
  name: string
  description: string
  price: number
  imageUrl: string
  category: string
  stock: number
  rating: number?
}
```

#### **orders/**
```typescript
{
  id: string
  userId: string
  items: CartItem[]
  totalAmount: number
  status: 'pending' | 'paid' | 'shipped' | 'delivered'
  paymentId: string?
  createdAt: timestamp
}
```

---

## 💳 Payment Integration

### **Razorpay (Sandbox Mode):**

```dart
import 'package:masika/core/services/payment_service.dart';

// Initialize payment
final paymentService = PaymentService();

await paymentService.initiatePayment(
  amount: 2400,  // Amount in paise (₹24.00)
  orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
  onSuccess: (response) {
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    // Update order status
  },
  onFailure: (response) {
    print('Error: ${response.message}');
    // Handle payment failure
  },
);
```

**Test Cards:** Use Razorpay test cards for development
**Production:** Switch to live keys in production

---

## 📄 PDF Generation

### **Export Health Report:**

```dart
import 'package:masika/core/services/pdf_service.dart';

final pdfService = PdfService();

await pdfService.generateHealthReport(
  userName: 'Sarah',
  insight: healthInsight,
  labels: {
    'title': 'Health Insight Report',
    'summary': 'Summary',
    'causes': 'Possible Causes',
    'recommendations': 'Recommendations',
    'disclaimer': 'Medical Disclaimer',
  },
);
```

**Features:**
- Professional layout
- User data summary
- Cycle statistics
- AI insights
- Recommendations
- Disclaimer
- Share via system dialog

---

## 🎬 Animation System

### **Page Transitions:**
```dart
// Fade transition
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(opacity: animation, child: child);
  },
  transitionDuration: const Duration(milliseconds: 400),
)

// Slide + Fade
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}
```

### **Micro-interactions:**
- Button press feedback
- Card tap effects
- Tab switching animations
- Form field focus states
- Loading states

---

## 📊 Performance

### **Optimizations Applied:**
- ✅ **const constructors** throughout codebase
- ✅ **Efficient rebuilds** with Riverpod selectors
- ✅ **Lazy loading** for lists
- ✅ **Image caching** (Hive + Firebase)
- ✅ **Offline-first** architecture
- ✅ **GPU-accelerated** animations
- ✅ **Tree shaking** for production builds

### **Performance Targets:**
- **Frame Rate:** 60fps (smooth UI)
- **Page Load:** < 300ms
- **State Update:** < 100ms
- **Initial Launch:** < 3s
- **Memory Usage:** < 150MB

### **Profiling:**
```bash
# Check performance
flutter run --profile

# Analyze build size
flutter build apk --analyze-size

# Check memory
flutter run --profile --dart-define=flutter.leak_tracking.enabled=true
```

---

## 🧪 Testing

### **Run Tests:**
```bash
# All tests
flutter test

# Specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

### **Test Structure:**
```
test/
├── unit/
│   ├── models_test.dart
│   ├── services_test.dart
│   └── validators_test.dart
├── widget/
│   ├── components_test.dart
│   └── screens_test.dart
└── integration/
    └── user_flow_test.dart
```

---

## 🐛 Troubleshooting

### **Common Issues:**

#### **1. Build Fails (Windows):**
```bash
# Enable Developer Mode (Windows)
# Or run as Administrator:

flutter clean
flutter pub get
flutter run
```

#### **2. Firebase Not Initialized:**
```bash
# Ensure google-services.json exists
ls android/app/google-services.json

# Check Firebase initialization in main.dart
await FirebaseService.initialize();
```

#### **3. Hive Errors:**
```bash
# Clear Hive boxes
flutter clean
rm -rf build/

# Re-run
flutter run
```

#### **4. Payment Integration:**
```bash
# Use Razorpay test mode
# Sandbox keys in payment_service.dart
# Test cards: https://razorpay.com/docs/payments/payments/test-card-details/
```

---

## 📱 Screen Flow

### **Complete User Journey:**

```
┌─────────────────────────────────────────────────────────┐
│                    App Launch                            │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────┐
        │    Splash Screen        │ (3 seconds)
        │    Animated logo        │
        └─────────┬───────────────┘
                  │
                  ▼
        ┌─────────────────────────┐
        │  Personalization        │ (First time only)
        │  Feature introduction   │
        └─────────┬───────────────┘
                  │
                  ▼
        ┌─────────────────────────┐
        │   Radical Care          │ (First time only)
        │   Brand philosophy      │
        └─────────┬───────────────┘
                  │
                  ▼
        ┌─────────────────────────┐
        │   Welcome Screen        │
        │   Login / Register      │
        │   Guest Mode            │
        └───┬───────────┬─────────┘
            │           │
            │           └─────► Profile Setup → Dashboard
            │
            ▼
    ┌───────────────────────────────────────────┐
    │           Dashboard Shell                 │
    │  ┌─────────────────────────────────────┐ │
    │  │  Home | Insights | ➕ | Shop | Profile│ │
    │  └─────────────────────────────────────┘ │
    └───────────────────────────────────────────┘
            │
            ├───► Home (Dashboard)
            │      - Coach card
            │      - Schedule
            │      - Recommendations
            │
            ├───► Insights (Articles)
            │      - Health tips
            │      - Cycle education
            │
            ├───► ➕ (Quick Log)
            │      - Log period
            │      - Track symptoms
            │
            ├───► Shop (E-commerce)
            │      - Products
            │      - Cart
            │      - Checkout
            │
            └───► Profile (Settings)
                   - User info
                   - Language
                   - Preferences
```

---

## 🎨 Theme Customization

### **Changing Brand Colors:**

Edit `lib/core/theme/app_colors.dart`:
```dart
static const primary = Color(0xFF8B1538);  // Change to your color
static const secondary = Color(0xFFFF6B9D);  // Change accent
```

All components automatically update!

### **Changing Fonts:**

Edit `lib/core/theme/app_typography.dart`:
```dart
static String get primaryFont => 'Your Font Name';

// Update all text styles
static TextStyle displayLarge = GoogleFonts.yourFont(
  fontSize: 48,
  fontWeight: FontWeight.w800,
);
```

### **Adjusting Spacing:**

Edit `lib/core/theme/app_spacing.dart`:
```dart
static const double unit = 4.0;  // Change base unit

// All spacing scales automatically
```

---

## 🚀 Deployment

### **Pre-Deployment Checklist:**

#### **Code:**
- [ ] Remove debug prints
- [ ] Remove unused imports
- [ ] Run `flutter analyze` (no errors)
- [ ] Run tests (`flutter test`)
- [ ] Check memory leaks

#### **Assets:**
- [ ] Optimize images
- [ ] Remove unused assets
- [ ] Update app icon
- [ ] Update splash screen

#### **Configuration:**
- [ ] Update version in `pubspec.yaml`
- [ ] Set proper app ID in `android/app/build.gradle.kts`
- [ ] Configure ProGuard rules
- [ ] Update Firebase for production
- [ ] Switch Razorpay to live keys

#### **Testing:**
- [ ] Test on multiple devices
- [ ] Test all user flows
- [ ] Test payment gateway
- [ ] Test offline mode
- [ ] Test all languages

### **Android Release:**

**Step 1:** Generate signing key:
```bash
keytool -genkey -v -keystore ~/masika-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias masika
```

**Step 2:** Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=masika
storeFile=<path-to-jks>
```

**Step 3:** Build:
```bash
flutter build appbundle --release
```

**Step 4:** Upload to Play Console

### **iOS Release:**

**Step 1:** Open Xcode:
```bash
open ios/Runner.xcworkspace
```

**Step 2:** Configure signing

**Step 3:** Archive:
- Product → Archive
- Upload to App Store Connect

---

## 📈 Analytics & Monitoring

### **Firebase Analytics (Ready):**
```dart
// Track events
await FirebaseAnalytics.instance.logEvent(
  name: 'cycle_logged',
  parameters: {'day': 1, 'phase': 'menstrual'},
);

// Track screens
await FirebaseAnalytics.instance.setCurrentScreen(
  screenName: 'Dashboard',
);
```

### **Crashlytics (Ready):**
```dart
// Report errors
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'User action failed',
);
```

---

## 🤝 Contributing

### **Development Workflow:**

1. **Create Feature Branch:**
```bash
git checkout -b feature/new-feature
```

2. **Follow Design System:**
   - Use `AppColors` for colors
   - Use `AppTypography` for text
   - Use `AppSpacing` for layout
   - Use premium components

3. **Test Thoroughly:**
```bash
flutter test
flutter analyze
```

4. **Commit & Push:**
```bash
git add .
git commit -m "Add: New feature"
git push origin feature/new-feature
```

5. **Create Pull Request**

---

## 📞 Support

### **Documentation:**
- `README.md` - This file
- `PREMIUM_UPGRADE_COMPLETE.md` - Design system details
- `PRODUCTION_READY_GUIDE.md` - Technical guide
- `DASHBOARD_REBUILD_SUMMARY.md` - Dashboard specifics
- `PERSONALIZATION_PIXEL_PERFECT.md` - Onboarding details

### **Code Comments:**
- Inline documentation throughout codebase
- Widget descriptions
- Function documentation
- Architecture decisions

---

## 📋 Changelog

### **v1.0.0 - Initial Production Release**

**✨ Features:**
- Complete menstrual health platform
- Premium UI with design system
- Multilingual support (4 languages)
- Offline-first architecture
- E-commerce integration
- AI health insights
- Educational content
- Doctor consultations
- Rewards system

**🎨 Design:**
- Comprehensive design system
- Google Fonts integration
- 30+ color tokens
- 21 text styles
- Premium shadows & effects
- Cohesive visual language

**🔧 Technical:**
- Clean architecture
- Riverpod state management
- Firebase backend
- Hive local storage
- Razorpay payments
- PDF generation
- Secure storage

**🐛 Bug Fixes:**
- Fixed navigation blank screens
- Fixed layout overflow issues
- Fixed theme inconsistencies
- Optimized performance
- Removed unused code

---

## 🎉 Status

### **Production Ready:**
- ✅ **Design System** - Complete and documented
- ✅ **Premium UI** - All screens polished
- ✅ **State Management** - Riverpod configured
- ✅ **Backend** - Firebase integrated
- ✅ **Payments** - Razorpay working
- ✅ **Localization** - 4 languages supported
- ✅ **Testing** - Basic tests included
- ✅ **Documentation** - Comprehensive guides

### **Ready For:**
- 🚀 Production deployment
- 🚀 App Store submission
- 🚀 Play Store submission
- 🚀 User testing
- 🚀 Marketing launch

---

## 📄 License

**Private** - All rights reserved

---

## 🌟 Conclusion

Masika is a **production-ready**, **premium-quality** Flutter application with a cohesive, warm, and supportive design language. The comprehensive design system, clean architecture, and professional polish make it ready for immediate deployment to production.

**Built with ❤️ for menstrual wellness**

---

<div align="center">

**Masika v1.0.0**

Made with Flutter 🚀

</div>
