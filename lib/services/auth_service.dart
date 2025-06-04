import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  static User? get currentUser => _auth.currentUser;
  
  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await _createUserDocument(credential.user!);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Sync user data from Firestore
      await _syncUserData(credential.user!);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create/update user document
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }
  
  // Sign in with Apple
  static Future<UserCredential?> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create an OAuth credential from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      // Sign in the user with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      
      // Update display name if available
      if (appleCredential.givenName != null && appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
        await userCredential.user?.updateDisplayName(displayName);
      }
      
      // Create/update user document
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    
    // Clear local storage
    await StorageService.clearUserData();
  }
  
  // Delete account
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user collections
      await _deleteUserCollections(user.uid);
      
      // Delete the user account
      await user.delete();
      
      // Clear local storage
      await StorageService.clearUserData();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Check if email is verified
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  
  // Send email verification
  static Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }
  
  // Get ID token for backend authentication
  static Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
  
  // Private helper methods
  static Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Crystal Seeker',
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'subscriptionTier': 'free',
      'subscriptionStatus': 'active',
      'monthlyIdentifications': 0,
      'totalIdentifications': 0,
      'metaphysicalQueries': 0,
      'settings': {
        'notifications': true,
        'newsletter': true,
        'darkMode': true,
      },
    };
    
    await userDoc.set(userData, SetOptions(merge: true));
  }
  
  static Future<void> _syncUserData(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    
    if (userDoc.exists) {
      final data = userDoc.data()!;
      
      // Update last login
      await userDoc.reference.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      
      // Sync subscription tier to local storage
      if (data['subscriptionTier'] != null) {
        await StorageService.saveSubscriptionTier(data['subscriptionTier']);
      }
      
      // Sync other settings
      // TODO: Implement more data syncing as needed
    } else {
      // Create user document if it doesn't exist
      await _createUserDocument(user);
    }
  }
  
  static Future<void> _deleteUserCollections(String uid) async {
    // Delete user's crystal collection
    final collectionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('crystals');
    
    final crystals = await collectionRef.get();
    for (final doc in crystals.docs) {
      await doc.reference.delete();
    }
    
    // Delete user's journal entries
    final journalRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('journal');
    
    final entries = await journalRef.get();
    for (final doc in entries.docs) {
      await doc.reference.delete();
    }
  }
  
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign in method is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}