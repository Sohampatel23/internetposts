Ensure Flutter is installed (stable channel) and flutter doctor is clean.
Create the project folder and add files from above.
Add packages: flutter pub get .
Generate Hive adapter for Post :
flutter packages pub run build_runner build --delete-conflicting-outputs
Run the app:
flutter run