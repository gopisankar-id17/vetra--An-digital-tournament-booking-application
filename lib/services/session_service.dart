import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _adminSessionKey = 'admin_session';
  static const String _userSessionKey = 'user_session';
  static const String _organizerSessionKey = 'organizer_session';
  static const String _adminIdKey = 'admin_id';
  static const String _userIdKey = 'user_id';
  static const String _organizerIdKey = 'organizer_id';
  static const String _adminEmailKey = 'admin_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _organizerEmailKey = 'organizer_email';
  static const String _adminNameKey = 'admin_name';
  static const String _userNameKey = 'user_name';
  static const String _organizerNameKey = 'organizer_name';
  static const String _organizerOrganizationKey = 'organizer_organization';

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

  // Organizer Session Management
  static Future<void> createOrganizerSession({
    required String organizerId,
    required String email,
    required String name,
    required String organization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_organizerSessionKey, true);
    await prefs.setString(_organizerIdKey, organizerId);
    await prefs.setString(_organizerEmailKey, email);
    await prefs.setString(_organizerNameKey, name);
    await prefs.setString(_organizerOrganizationKey, organization);
    print('SessionService: Organizer session created for $email');
  }

  static Future<bool> isOrganizerLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_organizerSessionKey) ?? false;
  }

  static Future<Map<String, String?>> getOrganizerSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_organizerIdKey),
      'email': prefs.getString(_organizerEmailKey),
      'name': prefs.getString(_organizerNameKey),
      'organization': prefs.getString(_organizerOrganizationKey),
    };
  }

  static Future<void> clearOrganizerSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_organizerSessionKey);
    await prefs.remove(_organizerIdKey);
    await prefs.remove(_organizerEmailKey);
    await prefs.remove(_organizerNameKey);
    await prefs.remove(_organizerOrganizationKey);
    print('SessionService: Organizer session cleared');
  }

  // Clear all sessions (logout from all)
  static Future<void> clearAllSessions() async {
    await clearAdminSession();
    await clearUserSession();
    await clearOrganizerSession();
    print('SessionService: All sessions cleared');
  }

  // Check what type of user is logged in
  static Future<String> getLoggedInUserType() async {
    final isAdmin = await isAdminLoggedIn();
    final isUser = await isUserLoggedIn();
    final isOrganizer = await isOrganizerLoggedIn();

    if (isAdmin) return 'admin';
    if (isOrganizer) return 'organizer';
    if (isUser) return 'user';
    return 'none';
  }
}
