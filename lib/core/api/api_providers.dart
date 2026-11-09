import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';
import 'auth_token_storage.dart';
import 'graphql_client.dart';

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null;
});

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.defaultConfig();
});

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthTokenStorage(prefs: prefs);
});

final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenStorage = ref.watch(authTokenStorageProvider);
  final client = GraphQLClient(config: config, tokenStorage: tokenStorage);

  ref.onDispose(client.close);

  return client;
});
