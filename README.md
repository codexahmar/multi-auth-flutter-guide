# 🔐 Authentication Providers Setup Guide

[![Flutter](https://img.shields.io/badge/Flutter-Compatible-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

This repository provides a comprehensive guide for integrating multiple social authentication providers (Google, Facebook, and Apple) along with traditional email/password authentication in both Android and iOS applications. The complete implementation code is available in the `AuthService` file.

## 📋 Table of Contents
- [🚀 Getting Started](#-getting-started)
- [📧 Email/Password Authentication](#-emailpassword-authentication)
- [🔍 Google Sign-In](#-google-sign-in)
  - [Android Setup](#google-android-setup)
  - [iOS Setup](#google-ios-setup)
- [📘 Facebook Sign-In](#-facebook-sign-in)
  - [Android Setup](#facebook-android-setup)
  - [iOS Setup](#facebook-ios-setup)
- [🍎 Apple Sign-In](#-apple-sign-in)
- [💻 Implementation](#-implementation)
- [🛠️ Dependencies](#️-dependencies)
- [🔧 Troubleshooting](#-troubleshooting)

## 🚀 Getting Started

### Prerequisites

Before setting up authentication providers, you need to:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or select an existing one
   - Enable Authentication in the Firebase console
   - Navigate to Authentication → Sign-in method and enable the providers you want to use

2. **Add Firebase Configuration Files**
   - **For Android**: Download `google-services.json` and place it in `android/app/`
   - **For iOS**: Download `GoogleService-Info.plist` and add it to your iOS project in Xcode

> **Note**: These configuration files are essential for Firebase to work properly in your application.

## 📧 Email/Password Authentication

Email/password authentication works out of the box once Firebase is configured:

1. **Enable Email/Password Provider**
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable "Email/Password" provider

2. **Implementation**
   - The `AuthService` class provides `signInWithEmailPassword()` and `signUpWithEmailPassword()` methods
   - Password reset functionality is available through `sendPasswordResetEmail()`

## 🔍 Google Sign-In

### Google Android Setup

1. **Firebase Console Configuration**
   - Add Google provider in Firebase Authentication
   - Enter your email and project name when prompted
   - Navigate to Project Settings → Your Apps → Android
   - Click "Add fingerprint"

2. **Generate SHA Keys**

   **Method 1: Using JDK (keytool)**
   ```bash
   # For debug keystore (password: android)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release keystore
   keytool -list -v -keystore /path/to/your/keystore -alias your-key-alias -storepass your-store-password
   ```
   
   **Method 2: Using Flutter (direct method)**
   ```bash
   # Get SHA-1 and SHA-256 directly from Flutter
   cd android
   ./gradlew signingReport
   ```

3. **Add SHA Keys to Firebase**
   - Copy both SHA-1 and SHA-256 fingerprints
   - Paste them in the fingerprints field in Firebase Console
   - **Important**: The debug keystore password is `android`

### Google iOS Setup

1. **Download Configuration File**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to your iOS project in Xcode

2. **Update Info.plist**
   ```xml
   <!-- Google Client ID -->
   <key>GIDClientID</key>
   <string>YOUR_GOOGLE_CLIENT_ID</string>
   
   <!-- URL Schemes for Google Sign-in -->
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_REVERSED_GOOGLE_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

3. **Get Credentials**
   - Open `GoogleService-Info.plist` file
   - Copy `CLIENT_ID` and `REVERSED_CLIENT_ID` values
   - Replace placeholders in Info.plist with these values

## 📘 Facebook Sign-In

### Facebook Android Setup

1. **Create Facebook App**
   - Go to [developers.facebook.com](https://developers.facebook.com)
   - Create a new app
   - Select "Consumer" app type
   - Note down the App ID, Client Token, and Display Name

2. **Add Platform Configuration**
   - In Facebook Developer Console, add Android platform
   - Enter your package name and class name
   - Add your key hash (can be generated using the same SHA-1 key)

3. **Configure strings.xml**
   - Navigate to `android/app/src/main/res/values/`
   - Create `strings.xml` if it doesn't exist
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
     <string name="app_name">YourAppName</string>
     <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
     <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
     <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
   </resources>
   ```

4. **Update AndroidManifest.xml**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Add the following before the closing `</application>` tag:
   ```xml
   <meta-data 
     android:name="com.facebook.sdk.ApplicationId" 
     android:value="@string/facebook_app_id"/>
   
   <meta-data 
     android:name="com.facebook.sdk.ClientToken" 
     android:value="@string/facebook_client_token"/>
   
   <activity 
     android:name="com.facebook.FacebookActivity"
     android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
     android:label="@string/app_name" />
   
   <activity 
     android:name="com.facebook.CustomTabActivity"
     android:exported="true">
     <intent-filter>
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="@string/fb_login_protocol_scheme" />
     </intent-filter>
   </activity>
   ```

5. **Add Facebook SDK Dependency**
   - Open app-level `build.gradle`
   - Add to dependencies block:
   ```gradle
   dependencies {
     implementation 'com.facebook.android:facebook-android-sdk:latest.release'
   }
   ```

### Facebook iOS Setup

1. **Configure Facebook App for iOS**
   - In Facebook Developer Console, add iOS platform
   - Enter your Bundle ID

2. **Update Info.plist**
   ```xml
   <!-- URL Schemes for Facebook Sign-in -->
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>fbYOUR_FACEBOOK_APP_ID</string>
       </array>
     </dict>
   </array>
   
   <!-- Facebook Configuration -->
   <key>FacebookAppID</key>
   <string>YOUR_FACEBOOK_APP_ID</string>
   
   <key>FacebookClientToken</key>
   <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
   
   <key>FacebookDisplayName</key>
   <string>YOUR_FACEBOOK_DISPLAY_NAME</string>
   
   <!-- Add this for iOS 9+ -->
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>fbapi</string>
     <string>fb-messenger-share-api</string>
   </array>
   ```

3. **Get Credentials**
   - Use the same App ID, Client Token, and Display Name from the Facebook app you created

## 🍎 Apple Sign-In

Apple Sign-In is automatically available on iOS devices running iOS 13+ and requires minimal setup:

1. **Enable Apple Sign-In Capability**
   - In Xcode, go to your project settings
   - Select your target → Signing & Capabilities
   - Click the "+" button and add "Sign in with Apple" capability

2. **Configure App ID**
   - In Apple Developer Console, go to your App ID
   - Enable "Sign in with Apple" for your App ID
   - Configure your service IDs if needed for web authentication

3. **Privacy Requirements**
   - Apple Sign-In must be prominently displayed if other social sign-in methods are available
   - Consider adding privacy policy links as required by App Store guidelines

## 💻 Implementation

The authentication logic is implemented in the `AuthService` class. This service handles:

- ✅ Email/Password authentication
- ✅ Google Sign-In flow for both platforms
- ✅ Facebook Sign-In integration
- ✅ Apple Sign-In (iOS native)
- ✅ Password reset functionality
- ✅ Comprehensive error handling
- ✅ Multi-provider sign-out

### Usage Example

```dart
final authService = AuthService();

// Email/Password Authentication
await authService.signInWithEmailPassword(email, password);
await authService.signUpWithEmailPassword(email, password);
await authService.sendPasswordResetEmail(email);

// Social Authentication
await authService.signInWithGoogle();
await authService.signInWithFacebook();
await authService.signInWithApple(); // iOS only

// Sign out from all providers
await authService.signOut();

// Get current user
User? currentUser = authService.getCurrentUser();

// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  if (user == null) {
    // User is signed out
  } else {
    // User is signed in
  }
});
```

## 🛠️ Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  
  # Google Sign-In
  google_sign_in: ^6.1.6
  
  # Facebook Login
  flutter_facebook_auth: ^6.0.4
  
  # Apple Sign-In
  sign_in_with_apple: ^5.0.0
```

Run `flutter pub get` after adding dependencies.

## 🔧 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **SHA fingerprint mismatch** | Ensure you're using the correct keystore for generating fingerprints. Debug keystore password is `android` |
| **Facebook login fails** | Verify package name matches Facebook Developer Console configuration |
| **Google sign-in not working** | Check that configuration files are properly added and SHA keys are correct |
| **Apple Sign-In unavailable** | Ensure iOS 13+ and proper capability configuration in Xcode |
| **Network errors** | Check internet connection and Firebase project configuration |

### Debug Tips

1. **Enable debug logging** in your app to see detailed error messages
2. **Test on real devices** for social authentication (simulators may have limitations)
3. **Check Firebase Console** for authentication logs and user management
4. **Verify bundle IDs** match across all platforms and services

### Support Resources

For implementation details, refer to the `AuthService` file in this repository. For platform-specific issues, consult the official documentation:

- 📖 [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- 🔍 [Google Sign-In Documentation](https://developers.google.com/identity/sign-in)
- 📘 [Facebook Login Documentation](https://developers.facebook.com/docs/facebook-login)
- 🍎 [Apple Sign-In Documentation](https://developer.apple.com/sign-in-with-apple)

---

**Note**: This guide assumes you're using Flutter with Firebase. Make sure to follow the setup steps in order and test each authentication method thoroughly before deploying to production.
