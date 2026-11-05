import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException, HttpException;
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_token_storage.dart';

class GraphQLClient {
  GraphQLClient({
    required this.config,
    required this.tokenStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ApiConfig config;
  final AuthTokenStorage tokenStorage;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
  }) {
    return execute(document: document, variables: variables);
  }

  Future<Map<String, dynamic>> mutate(
    String document, {
    Map<String, dynamic>? variables,
  }) {
    return execute(document: document, variables: variables);
  }

  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    final uri = Uri.parse(config.graphqlUrl);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = tokenStorage.currentToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final payload = jsonEncode({
      'query': document,
      if (variables != null && variables.isNotEmpty) 'variables': variables,
    });

    http.Response response;
    try {
      response = await _httpClient
          .post(uri, headers: headers, body: payload)
          .timeout(config.timeout);
    } on TimeoutException {
      throw const NetworkException('Delai d\'attente depasse');
    } on SocketException catch (e) {
      throw NetworkException('Impossible de joindre le serveur: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('Erreur HTTP: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Erreur de connexion: $e');
    }

    if (response.statusCode == 401) {
      throw const AuthException('Non authentifie ou session expiree');
    }

    if (response.statusCode >= 500) {
      throw ApiException(
        'Erreur serveur (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'Reponse non-JSON recue du serveur',
        statusCode: response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Format de reponse GraphQL invalide');
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final messages = errors
          .map(
            (e) =>
                (e is Map ? e['message']?.toString() : null) ??
                'Erreur inconnue',
          )
          .toList();

      final firstError = errors.first;
      final code = firstError is Map && firstError['extensions'] is Map
          ? firstError['extensions']['code']?.toString()
          : null;

      if (code == 'UNAUTHENTICATED') {
        throw AuthException(messages.first);
      }

      throw GraphQLException(messages.first, errors: messages, code: code);
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Aucune donnee dans la reponse GraphQL');
    }

    return data;
  }

  void close() {
    _httpClient.close();
  }
}
