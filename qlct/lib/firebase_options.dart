import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCh27sRKiOikMbgwsUdVl1guq2Ni-9F8N0',
    appId: '1:1086022198570:web:YOUR_WEB_APP_ID',
    messagingSenderId: '1086022198570',
    projectId: 'qlct-95f82',
    authDomain: 'qlct-95f82.firebaseapp.com',
    storageBucket: 'qlct-95f82.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh27sRKiOikMbgwsUdVl1guq2Ni-9F8N0',
    appId: '1:1086022198570:android:3a666d8b1d9c9351182a53',
    messagingSenderId: '1086022198570',
    projectId: 'qlct-95f82',
    storageBucket: 'qlct-95f82.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:1086022198570:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '1086022198570',
    projectId: 'qlct-95f82',
    storageBucket: 'qlct-95f82.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.qlct',
  );
}