part of asl_social_auth;

// SignIn with google...

Future<User> _signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  // If user cancel sign-in flow return user...
  if (googleUser == null) return null;

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // return firebase authenticated user...
  return await _autheticateUserWithFirebaseAuth(credential);
}
