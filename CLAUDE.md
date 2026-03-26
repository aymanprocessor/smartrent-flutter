# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run all tests
flutter test

# Run a single test file
flutter test test/wallet_controller_test.dart

# Lint / analyze
flutter analyze

# Generate localization files (after editing .arb files)
flutter gen-l10n

# Get dependencies
flutter pub get
```

## Architecture

**Stack:** Flutter 3.32.x · GetX 4.7.2 · Laravel REST API · Firebase FCM · Pusher Channels · Moyasar payments

### Feature Structure (MVVM via GetX)

Every feature lives under `lib/views/<feature>/` with this exact layout:

```
screen/
  feature_screen.dart          ← GetView<Controller> → ResponsiveLayout(mobile:, tablet:)
  feature_mobile_screen.dart   ← `part of` feature_screen.dart
  feature_tablet_screen.dart   ← `part of` feature_screen.dart
controller/
  feature_controller.dart      ← GetxController with .obs state
widget/
  *.dart                       ← feature-scoped widgets
model/
  *.dart                       ← data models with fromJson factories
```

Screen files use `part of` / `part` directives — never standalone imports.

### Routing

- Route string constants: `lib/routes/routes.dart`
- `GetPage` registrations: `lib/routes/route_pages.dart` (a `part` file)
- Navigate: `Get.toNamed(Routes.historyDetailScreen, arguments: {'history': obj})`
- Arguments always pass as `Map<String, dynamic>` and are read in `controller.onInit()` via `Get.arguments`

### Bindings

Every route has a binding in `lib/bindings/` using `Get.lazyPut`. Register all controllers there — never `Get.put()` inside widgets.

### API Layer

- All endpoints are `enum ApiEndpoint` values in `lib/base/api/endpoint/api_endpoint.dart`
- Use `RequestProcess().request<T>(fromJson:, apiEndpoint:, isLoading:, onSuccess:)` for every API call
- Base URL: `ApiConfig.mainDomain` — **currently hardcoded to local dev IP `192.168.1.11:8000`; change for production** (production: `https://smartrent.sa`)
- Endpoints with path params use `.withId(int id)` — e.g. `ApiEndpoint.bookingCancel.withId(bookingId)`

### Key Files

| Purpose | Path |
|---|---|
| App entry | `lib/main.dart` |
| Global barrel import | `lib/base/utils/basic_import.dart` |
| API config & endpoints | `lib/base/api/endpoint/api_endpoint.dart` |
| Request wrapper | `lib/base/api/method/request_process.dart` |
| Global settings service | `lib/base/api/services/basic_services.dart` |
| Routes | `lib/routes/routes.dart` + `lib/routes/route_pages.dart` |
| I18n keys | `lib/languages/strings.dart` |
| Booking validation rules | `lib/base/utils/booking_validators.dart` |

## Key Conventions

### Localization
Always use `DynamicLanguage.key(Strings.someKey)` — never hardcode user-facing strings. Keys are defined in `lib/languages/strings.dart`. ARB source files: `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

### Common Imports
`import '../../../base/utils/basic_import.dart'` provides `Get`, common widgets, `ResponsiveLayout`, `CustomColor`, spacing utils, etc. Use it instead of individual imports.

### Controller / UI Separation (strict)
- Controllers: **no** `Get.snackbar()`, **no** `Get.back()`, **no** UI calls. Return result objects to the UI.
- UI layer: handles all snackbars, dialogs, and navigation based on controller result objects.

### Dialogs — Critical GetX Bug
**Never use `Get.dialog()` + `Get.back()` together.** GetX's `back()` calls `closeCurrentSnackbar()` which crashes with `LateInitializationError`.
✅ Always use `showDialog(context: Get.context!, builder: (ctx) => ...) ` + `Navigator.pop(ctx)`.

### State Management
- Reactive: `final foo = false.obs;` → `Obx(() => ...)` in UI
- Non-reactive refresh: `GetBuilder<Controller>` + `controller.update()`

### Race Conditions
- Guard async actions with `isLoading.obs` flag; disable button while `true`
- Defer navigation from `onInit()` with `WidgetsBinding.instance.addPostFrameCallback`
- Check `if (isClosed) return;` after `await` in controllers
- Use generation counter for overlapping async calls

### Real-time & Notifications
- **Pusher Channels** (`RealtimeService`): live booking updates from Laravel broadcasting
- **Firebase FCM + Pusher Beams**: push notifications — initialized **after** user login in splash/login flow, not in `main()`
- **awesome_notifications**: local notification display
- Notification taps navigate via `NotificationNavigation.goToHistoryDetail(historyId: id)`

### UI Design System
Premium screens define private `_C` (colors), `_S` (8px-grid spacing), `_R` (border radii), `_Shadow` classes at the top of the barrel file. Global theme tokens are in `lib/base/themes/`.

### GetX `lazyPut` Guard
When accessing a controller that may not be registered yet (e.g. from a deep-link or notification):
```dart
final ctrl = Get.isRegistered<MyController>()
    ? Get.find<MyController>()
    : Get.put(MyController());
```
