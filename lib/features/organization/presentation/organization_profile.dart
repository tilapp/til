import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:til/features/loading/presentation/loading_view.dart';
import 'package:til/features/organization/domain/organization.dart';
import 'package:til/features/posts/domain/post.dart';
import 'package:til/features/posts/presentation/new_post_view.dart';
import 'package:til/features/user/domain/user.dart';

import '../../organization/data/organization_db.dart';
import '../../organization/data/organization_db_provider.dart';
import '../../posts/data/post_db.dart';
import '../../posts/data/post_db_provider.dart';
import '../../authentication/data/logged_in_user_provider.dart';
import '../../posts/presentation/feed_post.dart';

class OrganizationProfileView extends ConsumerStatefulWidget {
  const OrganizationProfileView({
    super.key,
    required this.id,
  });

  static const routeName = '/organization/:id';

  final String id;

  @override
  ConsumerState<OrganizationProfileView> createState() =>
      _OrganizationProfileViewState();
}

class _OrganizationProfileViewState
    extends ConsumerState<OrganizationProfileView> {
  @override
  void initState() {
    super.initState();
  }

  final headerStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  Widget _createHeaderSection(User loggedInUser, Organization? organization) {
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

    return Row(
      children: [
        CircleAvatar(
          minRadius: 75,
          backgroundImage:
              AssetImage('assets/images/${loggedInUser.imagePath}'),
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
                body: loggedInUser.name,
              ),
              createTitleBody(
                title: 'Organization',
                body: organization?.name ??
                    'Error: Organization with id=${loggedInUser.organizationId} not found',
              ),
              createEmailSection(
                email: loggedInUser.email,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _createAboutMeSection(User loggedInUser) {
    var aboutMe = loggedInUser.aboutMe;

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

  Widget _createMemberPostsSection(List<Post>? posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Some things you learned',
          style: headerStyle,
        ),
        Column(
          children: [
            if (posts != null && posts.isNotEmpty) ...[
              ...posts
                  .map((e) => Container(
                        margin: const EdgeInsets.only(
                          top: 12,
                        ),
                        child: FeedPost(post: e),
                      ))
                  .toList()
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUserAsync = ref.watch(loggedInUserProvider);

    if (loggedInUserAsync is AsyncData) {
      final loggedInUser = loggedInUserAsync.asData!.value!;
      final orgDB = ref.watch(organizationDBProvider);
      final memberPostsFuture = orgDB.getMemberPosts(widget.id);
      final organizationFuture = orgDB.getById(widget.id);

      return FutureBuilder(
        future: Future.wait([memberPostsFuture, organizationFuture]),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final memberPosts = snapshot.data![0] as List<Post>;
          final organization = snapshot.data![1] as Organization?;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _createHeaderSection(loggedInUser, organization),
                const SizedBox(
                  height: 32,
                ),
                _createAboutMeSection(loggedInUser),
                const SizedBox(
                  height: 32,
                ),
                _createMemberPostsSection(memberPosts),
              ],
            ),
          );
        },
      );
    } else {
      return const LoadingView();
    }
  }
}
