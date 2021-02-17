part of asl_social_auth;

class SocialLoginService {
  // Fireabse auth instance...
  static FirebaseAuth _auth;

  // Twitter keys...
  static String _twitterAPIkey;
  static String _twitterAPISecretKey;
  static String _twitterRedirectURI;

  // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup...
  static String _appleClientId;
  static String _appleRedirectUri;

  /// Initializes a new [FirebaseApp] instance by [name] and [options] and returns
  /// the created app. This method should be called before any usage of FlutterFire plugins.
  ///
  /// The default app instance cannot be initialized here and should be created
  /// using the platform Firebase integration.
  static Future<void> initializeAuthSerivce({
    String name,
    FirebaseOptions options,
    String twitterAPIkey,
    String twitterAPISecretKey,
    String twitterRedirectURI,
    String appleClientId,
    String appleRedirectUri,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      name: name,
      options: options,
    );

    _auth = FirebaseAuth.instance;
    _twitterAPIkey = twitterAPIkey;
    _twitterAPISecretKey = twitterAPISecretKey;
    _twitterRedirectURI = twitterRedirectURI;
    _appleClientId = appleClientId;
    _appleRedirectUri = appleRedirectUri;
  }

  /// User sign-in (Google, Facebook, Anonymously, Email-Password, Twitter, Apple)...
  /// [type] is required to use any service,(e.g: SocialLoginType.Google for Google login).
  ///
  /// [email] and [password] is required for login using email...
  static Future<User> signIn(
    SocialLoginType type, {
    String email,
    String password,
  }) async {
    // Check if fireabse is initlized or not...
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

      // Email-password Sign-In...
      case SocialLoginType.EmailPasswordSignIn:
        _signInWithEmailPassword(email: email, password: password);
        break;

      // Email-password Sign-Up...
      case SocialLoginType.EmailPasswordSignUp:
        _signUpWithEmailPassword(email: email, password: password);
        break;

      // Anonymously...
      case SocialLoginType.Anonymously:
        _authUser = await _signInAnoymously();
        break;

      // Twitter...
      case SocialLoginType.Twitter:
        _authUser = await _signInWithTiwtter();
        break;

      // Apple...
      case SocialLoginType.Apple:
        _authUser = await _signInWithApple();
        break;
    }

    return _authUser;
  }

  /// User Sign-Out (Google, Facebook, Anonymously, Email-Password, Twitter, Apple)...
  /// [type] is required to use any service,(e.g: SocialLoginType.Google for Google login).
  static Future<void> signOut(SocialLoginType type) async {
    switch (type) {

      // Google...
      case SocialLoginType.Google:
        await GoogleSignIn().signOut();
        break;

      // Facebook...
      case SocialLoginType.Facebook:
        await FacebookAuth.instance.logOut();
        break;

      // Email-password Sign-In...
      case SocialLoginType.EmailPasswordSignIn:
        break;

      // Email-password Sign-Up...
      case SocialLoginType.EmailPasswordSignUp:
        break;

      // Anonymously...
      case SocialLoginType.Anonymously:
        break;

      // Twitter...
      case SocialLoginType.Twitter:
        break;

      // Apple...
      case SocialLoginType.Apple:
        break;
    }

    // Signs out the current user from firebase user...
    await _auth.signOut();
  }

  // Check if service is initialize or not...
  static _checkIfServiceIsInitialize() {
    if (_auth == null) {
      throw "Initialize auth serivce in main before using any serivce";
    }
  }
}
