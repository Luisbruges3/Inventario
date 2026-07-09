import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/visita_controller.dart';
import '../models/casa.dart';
import '../repositories/casa_repository.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casasAsync = ref.watch(casasStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
      ),
      body: casasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (casas) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: casas.length,
          itemBuilder: (context, index) {
            final casa = casas[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      casa.numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Casa ${casa.numero} — ${casa.propietario}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (casa.inquilino.isNotEmpty)
                          Text(
                            'Inquilino: ${casa.inquilino}',
                            style: const TextStyle(fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _mostrarDialogoEditar(context, casa),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEditar(BuildContext context, Casa casa) async {
    final propietarioController =
        TextEditingController(text: casa.propietario);
    final inquilinoController = TextEditingController(text: casa.inquilino);
    final emailController =
        TextEditingController(text: casa.emailPropietario);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Casa ${casa.numero}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: propietarioController,
                decoration: const InputDecoration(
                  labelText: 'Propietario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: inquilinoController,
                decoration: const InputDecoration(
                  labelText: 'Inquilino (dejar vacío si no hay)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email propietario',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final casaActualizada = Casa(
                id: casa.id,
                numero: casa.numero,
                propietario: propietarioController.text,
                inquilino: inquilinoController.text,
                emailPropietario: emailController.text,
                saldoAFavor: casa.saldoAFavor,
              );

              await CasaRepository.instance.actualizarCasa(casaActualizada);

              propietarioController.dispose();
              inquilinoController.dispose();
              emailController.dispose();

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}