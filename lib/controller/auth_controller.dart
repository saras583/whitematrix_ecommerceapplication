import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller responsible for managing user authentication state.
/// Persists login session using SharedPreferences so the user stays logged in across restarts.
class AuthController extends ChangeNotifier {
  static const _prefKey = 'is_logged_in';

  // Demo credentials for testing (no backend needed as per task requirements)
  static const demoEmail = 'demo@shop.com';
  static const demoPhone = '9876543210';
  static const demoPassword = '123456';

  // Alternate demo credentials
  static const altEmail = 'saras@gmail.com';
  static const altPassword = 'saras@123';

  bool isInitialised = false;
  bool isLoggedIn = false;
  bool isLoading = false;
  String? errorMessage;

  /// Called on app startup to check if a saved login session exists
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(_prefKey) ?? false;
    isInitialised = true;
    notifyListeners();
  }

  /// Validates that the input is either a valid email or a 10-digit mobile number
  static String? validateIdentifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Please enter your email or phone number';
    }
    final isEmail = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v);
    final isPhone = RegExp(r'^[6-9]\d{9}$').hasMatch(v);
    if (!isEmail && !isPhone) {
      return 'Please enter a valid email or 10-digit phone number';
    }
    return null;
  }

  /// Validates that the password is at least 6 characters long
  static String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Please enter your password';
    }
    if (v.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Attempts login with the provided credentials
  Future<bool> login(String identifier, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Simulate short network delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 600));

    final id = identifier.trim().toLowerCase();
    final pw = password;

    // Check against accepted demo credentials
    final isDemoMatch = (id == demoEmail.toLowerCase() || id == demoPhone) && pw == demoPassword;
    final isAltMatch = id == altEmail.toLowerCase() && pw == altPassword;

    if (isDemoMatch || isAltMatch) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
      isLoggedIn = true;
      errorMessage = null;
    } else {
      errorMessage = 'Invalid email/phone or password. Please check demo credentials.';
    }

    isLoading = false;
    notifyListeners();
    return isLoggedIn;
  }

  /// Logs the user out and clears the saved session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    isLoggedIn = false;
    errorMessage = null;
    notifyListeners();
  }
}
