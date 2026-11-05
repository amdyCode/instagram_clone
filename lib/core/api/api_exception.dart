class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException: $message (code: $code, status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException([
    String message = 'Impossible de contacter le serveur',
  ]) : super(message, code: 'NETWORK_ERROR');
}

class AuthException extends ApiException {
  const AuthException([String message = 'Session expiree ou acces refuse'])
    : super(message, code: 'UNAUTHORIZED', statusCode: 401);
}

class GraphQLException extends ApiException {
  const GraphQLException(
    String message, {
    this.errors = const [],
    super.code = 'GRAPHQL_ERROR',
  }) : super(message);

  final List<String> errors;

  @override
  String toString() {
    if (errors.isEmpty) return 'GraphQLException: $message';
    return 'GraphQLException: $message, details: ${errors.join(', ')}';
  }
}
