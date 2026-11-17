import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/doble_model.dart';
import 'services/doble_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppDoble());
}

class AppDoble extends StatelessWidget {
  const AppDoble({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App 2 – Duplicador de Número',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEA580C),
          primary: const Color(0xFFEA580C),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEA580C),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const DobleScreen(),
    );
  }
}

class DobleScreen extends StatefulWidget {
  const DobleScreen({super.key});

  @override
  State<DobleScreen> createState() => _DobleScreenState();
}

class _DobleScreenState extends State<DobleScreen> {
  final DobleService _service = DobleService();
  final TextEditingController _numeroCtrl = TextEditingController();

  bool _cargando = false;
  DobleModel? _resultado;
  String? _error;
  List<DobleModel> _historial = [];
  bool _mostrarHistorial = false;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    final lista = await _service.getHistorial();
    if (mounted) setState(() => _historial = lista);
  }

  // =========================================================================
  // ACCIÓN PRINCIPAL: Enviar el número y recibir el doble
  // → Imprime en consola y guarda en SQLite (alarmas.db)
  // =========================================================================
  Future<void> _calcularDoble() async {
    final texto = _numeroCtrl.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Escribe un número antes de presionar el botón.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final double? numero = double.tryParse(texto);
    if (numero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Ingresa un número válido (ej. 8, 25, 14.5).'),
          backgroundColor: Colors.orange,
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
      final calculo = await _service.enviarNumero(numero);

      // IMPRESIÓN ADICIONAL DIRECTA EN CONSOLA DE FLUTTER
      // ignore: avoid_print
      print('════════════════════════════════════════════════════');
      // ignore: avoid_print
      print('>>> [CONSOLA FLUTTER – APP DOBLE] DOBLE DE UN NÚMERO:');
      // ignore: avoid_print
      print('>>> Número ingresado: $numero');
      // ignore: avoid_print
      print('>>> El doble del número es: ${calculo.resultadoDoble}');
      // ignore: avoid_print
      print('════════════════════════════════════════════════════');

      setState(() {
        _resultado = calculo;
        _cargando = false;
      });

      _cargarHistorial();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ El doble (${calculo.resultadoDoble}) fue impreso en consola y guardado en SQLite (ID #${calculo.idCalculo})'),
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
            Text('App 2 – Duplicador de Número',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('API separada → SQLite (alarmas.db)',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_mostrarHistorial ? Icons.calculate : Icons.history),
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
                color: const Color(0xFFEA580C).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEA580C).withOpacity(0.25)),
              ),
              child: Text(
                entorno,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEA580C)),
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
                              color: const Color(0xFFEA580C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.functions_rounded,
                                size: 30, color: Color(0xFFEA580C)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ingresa un número',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEA580C))),
                                Text(
                                    'Al presionar el botón se imprimirá el doble en consola y se guardará en SQLite.',
                                    style:
                                        TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Campo de texto del número
                      TextField(
                        controller: _numeroCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Número',
                          hintText: 'Ej. 7, 25, 14.5, -3...',
                          prefixIcon:
                              const Icon(Icons.pin, color: Color(0xFFEA580C)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEA580C), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _calcularDoble(),
                      ),
                      const SizedBox(height: 18),

                      // Botón principal
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: _cargando ? null : _calcularDoble,
                        icon: _cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Icon(Icons.bolt_rounded, size: 22),
                        label: Text(
                          _cargando
                              ? 'Calculando en SQLite...'
                              : 'Presionar para Calcular el Doble',
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
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange[400]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.deepOrange, size: 26),
                            const SizedBox(width: 8),
                            const Text('¡Resultado impreso en consola!',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange)),
                            const Spacer(),
                            Chip(
                              label: Text('ID #${_resultado!.idCalculo}'),
                              backgroundColor: Colors.orange[100],
                              labelStyle: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_resultado!.numeroEntrada}',
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('× 2  =',
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black54)),
                            ),
                            Text(
                              '${_resultado!.resultadoDoble}',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('🕒 ${_resultado!.fechaCreacion ?? ""}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
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
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
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
                        Icon(Icons.terminal, color: Colors.orangeAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Consola de Depuración – VS Code',
                            style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultado != null
                          ? '════════════════════════════════════\n'
                            '>>> [CONSOLA FLUTTER – APP DOBLE]\n'
                            '>>> Número ingresado: ${_resultado!.numeroEntrada}\n'
                            '>>> El doble del número es: ${_resultado!.resultadoDoble}\n'
                            '>>> ID SQLite: #${_resultado!.idCalculo}\n'
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
                    child: Text('No hay cálculos registrados todavía.',
                        style: TextStyle(color: Colors.black54)),
                  ),
                )
              else
                ..._historial.map((c) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEA580C),
                          child: Text('#${c.idCalculo ?? 0}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                        title: Text(
                          '${c.numeroEntrada}  ×  2  =  ${c.resultadoDoble}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA580C)),
                        ),
                        subtitle: Text('🕒 ${c.fechaCreacion ?? ""}',
                            style: const TextStyle(fontSize: 12)),
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}
