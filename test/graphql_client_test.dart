import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:instagram_clone/core/api/api_config.dart';
import 'package:instagram_clone/core/api/api_exception.dart';
import 'package:instagram_clone/core/api/auth_token_storage.dart';
import 'package:instagram_clone/core/api/graphql_client.dart';

void main() {
  group('AuthTokenStorage', () {
    test('stocke et efface le token correctement', () async {
      final storage = AuthTokenStorage();
      expect(storage.currentToken, isNull);
      expect(storage.hasToken, isFalse);

      await storage.writeToken('mon_token_secret');
      expect(storage.currentToken, 'mon_token_secret');
      expect(storage.hasToken, isTrue);

      await storage.deleteToken();
      expect(storage.currentToken, isNull);
      expect(storage.hasToken, isFalse);
    });
  });

  group('GraphQLClient', () {
    late AuthTokenStorage tokenStorage;
    const config = ApiConfig(graphqlUrl: 'http://localhost:4000/graphql');

    setUp(() {
      tokenStorage = AuthTokenStorage();
    });

    test('execute une requete avec succes', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.toString(), 'http://localhost:4000/graphql');
        expect(request.headers['content-type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['query'], contains('health'));

        return http.Response(
          jsonEncode({
            'data': {'health': 'Instagram API operational'},
          }),
          200,
        );
      });

      final client = GraphQLClient(
        config: config,
        tokenStorage: tokenStorage,
        httpClient: mockHttp,
      );

      final result = await client.query('query { health }');
      expect(result['health'], 'Instagram API operational');
    });

    test('envoie le header Authorization si un token est present', () async {
      await tokenStorage.writeToken('mon_jwt_token_123');

      final mockHttp = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer mon_jwt_token_123');
        return http.Response(
          jsonEncode({
            'data': {
              'me': {'username': 'alex'},
            },
          }),
          200,
        );
      });

      final client = GraphQLClient(
        config: config,
        tokenStorage: tokenStorage,
        httpClient: mockHttp,
      );

      final result = await client.query('query { me { username } }');
      expect(result['me']['username'], 'alex');
    });

    test(
      'leve une GraphQLException si le serveur renvoie des erreurs',
      () async {
        final mockHttp = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'errors': [
                {'message': 'Identifiants invalides'},
              ],
            }),
            200,
          );
        });

        final client = GraphQLClient(
          config: config,
          tokenStorage: tokenStorage,
          httpClient: mockHttp,
        );

        expect(
          () => client.mutate('mutation { login { token } }'),
          throwsA(isA<GraphQLException>()),
        );
      },
    );

    test('leve une AuthException si 401 est renvoye', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final client = GraphQLClient(
        config: config,
        tokenStorage: tokenStorage,
        httpClient: mockHttp,
      );

      expect(
        () => client.query('query { me { username } }'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
