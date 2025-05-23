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
    apiKey: 'AIzaSyAwTbcnVDyC6gRfeSf6aQMwLGuR7vEhk08',
    appId: '1:777080867979:web:352fe4940c00998c42588e',
    messagingSenderId: '777080867979',
    projectId: 'agenda-web-9ef97',
    authDomain: 'agenda-web-9ef97.firebaseapp.com',
    storageBucket: 'agenda-web-9ef97.firebasestorage.app',
    measurementId: 'G-YJ3SCPBEQQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApPLXNzWo379-qkm2i-2QQJk8DLwPJutI',
    appId: '1:777080867979:android:6131719ca07362ba42588e',
    messagingSenderId: '777080867979',
    projectId: 'agenda-web-9ef97',
    storageBucket: 'agenda-web-9ef97.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoIQT5uvaAfLJYRpqg4E3PVKwgF02xOf8',
    appId: '1:777080867979:ios:5ef59149d3dab2f442588e',
    messagingSenderId: '777080867979',
    projectId: 'agenda-web-9ef97',
    storageBucket: 'agenda-web-9ef97.firebasestorage.app',
    iosBundleId: 'com.example.agendaWeb',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBoIQT5uvaAfLJYRpqg4E3PVKwgF02xOf8',
    appId: '1:777080867979:ios:5ef59149d3dab2f442588e',
    messagingSenderId: '777080867979',
    projectId: 'agenda-web-9ef97',
    storageBucket: 'agenda-web-9ef97.firebasestorage.app',
    iosBundleId: 'com.example.agendaWeb',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAwTbcnVDyC6gRfeSf6aQMwLGuR7vEhk08',
    appId: '1:777080867979:web:408f1d8af78db59442588e',
    messagingSenderId: '777080867979',
    projectId: 'agenda-web-9ef97',
    authDomain: 'agenda-web-9ef97.firebaseapp.com',
    storageBucket: 'agenda-web-9ef97.firebasestorage.app',
    measurementId: 'G-1NTJ9E94KP',
  );
}
