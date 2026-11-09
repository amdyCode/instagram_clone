import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/api/api_providers.dart';
import '../../core/api/auth_token_storage.dart';
import '../../core/api/graphql_client.dart';
import '../../core/models/user.dart';

abstract class AuthRepository {
  Future<AuthPayload> login({
    required String emailOrUsername,
    required String password,
  });

  Future<AuthPayload> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? avatarUrl,
  });

  Future<User?> getMe();

  Future<void> logout();
}

class GraphQLAuthRepository implements AuthRepository {
  GraphQLAuthRepository({required this.client, required this.tokenStorage});

  final GraphQLClient client;
  final AuthTokenStorage tokenStorage;

  static const String _userFragment = '''
    id
    email
    username
    fullName
    bio
    link
    avatarUrl
    postCount
    followerCount
    followingCount
    isMe
  ''';

  static const String _loginMutation =
      '''
    mutation Login(\$input: LoginInput!) {
      login(input: \$input) {
        token
        user {
          $_userFragment
        }
      }
    }
  ''';

  static const String _registerMutation =
      '''
    mutation Register(\$input: RegisterInput!) {
      register(input: \$input) {
        token
        user {
          $_userFragment
        }
      }
    }
  ''';

  static const String _meQuery =
      '''
    query Me {
      me {
        $_userFragment
      }
    }
  ''';

  @override
  Future<AuthPayload> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final data = await client.mutate(
      _loginMutation,
      variables: {
        'input': {'emailOrUsername': emailOrUsername, 'password': password},
      },
    );

    final loginData = data['login'] as Map<String, dynamic>;
    final payload = AuthPayload.fromJson(loginData);

    await tokenStorage.writeToken(payload.token);
    return payload;
  }

  @override
  Future<AuthPayload> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? avatarUrl,
  }) async {
    final data = await client.mutate(
      _registerMutation,
      variables: {
        'input': {
          'email': email,
          'username': username,
          'password': password,
          if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        },
      },
    );

    final registerData = data['register'] as Map<String, dynamic>;
    final payload = AuthPayload.fromJson(registerData);

    await tokenStorage.writeToken(payload.token);
    return payload;
  }

  @override
  Future<User?> getMe() async {
    try {
      final data = await client.query(_meQuery);
      final meData = data['me'];
      if (meData == null) return null;
      return User.fromJson(meData as Map<String, dynamic>);
    } on AuthException {
      await tokenStorage.deleteToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await tokenStorage.deleteToken();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  final tokenStorage = ref.watch(authTokenStorageProvider);
  return GraphQLAuthRepository(client: client, tokenStorage: tokenStorage);
});
