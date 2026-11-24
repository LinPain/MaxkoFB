import 'package:http/http.dart' as http;

/// Browser transport. Browsers manage DNS themselves and do not expose custom
/// socket routing to Flutter applications.
http.Client createApiHttpClient() => http.Client();
