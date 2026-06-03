import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static const _keyAccessToken   = 'google_access_token';
  static const _keyRefreshToken  = 'google_refresh_token';
  static const _keyTokenExpiry   = 'google_token_expiry';
  static const _keyUserName      = 'user_name';
  static const _keyUserEmail     = 'user_email';
  static const _keyUserPhoto     = 'user_photo_url';
  static const _keyGoogleId      = 'google_id';
  static const _keyIsConnected   = 'is_google_connected';

  static SharedPreferences? _prefs;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) throw StateError('LocalStorageService not initialized');
    return _prefs!;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _p.setString(_keyAccessToken,  accessToken);
    await _p.setString(_keyRefreshToken, refreshToken);
    await _p.setInt(_keyTokenExpiry, expiry.millisecondsSinceEpoch);
  }

  static String? getAccessToken()  => _p.getString(_keyAccessToken);
  static String? getRefreshToken() => _p.getString(_keyRefreshToken);

  static bool isTokenExpired() {
    final expiry = _p.getInt(_keyTokenExpiry);
    if (expiry == null) return true;
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiry);
    return DateTime.now().isAfter(expiryTime.subtract(const Duration(minutes: 5)));
  }

  static bool get hasValidToken {
    final token = getAccessToken();
    return token != null && token.isNotEmpty && !isTokenExpired();
  }

  static Future<void> saveGoogleProfile({
    required String googleId,
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    await _p.setString(_keyGoogleId,   googleId);
    await _p.setString(_keyUserName,   name);
    await _p.setString(_keyUserEmail,  email);
    await _p.setString(_keyUserPhoto,  photoUrl);
    await _p.setBool(_keyIsConnected,  true);
  }

  static String? getUserName()    => _p.getString(_keyUserName);
  static String? getUserEmail()   => _p.getString(_keyUserEmail);
  static String? getUserPhoto()   => _p.getString(_keyUserPhoto);
  static String? getGoogleId()    => _p.getString(_keyGoogleId);
  static bool isGoogleConnected() => _p.getBool(_keyIsConnected) ?? false;

  static Future<void> clearAll() async {
    await _p.remove(_keyAccessToken);
    await _p.remove(_keyRefreshToken);
    await _p.remove(_keyTokenExpiry);
    await _p.remove(_keyGoogleId);
    await _p.remove(_keyUserName);
    await _p.remove(_keyUserEmail);
    await _p.remove(_keyUserPhoto);
    await _p.setBool(_keyIsConnected, false);
  }
}