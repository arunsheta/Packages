part of asl_social_auth;

// SignIn with Apple...
Future<User> _signInWithApple() async {
  User _authUser;
  try {
    // Get
    final AuthorizationCredentialAppleID appleIdCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: SocialLoginService._appleClientId,
        redirectUri: Uri.parse(SocialLoginService._appleRedirectUri),
      ),
    );

    // Get an OAuthCredential...
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    // Use the credential to sign in to firebase
    _authUser = await _autheticateUserWithFirebaseAuth(credential);
  } catch (e) {
    if ((e?.code ?? "") != AuthorizationErrorCode.unknown &&
        (e?.code ?? "") != AuthorizationErrorCode.canceled) {
      throw Exception(e.message);
    }
  }
  return _authUser;
}
