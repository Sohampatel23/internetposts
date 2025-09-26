Flutter Offline Posts App

A Flutter application that fetches posts from JSONPlaceholder
, supports offline mode, allows creating posts while offline, and syncs automatically when the device comes back online.

⚙️ Prerequisites

Flutter SDK >= 3.7
Dart >= 3.1
Device or emulator
Internet connection (for initial fetch)

📦 Dependencies

provider → State management
hive → Offline storage
hive_flutter → Flutter integration for Hive
connectivity_plus → Network detection
uuid → Generate unique IDs
dio → HTTP client

📝 Steps to Run

Clone the repository

git clone <your-github-repo-link>
cd offline_posts_app


Install dependencies

flutter pub get


Generate Hive TypeAdapter (Important!)

Since Post is a custom object, Hive needs a TypeAdapter to store it locally. Run:

flutter packages pub run build_runner build --delete-conflicting-outputs


⚠️ This step must be done before running the app.
Users installing the APK do not need this step — it’s only for development.

Run the app

flutter run

📌 Notes

Unsynced posts persist in Hive until successfully uploaded.
JSONPlaceholder API fakes POST requests; new posts return an ID (101+) but are not permanently stored on the server.
The app will work offline using cached posts.
