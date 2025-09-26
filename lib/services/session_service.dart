import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _adminSessionKey = 'admin_session';
  static const String _userSessionKey = 'user_session';
  static const String _adminIdKey = 'admin_id';
  static const String _userIdKey = 'user_id';
  static const String _adminEmailKey = 'admin_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _adminNameKey = 'admin_name';
  static const String _userNameKey = 'user_name';

  // Admin Session Management
  static Future<void> createAdminSession({
    required String adminId,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminSessionKey, true);
    await prefs.setString(_adminIdKey, adminId);
    await prefs.setString(_adminEmailKey, email);
    await prefs.setString(_adminNameKey, name);
    print('SessionService: Admin session created for $email');
  }

  static Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminSessionKey) ?? false;
  }

  static Future<Map<String, String?>> getAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_adminIdKey),
      'email': prefs.getString(_adminEmailKey),
      'name': prefs.getString(_adminNameKey),
    };
  }

  static Future<void> clearAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminSessionKey);
    await prefs.remove(_adminIdKey);
    await prefs.remove(_adminEmailKey);
    await prefs.remove(_adminNameKey);
    print('SessionService: Admin session cleared');
  }

  // User Session Management
  static Future<void> createUserSession({
    required String userId,
    required String phoneNumber,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userSessionKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userPhoneKey, phoneNumber);
    await prefs.setString(_userNameKey, name);
    print('SessionService: User session created for $phoneNumber');
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userSessionKey) ?? false;
  }

  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_userIdKey),
      'phone': prefs.getString(_userPhoneKey),
      'name': prefs.getString(_userNameKey),
    };
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userNameKey);
    print('SessionService: User session cleared');
  }

  // Clear all sessions (logout from all)
  static Future<void> clearAllSessions() async {
    await clearAdminSession();
    await clearUserSession();
    print('SessionService: All sessions cleared');
  }

  // Check what type of user is logged in
  static Future<String> getLoggedInUserType() async {
    final isAdmin = await isAdminLoggedIn();
    final isUser = await isUserLoggedIn();
    
    if (isAdmin) return 'admin';
    if (isUser) return 'user';
    return 'none';
  }
}
