import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/saludo_model.dart';
import 'services/saludo_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppSaludo());
}

class AppSaludo extends StatelessWidget {
  const AppSaludo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App 1 – Saludo Personalizado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
          primary: const Color(0xFF003366),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const SaludoScreen(),
    );
  }
}

class SaludoScreen extends StatefulWidget {
  const SaludoScreen({super.key});

  @override
  State<SaludoScreen> createState() => _SaludoScreenState();
}

class _SaludoScreenState extends State<SaludoScreen> {
  final SaludoService _service = SaludoService();
  final TextEditingController _nombreCtrl = TextEditingController();

  bool _cargando = false;
  SaludoModel? _resultado;
  String? _error;
  List<SaludoModel> _historial = [];
  bool _mostrarHistorial = false;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    final lista = await _service.getHistorial();
    if (mounted) setState(() => _historial = lista);
  }

  // =========================================================================
  // ACCIÓN PRINCIPAL: Enviar el nombre y recibir el saludo personalizado
  // → Imprime en consola y guarda en SQLite (alarmas.db)
  // =========================================================================
  Future<void> _saludar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Escribe tu nombre antes de presionar el botón.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _resultado = null;
    });

    try {
      final saludo = await _service.enviarNombre(nombre);

      // IMPRESIÓN ADICIONAL DIRECTA EN CONSOLA DE FLUTTER
      // ignore: avoid_print
      print('════════════════════════════════════════════════════');
      // ignore: avoid_print
      print('>>> [CONSOLA FLUTTER – APP SALUDO] SALUDO PERSONALIZADO:');
      // ignore: avoid_print
      print('>>> ${saludo.mensajeSaludo}');
      // ignore: avoid_print
      print('════════════════════════════════════════════════════');

      setState(() {
        _resultado = saludo;
        _cargando = false;
      });

      _cargarHistorial();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Saludo impreso en consola y guardado en SQLite (ID #${saludo.idSaludo})'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entorno = kIsWeb
        ? '🌐 Google Chrome  |  localhost:5238'
        : '📱 Emulador Android API 28  |  10.0.2.2:5238';

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('App 1 – Saludo Personalizado',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('API separada → SQLite (alarmas.db)',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_mostrarHistorial ? Icons.person : Icons.history),
            tooltip: _mostrarHistorial ? 'Formulario' : 'Historial SQLite',
            onPressed: () {
              setState(() => _mostrarHistorial = !_mostrarHistorial);
              if (_mostrarHistorial) _cargarHistorial();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarHistorial,
            tooltip: 'Refrescar historial',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de entorno
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF003366).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF003366).withOpacity(0.2)),
              ),
              child: Text(
                entorno,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF003366)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            if (!_mostrarHistorial) ...[
              // ── FORMULARIO ──────────────────────────────────────────────
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003366).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.waving_hand_rounded,
                                size: 30, color: Color(0xFF003366)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ingresa tu nombre',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003366))),
                                Text(
                                    'Al presionar el botón se imprimirá en consola y se guardará en SQLite.',
                                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Campo de texto del nombre
                      TextField(
                        controller: _nombreCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ej. Carlos, María, Juan...',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF003366)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF003366), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _saludar(),
                      ),
                      const SizedBox(height: 18),

                      // Botón principal
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: _cargando ? null : _saludar,
                        icon: _cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Icon(Icons.send_rounded, size: 22),
                        label: Text(
                          _cargando
                              ? 'Guardando en SQLite...'
                              : 'Presionar para Saludar',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── RESULTADO ───────────────────────────────────────────────
              if (_resultado != null)
                Card(
                  elevation: 4,
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.green[400]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 26),
                            const SizedBox(width: 8),
                            const Text('¡Saludo impreso en consola!',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            const Spacer(),
                            Chip(
                              label: Text('ID #${_resultado!.idSaludo}'),
                              backgroundColor: Colors.green[100],
                              labelStyle: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _resultado!.mensajeSaludo,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003366)),
                        ),
                        const SizedBox(height: 8),
                        Text('🕒 ${_resultado!.fechaCreacion ?? ""}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),

              if (_error != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── CONSOLA VISUALIZADOR ─────────────────────────────────────
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Consola de Depuración – VS Code',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultado != null
                          ? '════════════════════════════════════\n'
                            '>>> [CONSOLA FLUTTER – APP SALUDO]\n'
                            '>>> ${_resultado!.mensajeSaludo}\n'
                            '>>> ID SQLite: #${_resultado!.idSaludo}\n'
                            '════════════════════════════════════'
                          : '>>> Esperando que presiones el botón...',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── HISTORIAL SQLite ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('📋 Historial en SQLite (${_historial.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _cargarHistorial,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_historial.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No hay saludos registrados todavía.',
                        style: TextStyle(color: Colors.black54)),
                  ),
                )
              else
                ..._historial.map((s) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF003366),
                          child: Text('#${s.idSaludo ?? 0}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                        title: Text(s.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${s.mensajeSaludo}\n🕒 ${s.fechaCreacion ?? ""}',
                            style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}
