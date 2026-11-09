import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/post.dart';
import '../../core/models/user.dart';
import 'search_repository.dart';

class SearchState {
  const SearchState({
    this.explorePosts = const [],
    this.searchResults = const [],
    this.recentSearches = const [],
    this.isLoadingExplore = false,
    this.isSearching = false,
    this.query = '',
    this.error,
  });

  final List<ProfilePost> explorePosts;
  final List<User> searchResults;
  final List<User> recentSearches;
  final bool isLoadingExplore;
  final bool isSearching;
  final String query;
  final String? error;

  SearchState copyWith({
    List<ProfilePost>? explorePosts,
    List<User>? searchResults,
    List<User>? recentSearches,
    bool? isLoadingExplore,
    bool? isSearching,
    String? query,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      explorePosts: explorePosts ?? this.explorePosts,
      searchResults: searchResults ?? this.searchResults,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoadingExplore: isLoadingExplore ?? this.isLoadingExplore,
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SearchController extends Notifier<SearchState> {
  @override
  SearchState build() {
    Future.microtask(() => loadExplore());
    return const SearchState(isLoadingExplore: true);
  }

  SearchRepository get _repository => ref.read(searchRepositoryProvider);

  Future<void> loadExplore() async {
    state = state.copyWith(isLoadingExplore: true, clearError: true);
    try {
      final posts = await _repository.getExplorePosts();
      final profilePosts = posts.map((p) => p.toProfilePost()).toList();
      state = state.copyWith(
        explorePosts: profilePosts,
        isLoadingExplore: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingExplore: false,
        error: 'Impossible de charger la page explorer',
      );
    }
  }

  Future<void> onQueryChanged(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery == state.query) return;

    if (cleanQuery.isEmpty) {
      state = state.copyWith(query: '', searchResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(query: cleanQuery, isSearching: true);
    try {
      final users = await _repository.searchUsers(cleanQuery);
      if (state.query == cleanQuery) {
        state = state.copyWith(searchResults: users, isSearching: false);
      }
    } catch (_) {
      if (state.query == cleanQuery) {
        state = state.copyWith(
          searchResults: [],
          isSearching: false,
          error: 'Erreur lors de la recherche',
        );
      }
    }
  }

  void addRecent(User user) {
    final list = List<User>.from(state.recentSearches);
    list.removeWhere((u) => u.username == user.username);
    list.insert(0, user);
    state = state.copyWith(recentSearches: list);
  }

  void removeRecent(dynamic target) {
    final username = target is User ? target.username : target.toString();
    final list = List<User>.from(state.recentSearches);
    list.removeWhere((u) => u.username == username);
    state = state.copyWith(recentSearches: list);
  }

  void clearRecents() {
    state = state.copyWith(recentSearches: []);
  }

  void clearSearch() {
    state = state.copyWith(query: '', searchResults: [], isSearching: false);
  }
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
