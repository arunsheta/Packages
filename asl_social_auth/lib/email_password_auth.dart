part of asl_social_auth;

// SignIn with email-password...
Future<User> _signInWithEmailPassword({
  @required String email,
  @required String password,
}) async {
  try {
    // Get user credential...
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

// SignUp with email-password...
Future<User> _signUpWithEmailPassword({
  @required String email,
  @required String password,
}) async {
  try {
    UserCredential userCredential =
        await SocialLoginService._auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // print(await userCredential.user.getIdToken(true));
    // Authenticate user with firebase...
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    String msg = e?.message ?? "Something went wrong";

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
    throw Exception(error?.toString() ?? "Something went wrong");
  }
}

/// Send forgot password link for email login...
Future<void> forgotPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } catch (e) {
    throw e;
  }
}

// Anoymous SignIn (Guest SignIn)...
Future<User> _signInAnoymously() async {
  UserCredential userCredential =
      await SocialLoginService._auth.signInAnonymously();
  return userCredential.user;
}
