/// Uygulama yapılandırma ayarları
class AppConfig {
  // Build time'da --dart-define ile set edilecek
  // Örnek: flutter build web --dart-define=API_BASE_URL=https://your-backend.railway.app
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  
  static const String apiVersion = '/api/v1';
  
  /// Tam API endpoint URL'i
  static String get fullApiUrl => '$apiBaseUrl$apiVersion';
  
  /// Debug mode kontrolü
  static bool get isProduction => apiBaseUrl.contains('railway.app') || 
                                   apiBaseUrl.contains('herokuapp.com') ||
                                   apiBaseUrl.contains('render.com');
}
