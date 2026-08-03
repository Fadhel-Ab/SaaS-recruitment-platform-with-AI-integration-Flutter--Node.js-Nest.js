class ApiConstants {
  //static const String baseUrl = 'http://10.0.2.2:3000';
  static const String baseUrl =
      "https://saas-recruitment-platform-with-ai-integration-fl-production.up.railway.app/api";

  static const String login = '/auth/login';

  static const String register = '/auth/register';

  /// The backend serves static files (resumes, etc.) outside the `/api`
  /// prefix, so links to them need the origin without that suffix.
  static String get serverOrigin =>
      baseUrl.endsWith('/api')
          ? baseUrl.substring(0, baseUrl.length - '/api'.length)
          : baseUrl;
}
