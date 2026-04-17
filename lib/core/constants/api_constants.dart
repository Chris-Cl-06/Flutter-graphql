import 'dart:io'; // Importante para detectar la plataforma
import 'package:flutter/foundation.dart' show kIsWeb; // Importante

class ApiConstants {
  ApiConstants._();

  static String get tasksGraphqlEndpoint {
    
     if (kIsWeb) {
      return 'http://localhost:8080/graphql';
    }
     if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/graphql';
    }

    return 'http://localhost:8080/graphql';  
  }
}
