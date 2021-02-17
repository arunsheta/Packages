part of asl_social_auth;

// Sign-in with twitter
Future<User> _signInWithTiwtter() async {
  User _authUser;

  final twitterLogin = TwitterLogin(
    apiKey: SocialLoginService._twitterAPIkey,
    apiSecretKey: SocialLoginService._twitterAPISecretKey,
    redirectURI: SocialLoginService._twitterRedirectURI,
  );

  // Login user...
  final AuthResult authResult = await twitterLogin.login();

  // Manager auth result...
  switch (authResult.status) {

    // Logged In...
    case TwitterLoginStatus.loggedIn:
      UserCredential authUser =
          await SocialLoginService._auth.signInWithCredential(
        TwitterAuthProvider.credential(
            accessToken: authResult.authToken,
            secret: authResult.authTokenSecret),
      );

      _authUser = authUser.user;
      break;

    // Flow cancled by user...
    case TwitterLoginStatus.cancelledByUser:
      print("Cancled by user");
      break;

    // Error...
    case TwitterLoginStatus.error:
      throw authResult.errorMessage;
      break;
  }

  return _authUser;
}
