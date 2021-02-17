part of asl_social_auth;

// Auth user with firebase auth...
Future<User> _autheticateUserWithFirebaseAuth(
  AuthCredential credential,
) async {
  if (credential == null) return null;

  UserCredential authResult =
      await SocialLoginService._auth.signInWithCredential(credential);
  User _user = authResult.user;

  // Check user is not anonymous...
  assert(!_user.isAnonymous);
  assert(await _user.getIdToken() != null);

  // Get Current auth user...
  User currentUser = SocialLoginService._auth.currentUser;

  // Check if current user and auth user is same...
  assert(_user.uid == currentUser.uid);

  print("User Name: ${_user?.displayName ?? "N/A"}");
  print("User Email ${_user?.email ?? "N/A"}");
  return _user;
}
