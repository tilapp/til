import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:til/features/crud_collection.dart';
import '../domain/user.dart';

final class UserDB extends CrudCollection<User> {
  UserDB(this.ref)
      : super(
          collectionPath: 'users',
          fromJson: User.fromJson,
        );

  final ProviderRef<UserDB> ref;
  // final _firestore = FirebaseFirestore.instance;
  // final List<User> _users = [
  //   User(
  //     id: '0',
  //     name: 'John Foo',
  //     organizationId: '0',
  //     email: 'johnfoo@hawaii.edu',
  //     aboutMe: "I'm not a real person.",
  //     isVerified: false,
  //     imagePath: 'jenna-deane.jpg',
  //     role: Role.user,
  //     friendIds: [],
  //   ),
  //   User(
  //     id: '1',
  //     name: 'Winston Co',
  //     organizationId: '0',
  //     email: 'cow@hawaii.edu',
  //     aboutMe: 'I kinda like algorithms.',
  //     isVerified: true,
  //     imagePath: 'winston_co.png',
  //     role: Role.user,
  //     friendIds: [],
  //   ),
  //   User(
  //     id: '2',
  //     name: 'Korn Jiamsripong',
  //     organizationId: '1',
  //     email: 'kornj2@illinois.edu',
  //     aboutMe: "Hi. I don't like C++.",
  //     isVerified: true,
  //     imagePath: 'korn_jiamsripong.png',
  //     role: Role.user,
  //     friendIds: [],
  //   ),
  // ];

  Future<List<User>> fetchUsers() async {
    return await getAll();
  }

  Future<List<User>> getUsers(List<DocumentId> userIDs) async {
    if (userIDs.isEmpty) {
      return List.empty();
    }
    return await getWhere(FieldPath.documentId, whereIn: userIDs);
  }

  Future<DocumentId?> createUser({
    required UserUid userUid,
    required String name,
    required String email,
    String? aboutMe,
    required String imagePath,
  }) {
    final newUserId = createOne(User(
      id: '',
      userUid: userUid,
      name: name,
      email: email,
      organizationId: '0',
      aboutMe: aboutMe ?? '',
      isVerified: false,
      imagePath: imagePath,
      role: Role.user,
      friendIds: [],
    ));
    return newUserId;
  }

  Future<DocumentId?> createOrganizationAdmin({
    required UserUid userUid,
    required String name,
    required String email,
    String? aboutMe,
    required DocumentId organizationId,
    required String imagePath,
  }) {
    final newUserId = createOne(User(
      id: '',
      userUid: userUid,
      name: name,
      email: email,
      organizationId: organizationId,
      aboutMe: aboutMe ?? '',
      isVerified: true,
      imagePath: imagePath,
      role: Role.organizationAdmin,
      friendIds: [],
    ));
    return newUserId;
  }
}
