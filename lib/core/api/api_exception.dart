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
  const NetworkException([super.message = 'Impossible de contacter le serveur'])
    : super(code: 'NETWORK_ERROR');
}

class AuthException extends ApiException {
  const AuthException([super.message = 'Session expiree ou acces refuse'])
    : super(code: 'UNAUTHORIZED', statusCode: 401);
}

class GraphQLException extends ApiException {
  const GraphQLException(
    super.message, {
    this.errors = const [],
    super.code = 'GRAPHQL_ERROR',
  });

  final List<String> errors;

  @override
  String toString() {
    if (errors.isEmpty) return 'GraphQLException: $message';
    return 'GraphQLException: $message, details: ${errors.join(', ')}';
  }
}
