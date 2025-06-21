import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../db/database.dart';
import 'license_storage.dart';

class LicenciaPage extends StatefulWidget {
  const LicenciaPage({super.key});

  @override
  State<LicenciaPage> createState() => _LicenciaPageState();
}

class _LicenciaPageState extends State<LicenciaPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _mensajeError;
  String? _mensajeExito;
  final Logger logger = Logger();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _validarLicencia() async {
    setState(() {
      _loading = true;
      _mensajeError = null;
      _mensajeExito = null;
    });

    final licencia = _controller.text.trim();

    try {
      final response = await supabase
          .from('licencias')
          .select('nombre')
          .eq('codigo', licencia)
          .limit(1)
          .maybeSingle();

      logger.d('Respuesta de Supabase: $response');

      if (response != null) {
        final nombre = response['nombre'] as String;
        await LicenseStorage.guardarLicencia(licencia, nombre);

        if (!mounted) return;

        setState(() {
          _mensajeExito = "Validación correcta. Bienvenido, $nombre";
        });

        await DatabaseHelper.inicializar(context);
      } else {
        if (mounted) {
          setState(() {
            _mensajeError = 'Licencia inválida, intenta de nuevo.';
          });
        }
      }
    } catch (e) {
      logger.e('Error de conexión con Supabase: $e');
      if (mounted) {
        setState(() {
          _mensajeError = 'Error al conectar con Supabase';
        });
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activar Licencia")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Ingrese su licencia",
              ),
            ),
            const SizedBox(height: 20),
            if (_mensajeError != null)
              Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
            if (_mensajeExito != null)
              Text(
                _mensajeExito!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _validarLicencia,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Validar"),
            ),
          ],
        ),
      ),
    );
  }
}
