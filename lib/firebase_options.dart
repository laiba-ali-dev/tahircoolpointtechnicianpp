// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA63Koxo3Ll5q-Z7ONtVOurwPO_L7H6hHk',
    appId: '1:650722845488:web:1cc05b3865509bd626def5',
    messagingSenderId: '650722845488',
    projectId: 'tahircoolpoint-dc3c6',
    authDomain: 'tahircoolpoint-dc3c6.firebaseapp.com',
    storageBucket: 'tahircoolpoint-dc3c6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAO9fZi2BUEkRcNS12SoheOSL-ALW8K69U',
    appId: '1:650722845488:android:1b92309a81ff6f8526def5',
    messagingSenderId: '650722845488',
    projectId: 'tahircoolpoint-dc3c6',
    storageBucket: 'tahircoolpoint-dc3c6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBanlvqhfNmso4OmjjCTGlggeXVyD6FfdU',
    appId: '1:650722845488:ios:ce5b0a72e85cb9f526def5',
    messagingSenderId: '650722845488',
    projectId: 'tahircoolpoint-dc3c6',
    storageBucket: 'tahircoolpoint-dc3c6.firebasestorage.app',
    iosClientId: '650722845488-0iamjlom73ubrh5h90j6gndlnddkh5ff.apps.googleusercontent.com',
    iosBundleId: 'com.example.tahircoolpointtechnician',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBanlvqhfNmso4OmjjCTGlggeXVyD6FfdU',
    appId: '1:650722845488:ios:ce5b0a72e85cb9f526def5',
    messagingSenderId: '650722845488',
    projectId: 'tahircoolpoint-dc3c6',
    storageBucket: 'tahircoolpoint-dc3c6.firebasestorage.app',
    iosClientId: '650722845488-0iamjlom73ubrh5h90j6gndlnddkh5ff.apps.googleusercontent.com',
    iosBundleId: 'com.example.tahircoolpointtechnician',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA63Koxo3Ll5q-Z7ONtVOurwPO_L7H6hHk',
    appId: '1:650722845488:web:bbc060eb2ff5261d26def5',
    messagingSenderId: '650722845488',
    projectId: 'tahircoolpoint-dc3c6',
    authDomain: 'tahircoolpoint-dc3c6.firebaseapp.com',
    storageBucket: 'tahircoolpoint-dc3c6.firebasestorage.app',
  );
}
