part of asl_social_auth;

// Sign with facebook...
Future<User> _signInWithFacebook() async {
  // Authorised user detial...
  User _authUser;

  try {
    // Sign-in with facebook...
    final AccessToken result = await FacebookAuth.instance.login();

    // Create a credential from the access token
    _authUser = await _autheticateUserWithFirebaseAuth(
      FacebookAuthProvider.credential(result.token),
    );
  } on FacebookAuthException catch (e) {
    switch (e.errorCode) {
      case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
        throw "You have a previous login operation in progress";
        break;
      case FacebookAuthErrorCode.CANCELLED:
        print("login cancelled");
        break;
      case FacebookAuthErrorCode.FAILED:
        throw "Unable to login, please try after sometime";
        break;
    }
  } catch (e) {
    throw e;
  }

  return _authUser;
}
