
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDz8D3BEuraVbTokNHDsbHATjPX4CWQgAY',
    appId: '1:1059148649690:android:436d0ea729521bfeab01e3',
    messagingSenderId: '1059148649690',
    projectId: 'chat-app2-5f498',
    storageBucket: 'chat-app2-5f498.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1BFDiwUAixwgR3Pq2m5Q887It9jBfC8Y',
    appId: '1:1059148649690:ios:0e5d82828517f8bfab01e3',
    messagingSenderId: '1059148649690',
    projectId: 'chat-app2-5f498',
    storageBucket: 'chat-app2-5f498.appspot.com',
    iosBundleId: 'com.example.youtubeChatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB8IOqLs7dKMMvgGF5xW923eI0G_oMK9cU',
    appId: '1:1059148649690:web:7a96a43a32b246fbab01e3',
    messagingSenderId: '1059148649690',
    projectId: 'chat-app2-5f498',
    authDomain: 'chat-app2-5f498.firebaseapp.com',
    storageBucket: 'chat-app2-5f498.appspot.com',
    measurementId: 'G-C92G9QVM5X',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8IOqLs7dKMMvgGF5xW923eI0G_oMK9cU',
    appId: '1:1059148649690:web:7a96a43a32b246fbab01e3',
    messagingSenderId: '1059148649690',
    projectId: 'chat-app2-5f498',
    authDomain: 'chat-app2-5f498.firebaseapp.com',
    storageBucket: 'chat-app2-5f498.appspot.com',
    measurementId: 'G-C92G9QVM5X',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1BFDiwUAixwgR3Pq2m5Q887It9jBfC8Y',
    appId: '1:1059148649690:ios:0e5d82828517f8bfab01e3',
    messagingSenderId: '1059148649690',
    projectId: 'chat-app2-5f498',
    storageBucket: 'chat-app2-5f498.appspot.com',
    iosBundleId: 'com.example.youtubeChatApp',
  );

}