import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/post.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/search/explore_grid.dart';
import '../../core/widgets/search/search_bar_field.dart';
import '../../core/widgets/search/user_search_tile.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(searchControllerProvider.notifier)
        .onQueryChanged(_searchController.text);
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(searchControllerProvider.notifier).clearSearch();
  }

  void _onCancelSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    ref.read(searchControllerProvider.notifier).clearSearch();
  }

  void _onUserSelected(User user) {
    ref.read(searchControllerProvider.notifier).addRecent(user);
    context.push('/u/${user.username}');
  }

  void _onRemoveRecent(User user) {
    ref.read(searchControllerProvider.notifier).removeRecent(user);
  }

  void _onClearAllRecents() {
    ref.read(searchControllerProvider.notifier).clearRecents();
  }

  void _onPostSelected(ProfilePost post) {
    context.push('/post/${post.id}');
  }

  Future<void> _onRefresh() async {
    await ref.read(searchControllerProvider.notifier).loadExplore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchState = ref.watch(searchControllerProvider);
    final isSearching =
        _focusNode.hasFocus || searchState.query.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onClear: _onClearSearch,
                    ),
                  ),
                  if (isSearching) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _onCancelSearch,
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: _buildContent(theme, isDark, searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark, SearchState state) {
    if (state.query.isNotEmpty) {
      if (state.isSearching) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      }

      if (state.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: isDark
                    ? AppColors.darkSecondary
                    : AppColors.lightSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun compte trouve pour "${state.query}"',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Verifiez l\'orthographe ou essayez un autre mot-cle.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkSecondary
                      : AppColors.lightSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: state.searchResults.length,
        itemBuilder: (context, index) {
          final user = state.searchResults[index];
          return UserSearchTile(user: user, onTap: () => _onUserSelected(user));
        },
      );
    }

    if (_focusNode.hasFocus) {
      if (state.recentSearches.isEmpty) {
        return Center(
          child: Text(
            'Aucune recherche recente',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkSecondary
                  : AppColors.lightSecondary,
            ),
          ),
        );
      }

      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: _onClearAllRecents,
                  child: const Text(
                    'Effacer tout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...state.recentSearches.map(
            (user) => UserSearchTile(
              user: user,
              isRecent: true,
              onTap: () => _onUserSelected(user),
              onRemove: () => _onRemoveRecent(user),
            ),
          ),
        ],
      );
    }

    if (state.isLoadingExplore && state.explorePosts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          ExploreGrid(posts: state.explorePosts, onPostTap: _onPostSelected),
        ],
      ),
    );
  }
}
