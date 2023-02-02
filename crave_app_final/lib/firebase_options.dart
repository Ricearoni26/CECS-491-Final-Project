// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/widgets.dart';

// ...

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA3dGIdz0T1w7hDxIdM0Wfd2b9XGFc3QEU',
    appId: '1:355496256832:web:6f466baa4b849a56d8c6a5',
    messagingSenderId: '355496256832',
    projectId: 'craveappfinal',
    authDomain: 'craveappfinal.firebaseapp.com',
    storageBucket: 'craveappfinal.appspot.com',
    measurementId: 'G-44N0J67N49',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrsJmSodUhCApniZvj6O90nfQTXAWovwk',
    appId: '1:355496256832:android:5ea3f78811343294d8c6a5',
    messagingSenderId: '355496256832',
    projectId: 'craveappfinal',
    storageBucket: 'craveappfinal.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkteLP-3JDUwil9CE4ravtHqdx9cSMNwI',
    // appId: '1:355496256832:ios:2d5c412a1b1b3275d8c6a5',
    appId: '1:355496256832:ios:40096515c2ed6ed4d8c6a5',
    messagingSenderId: '355496256832',
    projectId: 'craveappfinal',
    storageBucket: 'craveappfinal.appspot.com',
    iosClientId: '355496256832-cgbgeepl4ua14bq2ihqefh2ihcbts0i1.apps.googleusercontent.com',
    iosBundleId: 'com.cecs491app.craveAppFinal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkteLP-3JDUwil9CE4ravtHqdx9cSMNwI',
    appId: '1:355496256832:ios:80b5af10ef94ad07d8c6a5',
    messagingSenderId: '355496256832',
    projectId: 'craveappfinal',
    storageBucket: 'craveappfinal.appspot.com',
    iosClientId: '355496256832-rbon105800a0dko9lq3drro2jobgcnis.apps.googleusercontent.com',
    iosBundleId: 'com.example.craveAppFinal',
  );
}
