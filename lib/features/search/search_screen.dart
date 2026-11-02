import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/post.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/search/explore_grid.dart';
import '../../core/widgets/search/search_bar_field.dart';
import '../../core/widgets/search/user_search_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  List<User> _filteredUsers = [];
  late List<User> _recentSearches;
  late List<ProfilePost> _explorePosts;

  @override
  void initState() {
    super.initState();
    _explorePosts = List.of(mockExplorePosts);
    _recentSearches = [mockUsers[4], mockUsers[1], mockUsers[0]];

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
    final q = _searchController.text.trim();
    if (q != _query) {
      setState(() {
        _query = q;
        _filteredUsers = searchUsers(_query);
      });
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filteredUsers = [];
    });
  }

  void _onCancelSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _query = '';
      _filteredUsers = [];
    });
  }

  void _onUserSelected(User user) {
    if (!_recentSearches.any((u) => u.username == user.username)) {
      setState(() {
        _recentSearches.insert(0, user);
      });
    }
    context.push('/u/${user.username}');
  }

  void _onRemoveRecent(User user) {
    setState(() {
      _recentSearches.removeWhere((u) => u.username == user.username);
    });
  }

  void _onClearAllRecents() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _onPostSelected(ProfilePost post) {
    context.push('/post/${post.id}');
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _explorePosts = List.of(mockExplorePosts)..shuffle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSearching = _focusNode.hasFocus || _query.isNotEmpty;

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
            Expanded(child: _buildContent(theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    if (_query.isNotEmpty) {
      if (_filteredUsers.isEmpty) {
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
                'Aucun compte trouvé pour « $_query »',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vérifiez l\'orthographe ou essayez un autre mot-clé.',
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
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return UserSearchTile(user: user, onTap: () => _onUserSelected(user));
        },
      );
    }

    if (_focusNode.hasFocus) {
      if (_recentSearches.isEmpty) {
        return Center(
          child: Text(
            'Aucune recherche récente',
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
                  'Récents',
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
          ..._recentSearches.map(
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

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          ExploreGrid(posts: _explorePosts, onPostTap: _onPostSelected),
        ],
      ),
    );
  }
}
