# CivicConnect

CivicConnect is a Flutter-based community issue reporting application for posting, tracking, discussing, and resolving local civic problems such as road damage, garbage dumping, water leakage, electricity faults, and safety concerns.

The app uses Firebase for authentication and real-time data, Cloudinary for image uploads, OpenStreetMap for zone maps, and Firebase AI/Gemini for CivicMate, an in-app assistant that helps users write clearer reports.

## Latest Deliverables

- Latest release APK: `app-release.apk`
- Project report: `CivicConnect_Project_Report.doc`
- App launcher icon generated from: `assets/icon.png`
- NorthCap logo and supervisor signature assets:
  - `assets/images/northcap_university_logo.jpg`
  - `assets/images/nishu_signature.jpg`

## Features

- Email/password login, signup, and forgot-password flow.
- Splash screen shown on every fresh launch or browser reload.
- Create civic issue posts with description, hashtags, category, urgency, and zone.
- Upload multiple images with a post.
- Tap any post or comment image to view it fullscreen on a black background.
- Real-time issue feed powered by Cloud Firestore streams.
- Like posts and comments.
- Add comments, replies, and image attachments in comments.
- Delete only your own comments.
- Owner-only post editing and deletion.
- Owner-only status updates and issue resolution.
- Add text proof and photo proof while marking a post as resolved.
- Search by issue text, user, status, zone, category, urgency, and hashtags.
- Zone map with active and total issue counts.
- CivicMate AI assistant for report writing guidance.
- Profile screen with user statistics, tips, project information, NorthCap branding, and supervisor signature.
- Share post details in a link-style text format.
- Location permission support for dashboard temperature display.

## Tech Stack

- Flutter and Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase AI / Gemini
- Cloudinary image upload API
- flutter_map with OpenStreetMap tiles
- image_picker
- geolocator
- url_launcher
- provider
- lottie

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  screens/
    create_post_screen.dart
    forgot_password.dart
    home_screen.dart
    login_screen.dart
    profile_screen.dart
    signup_screen.dart
    splash_screen.dart
  services/
    auth_service.dart
    cloudinary_service.dart
    firestore_services.dart
    gemini_service.dart
  utils/
    theme_controller.dart
    top_snackbar.dart
  widgets/
    glowing_background_logo.dart
    pressable_scale.dart
    pulse_loader.dart
    revolving_center_glow.dart
    scroll_to_top_button.dart
```

## Setup

Install dependencies:

```powershell
flutter pub get
```

Run on Chrome/Edge:

```powershell
flutter run -d edge
```

Run on Android:

```powershell
flutter run
```

Analyze:

```powershell
flutter analyze
```

## Build APK

Generate launcher icons after changing `assets/icon.png`:

```powershell
dart run flutter_launcher_icons
```

Build release APK:

```powershell
flutter build apk --release
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For GitHub submission, a copy is included at:

```text
app-release.apk
```

## Notes

- Firebase must be configured for the project through `firebase_options.dart`.
- Cloudinary settings are in `lib/services/cloudinary_service.dart`.
- CivicMate requires Firebase AI Logic to be enabled for the Firebase project.
- For production use, configure stricter Firebase security rules, a proper map tile provider, moderation workflows, and an authority dashboard.

## Team

- Anthati Greeshma - 22CSU413
- Sarthak Arya - 22CSU414
- Tanmay Kumar Das - 22CSU416
- Bhavay Mehta - 22CSU434

Supervisor: Dr. Nishu

Institution: The NorthCap University, Gurugram
