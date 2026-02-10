import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  // ============ EMAIL/PASSWORD LOGIN ============
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email: email, password: password);
      if (response['success'] == true) {
        await ApiService.setToken(response['token']);
        _user = response['user'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ EMAIL/PASSWORD REGISTER ============
  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (response['success'] == true) {
        await ApiService.setToken(response['token']);
        _user = response['user'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ GOOGLE SIGN-IN (FIREBASE) ============
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sign out first to force account picker every time
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 2: Get Google auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Step 3: Create Firebase credential
      final firebase_auth.OAuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _error = 'Firebase authentication failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 5: Get Firebase ID token
      final String? idToken = await firebaseUser.getIdToken();

      // Step 6: Try sending to backend
      if (idToken != null) {
        try {
          final response = await ApiService.googleSignIn(idToken: idToken);
          if (response['success'] == true) {
            await ApiService.setToken(response['token']);
            _user = response['user'];
            _isAuthenticated = true;
            _isLoading = false;
            notifyListeners();
            return true;
          }
        } catch (_) {
          // Backend might not be reachable, fall through to local auth
        }
      }

      // Step 7: Fallback - use Firebase user info directly
      _user = {
        'id': firebaseUser.uid,
        'name': firebaseUser.displayName ?? googleUser.displayName ?? googleUser.email.split('@')[0],
        'email': firebaseUser.email ?? googleUser.email,
        'phone': firebaseUser.phoneNumber,
        'avatarUrl': firebaseUser.photoURL ?? googleUser.photoUrl,
      };
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google sign-in error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ PROFILE ============
  Future<void> loadProfile() async {
    // Check Firebase auth first
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      _user = {
        'id': firebaseUser.uid,
        'name': firebaseUser.displayName ?? 'User',
        'email': firebaseUser.email ?? '',
        'phone': firebaseUser.phoneNumber,
        'avatarUrl': firebaseUser.photoURL,
      };
      _isAuthenticated = true;
      notifyListeners();
      return;
    }

    // Then check backend
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true) {
        _user = response['user'];
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      // Token may be invalid
    }
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (_) {}
    await ApiService.removeToken();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}