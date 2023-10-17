import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:til/data/friend_request_db.dart';
import 'package:til/data/organization_db.dart';
import 'package:til/data/post_db.dart';
import 'package:til/data/user_db.dart';
import 'package:til/settings/sign_in.dart';

import 'package:til/views/components/feed_post.dart';

class OtherProfileView extends StatefulWidget {
  const OtherProfileView({
    super.key,
    required this.user,
  });

  static const routeName = '/other-profile/:id';

  final User user;

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  final headerStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  Widget createHeaderSection() {
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

    var name = widget.user.name;
    var organization = organizationDB.getById(widget.user.organizationId).name;
    var email = widget.user.email;

    return Row(
      children: [
        CircleAvatar(
          minRadius: 75,
          backgroundImage: AssetImage('assets/images/${widget.user.imagePath}'),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createTitleBody(
              title: 'Name',
              body: name,
            ),
            createTitleBody(
              title: 'Organization',
              body: organization,
            ),
            createEmailSection(
              email: email,
            ),
          ],
        ),
      ],
    );
  }

  Widget createAboutMeSection() {
    var aboutMe = widget.user.aboutMe;

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

  Widget createThingsYouLearnedSection() {
    var thingsLearned = postDB.getUserPosts(widget.user.id);

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

  Widget createSendFriendRequestButton(BuildContext context) {
    void handleSendFriendRequest() {
      final success =
          friendRequestDB.sendFromTo(loggedInUser!.id, widget.user.id);
      if (success) {
        developer.log(
            'Send friend request from ${loggedInUser!.name} to ${widget.user.name}: success');
        context
            .go(OtherProfileView.routeName.replaceFirst(':id', widget.user.id));
      } else {
        developer.log(
            'Send friend request from ${loggedInUser!.name} to ${widget.user.name}: failed');
      }
    }

    bool friendRequestAlreadySent = false;

    if (friendRequestDB
        .getFromUser(loggedInUser!.id)
        .any((fr) => fr.to == widget.user.id)) {
      friendRequestAlreadySent = true;
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              createHeaderSection(),
              const SizedBox(
                height: 32,
              ),
              createAboutMeSection(),
              const SizedBox(
                height: 32,
              ),
              createThingsYouLearnedSection(),
            ],
          ),
          createSendFriendRequestButton(context),
        ],
      ),
    );
  }
}
