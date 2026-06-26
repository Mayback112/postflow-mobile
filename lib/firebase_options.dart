import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace these placeholder values with your real Firebase project config.
  // Run: flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_API_KEY',
    appId: 'REPLACE_WITH_REAL_APP_ID',
    messagingSenderId: 'REPLACE_WITH_REAL_SENDER_ID',
    projectId: 'REPLACE_WITH_REAL_PROJECT_ID',
    authDomain: 'REPLACE_WITH_REAL_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_REAL_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClrDTRqZKKxDl8d-Crg6bc1BUfM3FOXO4',
    appId: '1:50020499211:android:3b27d203dab06f80fa2c0e',
    messagingSenderId: '50020499211',
    projectId: 'e-comm-35d5a',
    storageBucket: 'e-comm-35d5a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMNykBgD2-I9dSTAyT6YDOTSGViwrrRBk',
    appId: '1:50020499211:ios:a296af0290412200fa2c0e',
    messagingSenderId: '50020499211',
    projectId: 'e-comm-35d5a',
    storageBucket: 'e-comm-35d5a.firebasestorage.app',
    iosBundleId: 'com.postflow.app',
  );
}
