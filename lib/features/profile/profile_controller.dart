import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profile.dart';
import '../auth/auth_controller.dart';
import 'profile_repository.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  final Profile? profile;
  final bool isLoading;
  final String? error;

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final user = ref.watch(authControllerProvider).user;
    if (user != null) {
      return ProfileState(profile: Profile.fromUser(user), isLoading: false);
    }
    return const ProfileState(isLoading: false);
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.getMyProfile();
      if (profile != null) {
        state = state.copyWith(
          profile: profile,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger le profil',
      );
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? link,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
        link: link,
      );

      final current = state.profile;
      state = state.copyWith(
        profile: current?.copyWith(
              fullName: updated.fullName,
              bio: updated.bio,
              avatarUrl: updated.avatarUrl,
              link: updated.link,
            ) ??
            updated,
        isLoading: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de mettre a jour le profil',
      );
      return false;
    }
  }
}

final myProfileControllerProvider =
    NotifierProvider<MyProfileController, ProfileState>(
  MyProfileController.new,
);

class UserProfileController extends Notifier<ProfileState> {
  UserProfileController(this.username);

  final String username;

  @override
  ProfileState build() => const ProfileState(isLoading: true);

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.getUserProfile(username);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger le profil',
      );
    }
  }

  Future<void> toggleFollow(String userId) async {
    final current = state.profile;
    if (current == null) return;

    final willFollow = !current.isFollowing;
    final optimistic = current.copyWith(
      isFollowing: willFollow,
      followerCount: current.followerCount + (willFollow ? 1 : -1),
    );
    state = state.copyWith(profile: optimistic);

    try {
      if (willFollow) {
        await _repository.follow(userId);
      } else {
        await _repository.unfollow(userId);
      }
    } catch (_) {
      state = state.copyWith(profile: current);
    }
  }
}

final userProfileControllerProvider =
    NotifierProvider.family<UserProfileController, ProfileState, String>(
  UserProfileController.new,
);
