import 'package:shared_preferences/shared_preferences.dart';

/// Persistent session store.
///
/// Holds the authorization key and user info returned by the BIX login API.
/// The authorization key is persisted locally so it survives app restarts
/// and can be used in subsequent API requests.
class Session {
  static final Session _instance = Session._();
  factory Session() => _instance;
  Session._();

  static const _keyAuth = 'session_authorizationKey';
  static const _keyUserId = 'session_userId';
  static const _keyUserType = 'session_userType';
  static const _keyEmail = 'session_email';

  String? authorizationKey;
  String? userId;
  String? userType; // 'Person' or 'Business'
  String? email;

  bool get isLoggedIn =>
      authorizationKey != null && authorizationKey!.isNotEmpty;

  /// Load saved session from local storage. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    authorizationKey = prefs.getString(_keyAuth);
    userId = prefs.getString(_keyUserId);
    userType = prefs.getString(_keyUserType);
    email = prefs.getString(_keyEmail);
  }

  /// Parse login response and persist all session data locally.
  Future<void> setFromLoginData(List<String> data) async {
    // data[0] = "userId,Person|Business"
    // data[1] = authorization key
    // data[3] = email
    if (data.isNotEmpty && data[0].contains(',')) {
      final parts = data[0].split(',');
      userId = parts.first;
      userType = parts.length > 1 ? parts.last : null;
    } else if (data.isNotEmpty) {
      userId = data[0];
    }
    if (data.length > 1) authorizationKey = data[1];
    if (data.length > 3) email = data[3];

    await _save();
  }

  /// Clear session and remove from local storage (logout).
  Future<void> clear() async {
    authorizationKey = null;
    userId = null;
    userType = null;
    email = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuth);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyEmail);
  }

  /// Persist current session data to local storage.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    if (authorizationKey != null) {
      await prefs.setString(_keyAuth, authorizationKey!);
    }
    if (userId != null) await prefs.setString(_keyUserId, userId!);
    if (userType != null) await prefs.setString(_keyUserType, userType!);
    if (email != null) await prefs.setString(_keyEmail, email!);
  }
}
