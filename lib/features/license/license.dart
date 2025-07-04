import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'license_storage.dart';

class LicenciaPage extends StatefulWidget {
  const LicenciaPage({super.key});

  @override
  State<LicenciaPage> createState() => _LicenciaPageState();
}

class _LicenciaPageState extends State<LicenciaPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _mensaje;
  final Logger logger = Logger();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _validarLicencia() async {
    final codigo = _controller.text.trim();

    if (codigo.isEmpty) {
      setState(() => _mensaje = 'Por favor ingresa un código.');
      return;
    }

    setState(() {
      _loading = true;
      _mensaje = null;
    });

    try {
      final response = await supabase
          .from('licencias')
          .select('nombre')
          .eq('codigo', codigo)
          .limit(1)
          .maybeSingle();

      logger.d('Respuesta de Supabase: $response');

      if (response != null) {
        final nombre = response['nombre'] as String;
        await LicenseStorage.guardarLicencia(codigo, nombre);

        setState(() {
          _mensaje = '✅ Licencia válida. Bienvenido, $nombre.';
        });

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _mensaje = '❌ Licencia inválida. Intenta de nuevo.';
        });
      }
    } catch (e) {
      logger.e('Error al validar licencia: $e');
      setState(() {
        _mensaje = '⚠️ Error al conectar con Supabase.';
      });
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('✅ LicenciaPage build ejecutado');
    return Scaffold(
      appBar: AppBar(title: const Text("Activar Licencia")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingrese su código de licencia:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Licencia",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_mensaje != null)
              Text(
                _mensaje!,
                style: TextStyle(
                  color: _mensaje!.startsWith('✅')
                      ? Colors.green
                      : _mensaje!.startsWith('⚠️')
                      ? Colors.orange
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.verified),
                onPressed: _loading ? null : _validarLicencia,
                label: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Validar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
