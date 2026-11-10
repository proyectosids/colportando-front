final class AppConfig {
  AppConfig({
    required this.apiBaseUri,
    this.requestTimeout = const Duration(seconds: 20),
  }) {
    if (!apiBaseUri.hasScheme || !apiBaseUri.path.endsWith('/')) {
      throw ArgumentError.value(
        apiBaseUri,
        'apiBaseUri',
        'Debe ser una URL absoluta que termine en /.',
      );
    }
  }

  factory AppConfig.fromEnvironment() {
    const rawBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://colportando-app.apps.isdapps.uk/api/v1/',
    );
    return AppConfig(apiBaseUri: Uri.parse(rawBaseUrl));
  }

  final Uri apiBaseUri;
  final Duration requestTimeout;
}
