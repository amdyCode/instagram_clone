import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/story.dart';
import '../../core/widgets/story/story_bottom_bar.dart';
import '../../core/widgets/story/story_header.dart';
import '../../core/widgets/story/story_progress_bars.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, this.initialIndex = 0, this.stories});

  final int initialIndex;
  final List<Story>? stories;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late final List<Story> _stories;

  late int _currentUserIndex;
  int _currentItemIndex = 0;
  bool _isPaused = false;
  final Map<String, bool> _likedItems = {};

  Story get _currentStory => _stories[_currentUserIndex];
  List<StoryItem> get _currentItems => _currentStory.items;
  StoryItem? get _currentItem =>
      _currentItems.isNotEmpty ? _currentItems[_currentItemIndex] : null;

  @override
  void initState() {
    super.initState();
    _stories = widget.stories ?? const [];
    _currentUserIndex = _stories.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _stories.length - 1);
    _pageController = PageController(initialPage: _currentUserIndex);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onNext();
      }
    });

    if (_stories.isNotEmpty) {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentItemIndex < _currentItems.length - 1) {
      setState(() {
        _currentItemIndex++;
      });
      _animController.forward(from: 0.0);
    } else if (_currentUserIndex < _stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) context.pop();
    }
  }

  void _onPrevious() {
    if (_currentItemIndex > 0) {
      setState(() {
        _currentItemIndex--;
      });
      _animController.forward(from: 0.0);
    } else if (_currentUserIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _animController.forward(from: 0.0);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentUserIndex = index;
      _currentItemIndex = 0;
    });
    _animController.forward(from: 0.0);
  }

  void _pause() {
    if (!_isPaused) {
      setState(() => _isPaused = true);
      _animController.stop();
    }
  }

  void _resume() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _animController.forward();
    }
  }

  void _toggleLike() {
    final item = _currentItem;
    if (item == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      final current = _likedItems[item.id] ?? item.isLiked;
      _likedItems[item.id] = !current;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Aucune story disponible',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 250) {
              context.pop();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: _stories.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, userIdx) {
              final story = _stories[userIdx];
              final items = story.items;
              final isCurrent = userIdx == _currentUserIndex;
              final item = items.isNotEmpty
                  ? items[isCurrent ? _currentItemIndex : 0]
                  : null;
              final isLiked = item != null
                  ? (_likedItems[item.id] ?? item.isLiked)
                  : false;

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (item != null)
                    CachedNetworkImage(
                      imageUrl: item.mediaUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(
                        color: Color(0xFF1C1C1E),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: Color(0xFF1C1C1E),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white38,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  else
                    const ColoredBox(color: Colors.black),

                  // Degrade superieur pour la lisibilite
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Degrade inferieur
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _onPrevious,
                          onLongPressStart: (_) => _pause(),
                          onLongPressEnd: (_) => _resume(),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _onNext,
                          onLongPressStart: (_) => _pause(),
                          onLongPressEnd: (_) => _resume(),
                        ),
                      ),
                    ],
                  ),

                  SafeArea(
                    child: AnimatedOpacity(
                      opacity: _isPaused ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) => StoryProgressBars(
                              itemCount: items.length,
                              activeIndex: isCurrent ? _currentItemIndex : 0,
                              progress: isCurrent ? _animController.value : 0.0,
                            ),
                          ),
                          StoryHeader(
                            user: story.user,
                            createdAt: item?.createdAt ?? DateTime.now(),
                            closeFriends: story.closeFriends,
                            onClose: () => context.pop(),
                            onUserTap: () {
                              context.push('/u/${story.user.username}');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      child: AnimatedOpacity(
                        opacity: _isPaused ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item?.caption != null &&
                                item!.caption!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Text(
                                  item.caption!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            StoryBottomBar(
                              isLiked: isLiked,
                              onLikeToggle: _toggleLike,
                              onShareTap: () {},
                              onSendTap: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
