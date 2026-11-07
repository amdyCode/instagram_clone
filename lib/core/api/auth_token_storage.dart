import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  AuthTokenStorage({SharedPreferences? prefs})
    : _prefs = prefs,
      _token = prefs?.getString(_key);

  static const String _key = 'auth_jwt_token';
  final SharedPreferences? _prefs;
  String? _token;

  String? get currentToken => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<String?> readToken() async {
    _token ??= _prefs?.getString(_key);
    return _token;
  }

  Future<void> writeToken(String token) async {
    _token = token;
    await _prefs?.setString(_key, token);
  }

  Future<void> deleteToken() async {
    _token = null;
    await _prefs?.remove(_key);
  }
}
