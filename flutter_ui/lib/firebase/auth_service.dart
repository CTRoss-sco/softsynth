import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //getter for current user
  static User? get currentUser => _auth.currentUser;

  //check to see if user is signed in
  static bool get isSignedIn => currentUser != null;

  //authentication state change stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  //Sign-ups done through email and password combination
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
}) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
      );

      //if a display name is provided, update the user's profile
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }

      print('User signed up successfully: ${credential.user?.email}');
      return credential;

  } on FirebaseAuthException catch (e) {
    print('Sign up failed: ${e.message}');
    throw _handleAuthException(e);
  } catch (e) {
    print('Unexpected error during sign up: $e');
    rethrow;
  }
}

//method to sign in with email and password
static Future<UserCredential?> signInWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('User signed in successfully: ${credential.user?.email}');
    return credential;

  } on FirebaseAuthException catch (e) {
    print('Sign in failed: ${e.message}');
    throw _handleAuthException(e);
  } catch (e) {
    print('Unexpected error during sign in: $e');
    rethrow;
  }
}

//method to allow user to sign out
static Future<void> signOut() async {
  try {
    await _auth.signOut();
    print('User signed out successfully');
  } catch (e) {
    print('Sign out failed: $e');
    rethrow;
  }
}

// method to handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

}