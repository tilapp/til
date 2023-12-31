import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:til/features/authentication/data/logged_in_user_provider.dart';
import 'package:til/features/friends/data/friend_request_db_provider.dart';
import 'package:til/features/friends/domain/friend_request.dart';
import 'package:til/features/friends/presentation/incoming_friend_request.dart';
import 'package:til/features/friends/presentation/suggested_person.dart';
import 'package:til/features/loading/presentation/loading_view.dart';
import 'package:til/features/user/data/user_db_provider.dart';
import 'package:til/features/user/domain/user.dart';
import 'package:til/features/user/presentation/other_profile_view.dart';
import 'package:til/features/user/presentation/user_avatar.dart';

class FriendsView extends ConsumerWidget {
  const FriendsView({super.key});

  static const routeName = '/friends';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget createIncomingRequestsSection(List<FriendRequest> incoming) {
      if (incoming.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          const Text(
            'Incoming Friend Requests',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: incoming
                    .map((fr) => IncomingFriendRequest(
                          friendRequest: fr,
                        ))
                    .toList()),
          ),
          const SizedBox(
            height: 18,
          ),
        ],
      );
    }

    Widget createFriendsSection(List<User> friends) {
      List<Widget> body;
      if (friends.isEmpty) {
        body = [
          const Text(
            "Looks like it's empty!",
            style: TextStyle(fontSize: 16),
          ),
        ];
      } else {
        body = [
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return InkWell(
                  onTap: () {
                    context.go(
                      OtherProfileView.routeName.replaceFirst(':id', friend.id),
                    );
                  },
                  child: UserAvatar(
                    user: friend,
                    maxRadius: 30.0,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                width: 8.0,
              ),
            ),
          ),
        ];
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Friends',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...body,
        ],
      );
    }

    Widget createSimilarSection(List<User> users) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'These users learned similar things as you',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          ...users
              .map((user) => SuggestedPerson(
                    user: user,
                    message:
                        'Both you and ${user.name} learned <TODO> since <TODO>!',
                  ))
              .toList()
        ],
      );
    }

    Widget createYouMayKnowSection(List<User> users) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You may know these people',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return InkWell(
                  onTap: () {
                    context.go(
                      OtherProfileView.routeName.replaceFirst(':id', user.id),
                    );
                  },
                  child: UserAvatar(
                    user: user,
                    maxRadius: 30.0,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                width: 8.0,
              ),
            ),
          ),
        ],
      );
    }

    final userAsync = ref.watch(loggedInUserProvider);
    if (userAsync is! AsyncData) {
      return const LoadingView();
    }
    if (!userAsync.hasValue || userAsync.value == null) {
      return const LoadingView();
    }
    if (userAsync is AsyncData) {
      final user = userAsync.asData!.value!;
      final friendsFuture = ref.watch(userDBProvider).getUsers(user.friendIds);
      final incomingFuture =
          ref.watch(friendRequestDBProvider).getToUser(user.id);
      // TODO(winstonco): Correctly gen people with similar interests
      final similarFuture = ref.watch(userDBProvider).getAll();
      // TODO(winstonco): Correctly gen people you might know
      final youMayKnowFuture = ref.watch(userDBProvider).getAll();
      return FutureBuilder(
        future: Future.wait([
          friendsFuture,
          incomingFuture,
          similarFuture,
          youMayKnowFuture,
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final friends = snapshot.data![0] as List<User>;
          final incoming = snapshot.data![1] as List<FriendRequest>;
          final similar = snapshot.data![2] as List<User>;
          final youMayKnow = snapshot.data![3] as List<User>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  createIncomingRequestsSection(incoming),
                  createFriendsSection(friends),
                  const SizedBox(
                    height: 18,
                  ),
                  createSimilarSection(
                      similar..removeWhere((e) => e.id == user.id)),
                  const SizedBox(
                    height: 18,
                  ),
                  createYouMayKnowSection(
                      youMayKnow..removeWhere((e) => e.id == user.id)),
                ],
              ),
            ),
          );
        },
      );
    }
    return const LoadingView();
  }
}
