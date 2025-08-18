import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/*
Class to manage Firebase initialisation using the environment variables.
*/

class FirebaseService {
  static bool _initialized = false;
  
  // method to initialise Firebase with environment variables
  static Future<void> initialize() async {
    if (_initialized) {
      print('Firebase already initialized');
      return;
    }
    
    try {
      // Load environment variables from assets
      await dotenv.load(fileName: ".env");
      print('Environment variables loaded from assets');
      
      // Create Firebase options from environment variables
      final options = FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      );
      
      await Firebase.initializeApp(options: options);
      
      _initialized = true;
      print('Firebase initialized successfully with environment variables');
      
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow;
    }
  }
  
  //check to see if Firebase has been initialised
  static bool get isInitialized => _initialized;

  //gets current Firebase app instance
  static FirebaseApp get app {
    if (!_initialized) {
      throw Exception('Firebase not initialised. Call FirebaseService.initialise() first.');
    }
    return Firebase.app();
  }
}