class AuthTokenStorage {
  AuthTokenStorage({String? initialToken}) : _token = initialToken;

  String? _token;

  String? get currentToken => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<String?> readToken() async {
    return _token;
  }

  Future<void> writeToken(String token) async {
    _token = token;
  }

  Future<void> deleteToken() async {
    _token = null;
  }
}
