import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saludo_model.dart';

class SaludoService {
  /// URL base según el entorno:
  /// - Google Chrome → localhost:5238
  /// - Emulador Android API 28 → 10.0.2.2:5238
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5238';
    return 'http://10.0.2.2:5238';
  }

  /// POST /api/saludo
  /// Envía el nombre, el servidor imprime el saludo en consola y lo guarda en SQLite.
  Future<SaludoModel> enviarNombre(String nombre) async {
    final url = Uri.parse('$baseUrl/api/saludo');

    // ► IMPRESIÓN EN CONSOLA DE FLUTTER (pestaña Debug Console en VS Code)
    debugPrint('══════════════════════════════════════════════════════');
    debugPrint('[APP SALUDO] Enviando nombre a la API (puerto 5238)');
    debugPrint('[APP SALUDO] Nombre ingresado : "$nombre"');
    debugPrint('[APP SALUDO] URL destino      : $url');

    final response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'nombre': nombre}))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final saludo = SaludoModel.fromJson(data);

      // ► RESULTADO EN CONSOLA DE FLUTTER
      debugPrint('[APP SALUDO] ✅ SALUDO PERSONALIZADO:');
      debugPrint('[APP SALUDO] >>> ${saludo.mensajeSaludo}');
      debugPrint('[APP SALUDO] Guardado en SQLite (alarmas.db) con ID #${saludo.idSaludo}');
      debugPrint('══════════════════════════════════════════════════════');

      return saludo;
    }

    debugPrint('[APP SALUDO] ❌ Error HTTP ${response.statusCode}: ${response.body}');
    debugPrint('══════════════════════════════════════════════════════');
    throw Exception('Error en API Saludo (${response.statusCode}): ${response.body}');
  }

  /// GET /api/saludo — historial guardado en SQLite
  Future<List<SaludoModel>> getHistorial() async {
    try {
      final r = await http
          .get(Uri.parse('$baseUrl/api/saludo'))
          .timeout(const Duration(seconds: 6));
      if (r.statusCode == 200) {
        return (jsonDecode(r.body) as List)
            .map((e) => SaludoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
