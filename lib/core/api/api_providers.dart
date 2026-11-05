import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'auth_token_storage.dart';
import 'graphql_client.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.defaultConfig();
});

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return AuthTokenStorage();
});

final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenStorage = ref.watch(authTokenStorageProvider);
  final client = GraphQLClient(config: config, tokenStorage: tokenStorage);

  ref.onDispose(client.close);

  return client;
});
