/// Simple in-memory session store.
///
/// Holds the authorization key and user info returned by the BIX login API.
/// The authorization key must be included in all subsequent API requests.
class Session {
  static final Session _instance = Session._();
  factory Session() => _instance;
  Session._();

  String? authorizationKey;
  String? userId;
  String? userType; // 'Person' or 'Business'
  String? email;

  bool get isLoggedIn => authorizationKey != null && authorizationKey!.isNotEmpty;

  void setFromLoginData(List<String> data) {
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
  }

  void clear() {
    authorizationKey = null;
    userId = null;
    userType = null;
    email = null;
  }
}
