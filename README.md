# store_navigator

**Store Navigator mobile application - Store Navigation and Product Localization for Enhanced Grocery Shopping Experiences**

This repository contains the source code for the Store Navigator mobile application, written in Flutter. The application is for download on Android via Google Playstore (\url{https://play.google.com/store/apps/details?id=uk.storenav.app}) and on iOS via TestFlight (\url{https://testflight.apple.com/join/b4jRHKpd}).


## How to Run Locally

### Prerequisites

Before you begin, ensure you have Flutter installed and set up on your system. If you are new to Flutter, follow the [Flutter Get Started guide](https://docs.flutter.dev/get-started) to install Flutter and set up your environment for development.

### Steps to Run the App

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Itope84/store_navigator.git
   cd store_navigator
   ```

2. **Set Up Flutter**
- Ensure you have Flutter installed and added to your system's PATH.
- Run the following command to check your Flutter installation:
  ```
  flutter doctor
  ```
  This will verify that your environment is correctly configured for Flutter development.

3. **Configure Android Build Settings**
- Navigate to the `android/` directory in your project folder.
- Create or edit the `local.properties` file and add the following lines:
  ```
  flutter.minSdkVersion=21
  flutter.targetSdkVersion=33
  flutter.compileSdkVersion=34
  ```

4. **Install Dependencies**
- Run the following command to fetch and install all dependencies:
  ```
  flutter pub get
  ```

5. **Run the App**
- Connect a physical device or start an emulator.
- Use the following command to run the app:
  ```
  flutter run
  ```

## Additional Resources

If this is your first Flutter project or you need further guidance, refer to the following resources:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/): Comprehensive tutorials, samples, and API references.


