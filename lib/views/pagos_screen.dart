import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/visita_controller.dart';
import '../controllers/cobro_controller.dart';
import 'detalle_casa_screen.dart';

class PagosScreen extends ConsumerWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatoPrecio = NumberFormat('#,###', 'es_CO');
    final casasAsync = ref.watch(casasStreamProvider);
    final pagosAsync = ref.watch(pagosStreamProvider);

    return casasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (casas) => pagosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pagos) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: casas.length,
            itemBuilder: (context, index) {
              final casa = casas[index];

              // Obtener todos los pagos pendientes de esta casa
              final pagosPendientesCasa = pagos
                  .where((p) => p.casaId == casa.id && !p.pagado)
                  .toList();

              // Calcular deuda total de la casa
              final deudaTotal = pagosPendientesCasa.fold(
                0.0,
                (sum, p) => sum + p.saldoPendiente,
              );

              final estaAlDia = deudaTotal == 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  dense: false,
                  minVerticalPadding: 12,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleCasaScreen(casa: casa),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: estaAlDia ? Colors.green : Colors.red,
                    child: Text(
                      casa.numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    'Casa ${casa.numero} — ${casa.propietario}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    estaAlDia
                        ? casa.saldoAFavor > 0
                            ? 'Paz y salvo · A favor: \$${formatoPrecio.format(casa.saldoAFavor)}'
                            : 'Paz y salvo'
                        : 'Deuda: \$${formatoPrecio.format(deudaTotal)}',
                    style: TextStyle(
                      color: estaAlDia ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}