/// Constantes globais do Império 022

class AppConstants {
  // API
  static const String baseUrl = 'https://imperio022-app.onrender.com';
  // Substituir pela URL real do backend quando estiver disponível
  // static const String baseUrl = 'https://seu-backend.com';

  // Colors
  static const Color primaryColor = Color(0xFFE31837);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF121212);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);

  // Fonts
  static const String displayFont = 'Space_Grotesk';
  static const String bodyFont = 'Inter';

  // Vehicle prices
  static const Map<String, double> vehiclePrices = {
    'moto': 35.0,
    'hatch': 60.0,
    'sedan': 70.0,
    'suv': 100.0,
    'truck': 120.0,
    'other': 80.0,
  };

  // Loyalty
  static const int loyaltyMaxWashes = 7;
}
