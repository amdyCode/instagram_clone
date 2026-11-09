import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  const ApiConfig({
    required this.graphqlUrl,
    this.timeout = const Duration(seconds: 10),
  });

  final String graphqlUrl;
  final Duration timeout;

  static String get defaultGraphqlUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:4000/graphql';
    }

    return 'http://localhost:4000/graphql';
  }

  factory ApiConfig.defaultConfig() {
    return ApiConfig(graphqlUrl: defaultGraphqlUrl);
  }
}
