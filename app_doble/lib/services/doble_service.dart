import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/doble_model.dart';

class DobleService {
  /// URL base según el entorno:
  /// - Google Chrome → localhost:5238
  /// - Emulador Android API 28 → 10.0.2.2:5238
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5238';
    return 'http://10.0.2.2:5238';
  }

  /// POST /api/doble
  /// Envía el número, el servidor calcula el doble, imprime en consola y guarda en SQLite.
  Future<DobleModel> enviarNumero(double numero) async {
    final url = Uri.parse('$baseUrl/api/doble');

    // ► IMPRESIÓN EN CONSOLA DE FLUTTER (pestaña Debug Console en VS Code)
    debugPrint('══════════════════════════════════════════════════════');
    debugPrint('[APP DOBLE] Enviando número a la API (puerto 5238)');
    debugPrint('[APP DOBLE] Número ingresado : $numero');
    debugPrint('[APP DOBLE] Cálculo local    : $numero × 2 = ${numero * 2}');
    debugPrint('[APP DOBLE] URL destino      : $url');

    final response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'numero': numero}))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final calculo = DobleModel.fromJson(data);

      // ► RESULTADO EN CONSOLA DE FLUTTER
      debugPrint('[APP DOBLE] ✅ EL DOBLE DE $numero ES: ${calculo.resultadoDoble}');
      debugPrint('[APP DOBLE] Guardado en SQLite (alarmas.db) con ID #${calculo.idCalculo}');
      debugPrint('══════════════════════════════════════════════════════');

      return calculo;
    }

    debugPrint('[APP DOBLE] ❌ Error HTTP ${response.statusCode}: ${response.body}');
    debugPrint('══════════════════════════════════════════════════════');
    throw Exception('Error en API Doble (${response.statusCode}): ${response.body}');
  }

  /// GET /api/doble — historial guardado en SQLite
  Future<List<DobleModel>> getHistorial() async {
    try {
      final r = await http
          .get(Uri.parse('$baseUrl/api/doble'))
          .timeout(const Duration(seconds: 6));
      if (r.statusCode == 200) {
        return (jsonDecode(r.body) as List)
            .map((e) => DobleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
