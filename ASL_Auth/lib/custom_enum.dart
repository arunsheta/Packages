// Auth...
enum AuthType {
  Login,
  SignUp,
  ForgotPassword,
  ChangePassword,
  UpdateProfile,
  RefreshToken,
  SetFcmToken,
  Logout,
  TermsAndCondition,
  PrivacyPolicy,
  None,
}

// Http request type...
enum HTTPRequestType {
  POST,
  GET,
  DELETE,
  PUT,
}

// Social log-in type...
enum SocialLoginType {
  Google,
  Facebook,
  Twitter,
  Apple,
  EmailPassword,
  Anonymously,
}
