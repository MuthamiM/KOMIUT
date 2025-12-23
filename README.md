# Komiut Public Transport App

A modern public transport mobile application built with Flutter, demonstrating commuter onboarding, authentication, and core interactions.

**[Download APK v1.2.2](https://github.com/MuthamiM/KOMIUT/releases/tag/v1.2.2)**

## Getting Started

### Prerequisites

- Flutter SDK: >=3.1.5 <4.0.0
- Dart SDK: Compatible with the above Flutter version
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MuthamiM/KOMIUT.git
   ```
2. Navigate to the project directory:
   ```bash
   cd KOMIUT
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The project follows Clean Architecture principles with a Feature-first folder structure. This ensures separation of concerns, scalability, and ease of testing.

### Folder Structure

- lib/core: Global constants, themes, utilities, and reusable widgets.
- lib/features: Feature-based modules (Auth, Home, Activity, Payment, Settings).
  - data: Repositories and models (Mocked).
  - presentation: UI screens and providers.
- lib/routes: Declarative routing configuration using GoRouter.

## State Management

Riverpod was chosen for state management because:

1. Compile-safe: Catches errors at compile-time rather than runtime.
2. Testable: Easily mockable and independent of the widget tree.
3. Reactive: Simplifies handling of asynchronous data states (Loading, Error, Data).
4. No context needed: Access state from anywhere in the app without passing BuildContext.

## Choice of Libraries

- GoRouter: For declarative, deep-link ready navigation.
- Google Fonts: To implement modern typography (Outfit/Inter).
- Flutter Animate: For smooth, high-performance UI transitions.
- Shared Preferences: For persistent theme and auth state storage.
- Flutter Map: For rendering real-time OpenStreetMap tiles and markers without API keys.

## Assumptions

1. Mock Data: Since no backend was required, all data is simulated to mimic network latency.
2. Auth Credentials: Use musamwange2@gmail.com / 23748124 for a successful login simulation.
3. OTP: The verification code is hardcoded to 123456.
4. Currency: All fares and balances are in Kenyan Shillings (KES) as per the localized requirement (Kenyan cities).
5. Localization: The app currently supports English but is structured for easy localization via the intl package.

## Branding

The app uses the official Komiut palette:

- Primary Yellow: #FFC107
- Deep Navy: #1A1F71
- Indigo: #5C2D91

## Security & Code Quality

### Clean Code Base

- Separation of Concerns: UI, Business Logic (Providers), and Data (Repositories) are strictly separated.
- Repository Pattern: Abstracts data source details from the UI.
- Reusable Widgets: Common UI elements (buttons, inputs, logo) are extracted for consistency and maintainability.
- Type Safety: Strong use of Dart's type system and Riverpod's compile-time safety.

### Vulnerability Prevention

- Robust Validation: All user inputs (Auth forms, Top-ups) are rigorously validated using custom regex and logic to prevent injection or invalid data states.
- Secure Navigation: Logic-based routing prevents unauthorized access to protected screens (routing handled by GoRouter based on auth state).
- Safe State Storage: User sessions are handled via Riverpod providers with clear lifecycles, and preferences are persisted using secure local storage patterns.
- Error Handling: Comprehensive try-catch blocks in repositories and UI-level error feedback prevent app crashes and exposure of system internals.

## Testing

- Unit Tests: Coverage for all form validators (test/validators_test.dart).
- Widget Tests: UI smoke tests for top-level screens (test/widget_test.dart).

Run tests using:

```bash
flutter test
```
