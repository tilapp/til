import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:til/features/friends/domain/friend_request.dart';
import 'package:til/features/loading/presentation/loading_view.dart';
import 'package:til/features/organization/domain/organization.dart';
import 'package:til/features/posts/domain/post.dart';
import 'package:til/features/user/presentation/profile_view.dart';
import 'package:til/features/user/presentation/user_avatar.dart';
import '../../friends/data/friend_request_db.dart';
import '../../friends/data/friend_request_db_provider.dart';
import '../../organization/data/organization_db_provider.dart';
import '../../posts/data/post_db.dart';
import '../../posts/data/post_db_provider.dart';
import '../domain/user.dart';
import '../data/user_db_provider.dart';
import '../../authentication/data/logged_in_user_provider.dart';

import 'package:til/features/posts/presentation/feed_post.dart';

class OtherProfileView extends ConsumerStatefulWidget {
  const OtherProfileView({
    super.key,
    required this.id,
  });

  static const routeName = '/other-profile/:id';

  final String id;

  @override
  ConsumerState<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends ConsumerState<OtherProfileView> {
  late PostDB postDB;
  late FriendRequestDB friendRequestDB;

  @override
  void initState() {
    super.initState();
    postDB = ref.read(postDBProvider);
    friendRequestDB = ref.read(friendRequestDBProvider);
  }

  final headerStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  Widget createHeaderSection(User? user, Organization? organization) {
    Widget createTitleBody({required String title, required String body}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: headerStyle,
            ),
            Text(
              body,
              style: const TextStyle(
                fontSize: 16,
              ),
            )
          ],
        ),
      );
    }

    Widget createEmailSection({required String email}) {
      String emailStatus = 'Email verified';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            emailStatus,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.lightBlue,
            ),
          ),
        ],
      );
    }

    if (user != null) {
      return Row(
        children: [
          UserAvatar(
            user: user,
            minRadius: 75,
          ),
          const SizedBox(
            width: 20,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                createTitleBody(
                  title: 'Name',
                  body: user.name,
                ),
                createTitleBody(
                  title: 'Organization',
                  body: organization?.name ??
                      'Error: Organization with id=${user.organizationId} not found',
                ),
                createEmailSection(
                  email: user.email,
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const LoadingView();
  }

  Widget createAboutMeSection(User? user) {
    if (user != null) {
      var aboutMe = user.aboutMe;

      if (aboutMe.isEmpty) {
        return Container();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About me',
            style: headerStyle,
          ),
          Text(
            aboutMe,
          ),
        ],
      );
    }
    return const LoadingView();
  }

  Widget createThingsYouLearnedSection(
    User? user,
    List<Post> thingsLearned,
  ) {
    if (user != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Some things this person learned',
            style: headerStyle,
          ),
          Column(
            children: thingsLearned
                .map((e) => Container(
                      margin: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: FeedPost(post: e),
                    ))
                .toList(),
          ),
        ],
      );
    }
    return const LoadingView();
  }

  Widget createSendFriendRequestButton(
    BuildContext context,
    User user,
    User loggedInUser,
    bool friendRequestAlreadySent,
  ) {
    void handleSendFriendRequest() {
      friendRequestDB.sendFromTo(loggedInUser.id, user.id).then((success) {
        if (success) {
          developer.log(
              'Send friend request from ${loggedInUser.name} to ${user.name}: success');
          context.go(OtherProfileView.routeName.replaceFirst(':id', user.id));
        } else {
          developer.log(
              'Send friend request from ${loggedInUser.name} to ${user.name}: failed');
        }
      });
    }

    return Positioned.fill(
      top: null,
      bottom: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    !friendRequestAlreadySent ? handleSendFriendRequest : null,
                clipBehavior: Clip.hardEdge,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const StadiumBorder(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: !friendRequestAlreadySent
                          ? [
                              const Color(0xFF6d00c2),
                              const Color(0xFF0014C6),
                            ]
                          : [
                              Colors.transparent,
                              Colors.transparent,
                            ],
                      stops: const [
                        0.2,
                        1.0,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      transform: const GradientRotation(1.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: !friendRequestAlreadySent
                        ? [
                            const Icon(
                              Icons.add_circle_outline,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            const Text(
                              'Send a friend request!',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ]
                        : [
                            const Text(
                              'You already sent a friend request.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userFuture = ref.watch(userDBProvider).getById(widget.id);
    final loggedInUserAsync = ref.watch(loggedInUserProvider);
    postDB = ref.watch(postDBProvider);

    return switch (loggedInUserAsync) {
      AsyncData(:final value) => Container(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: userFuture,
            builder: (context, snapshot) {
              if (value == null) {
                return const LoadingView();
              }
              final loggedInUser = value;
              if (!snapshot.hasData ||
                  snapshot.connectionState != ConnectionState.done) {
                return const LoadingView();
              }
              final user = snapshot.data!;
              // redirect to profile if looking at yourself
              if (user.id == loggedInUser.id) {
                context.go(ProfileView.routeName);
              }
              final thingsLearnedFuture =
                  ref.watch(postDBProvider).getUserPosts(user.id);
              final organizationFuture = ref
                  .watch(organizationDBProvider)
                  .getById(user.organizationId);
              final friendRequestsSentFuture =
                  ref.watch(friendRequestDBProvider).getFromUser(value.id);

              return FutureBuilder(
                future: Future.wait([
                  thingsLearnedFuture,
                  organizationFuture,
                  friendRequestsSentFuture,
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }

                  final thingsLearned = snapshot.data![0] as List<Post>;
                  final organization = snapshot.data![1] as Organization?;
                  final friendReqsSent =
                      snapshot.data![2] as List<FriendRequest>;

                  final friendRequestAlreadySent =
                      friendReqsSent.any((fr) => fr.to == user.id);
                  final showFriendReqBtn =
                      !loggedInUser.friendIds.contains(user.id);

                  return Stack(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        children: [
                          createHeaderSection(user, organization),
                          const SizedBox(
                            height: 32,
                          ),
                          createAboutMeSection(user),
                          const SizedBox(
                            height: 32,
                          ),
                          createThingsYouLearnedSection(
                            user,
                            thingsLearned,
                          ),
                        ],
                      ),
                      if (showFriendReqBtn)
                        createSendFriendRequestButton(
                          context,
                          user,
                          loggedInUser,
                          friendRequestAlreadySent,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      AsyncError(:final error) => Text('Error: $error'),
      _ => const LoadingView(),
    };
  }
}
