import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/post_db.dart';
import '../data/post_db_provider.dart';
import '../../user/domain/user.dart';
import '../../authentication/data/logged_in_user_provider.dart';
import '../../posts/presentation/home_view.dart';

class NewPostView extends ConsumerStatefulWidget {
  const NewPostView({super.key});

  static const routeName = '/new-post';

  @override
  ConsumerState<NewPostView> createState() => _NewPostViewState();
}

class _NewPostViewState extends ConsumerState<NewPostView> {
  late TextEditingController _controller;
  late PostDB postDB;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    postDB = ref.read(postDBProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // https://stackoverflow.com/questions/72315755/close-an-expansiontile-when-another-expansiontile-is-tapped
  int selectedTile = -1;
  int sectionCount = 3;

  void handleCreateNewPost(content, User? loggedInUser) {
    if (loggedInUser == null) return;

    postDB.addPost(
      userId: loggedInUser.id,
      content: content,
    );
    context.go(HomeView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    postDB = ref.watch(postDBProvider);
    var loggedInUser = ref.watch(loggedInUserProvider);

    return switch (loggedInUser) {
      AsyncData(:final value) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Today I learned...',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (String newPost) async {
                  handleCreateNewPost(newPost, value);
                },
                minLines: 5,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  hintText: '''
...to fly.
...how to ride a bike.''',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.text = '';
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 36,
                ),
                ElevatedButton(
                  onPressed: () {
                    handleCreateNewPost(_controller.text, value);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      AsyncError(:final error) => Text('Error: $error'),
      _ => const CircularProgressIndicator(),
    };
  }
}
