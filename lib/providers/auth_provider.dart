import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _error;

  // Let Android resolve the client ID from strings.xml
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

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

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _user = {
          'id': googleUser.id,
          'name': googleUser.displayName ?? googleUser.email.split('@')[0],
          'email': googleUser.email,
          'avatarUrl': googleUser.photoUrl,
        };
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

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
      } catch (_) {}

      _user = {
        'id': googleUser.id,
        'name': googleUser.displayName ?? googleUser.email.split('@')[0],
        'email': googleUser.email,
        'avatarUrl': googleUser.photoUrl,
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

  Future<void> loadProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true) {
        _user = response['user'];
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
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