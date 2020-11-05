part of asl_social_auth;

class SocialLoginService {
  // Fireabse auth instance...
  static FirebaseAuth _auth;

  // Twitter keys...
  static String apiKey;
  static String apiSecretKey;
  static String redirectURI;

  /// Initializes a new [FirebaseApp] instance by [name] and [options] and returns
  /// the created app. This method should be called before any usage of FlutterFire plugins.
  ///
  /// The default app instance cannot be initialized here and should be created
  /// using the platform Firebase integration.
  static Future<void> initializeAuthSerivce(
      {String name, FirebaseOptions options}) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      name: name,
      options: options,
    );

    _auth = FirebaseAuth.instance;
  }

  /// User sign-in (Google, Facebook, Anonymously, Email-Password)...
  /// [type] is required to use any service,(e.g: SocialLoginType.Google for Google login).
  ///
  /// [email] and [password] is required for login using email...
  static Future<User> signIn(
    SocialLoginType type, {
    String email,
    String password,
  }) async {
    _checkIfServiceIsInitialize();
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

  /// User Sign-Out (Google, Facebook, Anonymously, Email-Password)...
  /// [type] is required to use any service,(e.g: SocialLoginType.Google for Google login).
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

  /// Send forgot password link for email login...
  /// [type] is required to use any service,(e.g: SocialLoginType.Google for Google login).
  ///
  /// [email] and [password] is required for login using email...
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

    final twitterLogin = TwitterLogin(
      apiKey: "APISetup.twitterAPIKey",
      apiSecretKey: "APISetup.twitterAPISecretKey",
      redirectURI: "APISetup.twitterRedirectURL",
    );

    // Login user...
    final AuthResult authResult = await twitterLogin.login();

    // Manager auth result...
    switch (authResult.status) {

      // Logged In...
      case TwitterLoginStatus.loggedIn:
        UserCredential authUser = await _auth.signInWithCredential(
            TwitterAuthProvider.credential(
                accessToken: authResult.authToken,
                secret: authResult.authTokenSecret));

        _authUser = authUser.user;
        break;

      // Flow cancled by user...
      case TwitterLoginStatus.cancelledByUser:
        print("Cancled by user");
        break;

      // Error...
      case TwitterLoginStatus.error:
        break;
    }

    return _authUser;
  }

  signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);

    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
  }

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

    // Get Current auth user...
    User currentUser = _auth.currentUser;

    // Check if current user and auth user is same...
    assert(_user.uid == currentUser.uid);

    print("User Name: ${_user.displayName}");
    print("User Email ${_user.email}");
    return _user;
  }

  // Check if service is initialize or not...
  static _checkIfServiceIsInitialize() {
    if (_auth == null) {
      throw "Initialize auth serivce in main before using any serivce";
    }
  }
}
