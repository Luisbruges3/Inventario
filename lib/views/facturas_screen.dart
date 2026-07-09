import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/factura_controller.dart';
import '../services/factura_service.dart';

class FacturasScreen extends ConsumerStatefulWidget {
  const FacturasScreen({super.key});

  @override
  ConsumerState<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends ConsumerState<FacturasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trabajadorController = TextEditingController();
  final _emailController = TextEditingController();
  final _conceptoController = TextEditingController();
  final _valorController = TextEditingController();
  bool _enviando = false;

  final formatoPrecio = NumberFormat('#,###', 'es_CO');
  final formatoFecha = DateFormat('dd/MM/yyyy HH:mm', 'es_CO');

  @override
  void dispose() {
    _trabajadorController.dispose();
    _emailController.dispose();
    _conceptoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _generarFactura() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    try {
      await FacturaService.generarYEnviarFactura(
        trabajador: _trabajadorController.text.trim(),
        emailTrabajador: _emailController.text.trim(),
        concepto: _conceptoController.text.trim(),
        valor: double.parse(_valorController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Factura generada y enviada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _trabajadorController.clear();
        _emailController.clear();
        _conceptoController.clear();
        _valorController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar factura: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final facturasAsync = ref.watch(facturasStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        title: const Text(
          'Facturas',
          style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nueva factura a trabajador externo',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trabajadorController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del trabajador',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo del trabajador',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (!val.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conceptoController,
                      decoration: const InputDecoration(
                        labelText: 'Concepto (ej. Mantenimiento de jardines)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _valorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Valor a pagar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: _enviando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_enviando
                            ? 'Generando y enviando...'
                            : 'Generar y Enviar Factura'),
                        onPressed: _enviando ? null : _generarFactura,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Historial de facturas',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),

            facturasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (facturas) {
                if (facturas.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Aún no hay facturas generadas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  children: facturas.map((factura) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1565C0),
                          child: Icon(Icons.request_page,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(
                          factura.numero,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${factura.trabajador}\n'
                          '${factura.concepto} · ${formatoFecha.format(factura.fecha)}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          '\$${formatoPrecio.format(factura.valor)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}