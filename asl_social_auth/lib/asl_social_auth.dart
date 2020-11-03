part of asl_social_auth;

class SocialLoginService {
  // Fireabse auth instance...
  static FirebaseAuth _auth = FirebaseAuth.instance;

  // User sign-in...
  static Future<User> signIn(
    SocialLoginType type, {
    @required String email,
    @required String password,
  }) async {
    // Authorised user detial...
    User _authUser;
    switch (type) {

      // Google...
      case SocialLoginType.Google:
        _authUser = await _signInWithGoogle();
        break;

      // Facebook...
      case SocialLoginType.Facebook:
        _authUser = await _signInWithFacebook();
        break;

      // Email-password...
      case SocialLoginType.EmailPassword:
        _signInWithEmailPassword(email: email, password: password);
        break;

      // Anonymously...
      case SocialLoginType.Anonymously:
        _authUser = await _signInAnoymously();
        break;

      // Twitter...
      case SocialLoginType.Twitter:
        _signInWithTiwtter();
        break;
    }

    return _authUser;
  }

  // Sign-out user...
  static Future<void> signOut(SocialLoginType type) async {
    switch (type) {

      // Google user...
      case SocialLoginType.Google:
        await GoogleSignIn().signOut();
        break;

      // Facebook user...
      case SocialLoginType.Facebook:
        await FacebookAuth.instance.logOut();
        break;

      // Email-password user...
      case SocialLoginType.EmailPassword:
        break;

      // Anonymously logged in user...
      case SocialLoginType.Anonymously:
        break;

      // Twitter user...
      case SocialLoginType.Twitter:
        break;
    }

    // Signs out the current user from firebase user...
    await _auth.signOut();
  }

  // Send forgot password link...
  static Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // SignIn with google...
  static Future<User> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // If user cancel sign-in flow return user...
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // return firebase authenticated user...
      return await _autheticateUserWithFirebaseAuth(credential);
    } catch (e) {
      throw e;
    }
  }

  // Sign with facebook...
  static Future<User> _signInWithFacebook() async {
    // Authorised user detial...
    User _authUser;

    // Sign-in with facebook...
    final LoginResult result = await FacebookAuth.instance.login();

    switch (result.status) {

      // Logged-In result...
      case FacebookAuthLoginResponse.ok:

        // Create a credential from the access token
        _authUser = await _autheticateUserWithFirebaseAuth(
          FacebookAuthProvider.credential(result.accessToken.token),
        );
        break;

      // Login flow cancled by User...
      case FacebookAuthLoginResponse.cancelled:
        print("User Cancled login process");
        break;

      // Error during sign process...
      case FacebookAuthLoginResponse.error:
        throw Exception(
          "Something went wronng, Please try again",
        );
        break;
    }

    return _authUser;
  }

  // // Getting the facebook profile of a signed in user...
  // Future<Map<String, dynamic>> getFacebookUserDetail(
  //     BuildContext context, String token) async {
  //   try {
  //     // Throw unauthorised error if token is empty...
  //     if (token?.isEmpty ?? true)
  //       throw AppException(
  //         type: ExceptionType.UnAuthorised,
  //       );

  //     // Call Facebook graph API to get user detail...
  //     String resp = await ApiCall.callService(
  //         context: context,
  //         requestInfo: APIRequestInfoObj(
  //             endPoint:
  //                 'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
  //     return json.decode(resp);
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  // Anoymous SignIn (Guest SignIn)...
  static Future<User> _signInAnoymously() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }

  // SignIn with email-password...
  static Future<User> _signInWithEmailPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Authenticate user with firebase...
      return await _autheticateUserWithFirebaseAuth(userCredential.credential);
    } on FirebaseAuthException catch (e) {
      String msg = "Something went wrong";

      // No user found...
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';

        // Wrong password...
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
      }

      // Throw auth exception...
      throw Exception(msg);
    } catch (error) {
      // Throw error...
      throw Exception("Something went wrong");
    }
  }

  // Sign-in with twitter
  static Future<User> _signInWithTiwtter() async {
    User _authUser;

    // final twitterLogin = TwitterLogin(
    //   apiKey: APISetup.twitterAPIKey,
    //   apiSecretKey: APISetup.twitterAPISecretKey,
    //   // Callback URL for Twitter App
    //   // Android is a deeplink
    //   // iOS is a URLScheme
    //   redirectURI: 'URLScheme',
    // );

    // // Login user...
    // final AuthResult authResult = await twitterLogin.login();

    // // Manager auth result...
    // switch (authResult.status) {

    //   // Logged In...
    //   case TwitterLoginStatus.loggedIn:
    //     UserCredential authUser =
    //         await _auth.signInWithCustomToken(authResult.authToken);
    //     print(authUser.user.email);
    //     _authUser = authUser.user;
    //     break;

    //   // Flow cancled by user...
    //   case TwitterLoginStatus.cancelledByUser:
    //     print("Cancled by user");
    //     break;

    //   // Error...
    //   case TwitterLoginStatus.error:
    //     print(authResult.errorMessage);

    //     // Throw error...
    //     throw AppException(
    //       title: "Error",
    //       message: "Something went wrong",
    //     );
    //     break;
    // }

    return _authUser;
  }

  // signInWithApple() async {
  //   final credential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //   );

  //   print(credential);

  //   // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
  //   // after they have been validated with Apple (see `Integration` section for more information on how to do this)
  // }

  // // Get user auth state...
  // userAuthState() {
  //   _auth.authStateChanges().listen((User user) {
  //     if (user == null) {
  //       print('User is currently signed out!');
  //     } else {
  //       print('User is signed in!');
  //     }
  //   });
  // }

  // Auth user with firebase auth...
  static Future<User> _autheticateUserWithFirebaseAuth(
    AuthCredential credential,
  ) async {
    if (credential == null) return null;

    UserCredential authResult = await _auth.signInWithCredential(credential);

    User _user = authResult.user;

    // Check user is not anonymous...
    assert(!_user.isAnonymous);
    assert(await _user.getIdToken() != null);

    // Cet Current auth user...
    User currentUser = _auth.currentUser;

    // Check if current user and auth user is same...
    assert(_user.uid == currentUser.uid);

    print("User Name: ${_user.displayName}");
    print("User Email ${_user.email}");
    return _user;
  }
}
