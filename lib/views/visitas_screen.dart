import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/visita_controller.dart';
import '../models/casa.dart';

class VisitasScreen extends ConsumerStatefulWidget {
  const VisitasScreen({super.key});

  @override
  ConsumerState<VisitasScreen> createState() => _VisitasScreenState();
}

class _VisitasScreenState extends ConsumerState<VisitasScreen> {
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  Casa? _casaSeleccionada;
  final _formatoFecha = DateFormat('dd/MM/yyyy HH:mm', 'es_CO');

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _registrarVisita() async {
    if (_casaSeleccionada == null ||
        _cedulaController.text.isEmpty ||
        _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    await ref.read(visitaControllerProvider.notifier).registrarVisita(
          casa: _casaSeleccionada!,
          cedulaVisitante: _cedulaController.text,
          nombreVisitante: _nombreController.text,
        );

    setState(() {
      _casaSeleccionada = null;
      _cedulaController.clear();
      _nombreController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita registrada exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final casasAsync = ref.watch(casasStreamProvider);
    final visitasAsync = ref.watch(visitasStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulario de registro
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrar Visita',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown de casas
                casasAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (casas) => DropdownButtonFormField<Casa>(
                    value: _casaSeleccionada,
                    hint: const Text('Selecciona una casa'),
                    decoration: const InputDecoration(
                      labelText: 'Casa',
                      border: OutlineInputBorder(),
                    ),
                    items: casas.map((casa) {
                      return DropdownMenuItem<Casa>(
                        value: casa,
                        child: Text('Casa ${casa.numero}'),
                      );
                    }).toList(),
                    onChanged: (casa) => setState(() => _casaSeleccionada = casa),
                  ),
                ),

                const SizedBox(height: 12),

                // Residente que aparece al seleccionar casa
                if (_casaSeleccionada != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Residente: ${_casaSeleccionada!.residente}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Cédula visitante
                TextFormField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Cédula del visitante',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // Nombre visitante
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del visitante',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Fecha automática
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Fecha: ${_formatoFecha.format(DateTime.now())}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1565C0)),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _registrarVisita,
                    child: const Text('Registrar Visita'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Historial de visitas
          const Text(
            'Historial de Visitas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
            ),
          ),

          const SizedBox(height: 12),

          visitasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (visitas) {
              if (visitas.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay visitas registradas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visitas.length,
                itemBuilder: (context, index) {
                  final visita = visitas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1565C0),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        visita.nombreVisitante,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cédula: ${visita.cedulaVisitante}'),
                          Text('Casa ${visita.casaNumero} — ${visita.residente}'),
                          Text(_formatoFecha.format(visita.fecha)),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}