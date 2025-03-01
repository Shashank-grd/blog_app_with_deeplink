# Blog App with Firebase and Deep Linking

A Flutter application that displays blog posts from Firebase Cloud Firestore with deep linking functionality.

## Features

- **Firebase Integration**: Fetches blog posts from Cloud Firestore
- **Responsive UI**: Beautiful and responsive UI for displaying blog posts
- **Deep Linking**: Navigate directly to specific blog posts via deep links
- **State Management**: Uses Riverpod for efficient state management

## Getting Started

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` and `GoogleService-Info.plist` files
   - Enable Cloud Firestore in your Firebase project

### Firestore Structure

Create a collection named `blogPosts` with documents containing the following fields:
- `imageURL`: URL of the blog post's thumbnail or featured image
- `title`: Title of the blog post
- `summary`: Short summary or description of the blog post
- `content`: Full content of the blog post
- `deeplink`: Deep link for navigating directly to the blog post (format: `/blog/post-slug`)


### Deep Linking Setup

#### Android

Add the following to your `android/app/src/main/AndroidManifest.xml` file:

```xml
<intent-filter android:autoVerify="true">
   <action android:name="android.intent.action.VIEW" />
   <category android:name="android.intent.category.DEFAULT" />
   <category android:name="android.intent.category.BROWSABLE" />
   <data android:scheme="http" android:host="example.com" />
   <data android:scheme="https" />
</intent-filter>
```

## Usage

### Running the App

```
flutter run
```

### Testing Deep Links

You can test deep links using the following commands:

#### Android

```
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/blog/post-slug"
```

## Architecture

The app follows a clean architecture pattern:

- **Model**: Data models for blog posts
- **Repository**: Handles data fetching from Firestore
- **Provider**: State management using Riverpod
- **UI**: Screens and widgets for displaying blog posts

## License

This project is licensed under the MIT License - see the LICENSE file for details.
