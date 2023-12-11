import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/providers/firebase.dart';

part 'logged_user.g.dart';

@riverpod
class LoggedUser extends _$LoggedUser {
  @override
  Future<AppUser?> build() async {
    final auth = ref.watch(authProvider).currentUser;
    if (auth != null) {
      final firestore = ref.watch(firestoreProvider);
      final user = await firestore.collection('users').doc(auth.uid).get();
      return AppUser(
          id: auth.uid,
          name: user.data()!['name'],
          email: user.data()!['email']);
    } else {
      return null;
    }
  }

  Future<void> authenticateUser(String email, String password,
      {String name = ''}) async {
    final auth = ref.read(authProvider);
    if (name.isEmpty) {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } else {
      final db = ref.read(firestoreProvider);
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await db.collection('users').doc(authResult.user!.uid).set(
        {
          'name': name,
          'email': email,
          'membership': 'STANDARD',
        },
        SetOptions(merge: true),
      );
    }
    ref.invalidateSelf();
  }

  Future<void> signOutUser() async {
    await ref.read(authProvider).signOut();
    ref.invalidateSelf();
  }
}
