import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/cobro_controller.dart';
import '../models/casa.dart';
import '../models/pago.dart';
import '../services/recibo_service.dart';

class DetalleCasaScreen extends ConsumerStatefulWidget {
  final Casa casa;
  const DetalleCasaScreen({super.key, required this.casa});

  @override
  ConsumerState<DetalleCasaScreen> createState() => _DetalleCasaScreenState();
}

class _DetalleCasaScreenState extends ConsumerState<DetalleCasaScreen> {
  final formatoPrecio = NumberFormat('#,###', 'es_CO');
  final formatoFecha = DateFormat('dd/MM/yyyy HH:mm', 'es_CO');
  bool _verCobros = true;

  String _labelCategoria(String categoria) {
    switch (categoria) {
      case 'administracion':
        return 'Administración';
      case 'extraordinario':
        return 'Extraordinario';
      default:
        return 'Otros';
    }
  }

  // NUEVO: primer paso — elegir a qué categoría va el pago
  Future<void> _elegirCategoriaYPagar(List<Pago> pagosPendientes) async {
    final categoria = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('¿Qué vas a pagar?'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'administracion'),
            child: const Text('Administración'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'extraordinario'),
            child: const Text('Cuota Extraordinaria'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'otros'),
            child: const Text('Otros'),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'todos'),
            child: const Text(
              'Todos (paga lo más viejo sin importar categoría)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (categoria == null || !mounted) return;

    final esTodos = categoria == 'todos';
    final pagosFiltrados = esTodos
        ? pagosPendientes
        : pagosPendientes.where((p) => p.categoria == categoria).toList();

    await _mostrarDialogoPago(
      pagosFiltrados,
      categoriaSaldo: esTodos ? null : categoria,
    );
  }

  Future<void> _mostrarDialogoPago(
    List<Pago> pagosPendientes, {
    required String? categoriaSaldo,
  }) async {
    if (!mounted) return;

    final deudaTotal =
        pagosPendientes.fold(0.0, (sum, p) => sum + p.saldoPendiente);
    String montoTexto = '';

    final monto = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Registrar pago — Casa ${widget.casa.numero}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Propietario: ${widget.casa.propietario}'),
              if (categoriaSaldo == null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Estás pagando en modo "Todos": se pagará la deuda más antigua sin importar categoría.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Deuda ${categoriaSaldo == null ? "total" : _labelCategoria(categoriaSaldo)}: '
                '\$${formatoPrecio.format(deudaTotal)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Monto a pagar',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => montoTexto = val,
              ),
            ],
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
              onPressed: () {
                if (montoTexto.isEmpty) return;
                Navigator.pop(context, double.parse(montoTexto));
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );

    if (monto == null || !mounted) return;

    if (monto > deudaTotal) {
      final saldoAFavor = monto - deudaTotal;

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Monto mayor a la deuda'),
          content: Text(
            'El monto supera la deuda en \$${formatoPrecio.format(saldoAFavor)}. '
            '¿Registrar ese excedente como saldo a favor'
            '${categoriaSaldo == null ? "" : " de ${_labelCategoria(categoriaSaldo)}"}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, registrar'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirmar == true) {
        final detalles =
            await ref.read(cobroControllerProvider.notifier).distribuirPago(
                  casaId: widget.casa.id,
                  pagosPendientes: pagosPendientes,
                  montoPagado: monto,
                  registrarSaldoAFavor: true,
                  categoriaSaldo: categoriaSaldo,
                );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enviando recibo...')),
          );
          try {
            await ReciboService.generarYEnviarRecibo(
              casa: widget.casa,
              detalles: detalles,
              excedenteNuevo: saldoAFavor,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pago registrado con \$${formatoPrecio.format(saldoAFavor)} a favor. Recibo enviado.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Pago registrado pero error al enviar recibo: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago no registrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // Monto normal (no excede la deuda)
    final detalles =
        await ref.read(cobroControllerProvider.notifier).distribuirPago(
              casaId: widget.casa.id,
              pagosPendientes: pagosPendientes,
              montoPagado: monto,
              registrarSaldoAFavor: false,
              categoriaSaldo: categoriaSaldo,
            );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando recibo...')),
      );
      try {
        await ReciboService.generarYEnviarRecibo(
          casa: widget.casa,
          detalles: detalles,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recibo enviado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar recibo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagosAsync = ref.watch(pagosStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        title: Text(
          'Casa ${widget.casa.numero} — ${widget.casa.propietario}',
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: pagosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pagos) {
          final pagosCasa =
              pagos.where((p) => p.casaId == widget.casa.id).toList();

          final pagosPendientes = pagosCasa.where((p) => !p.pagado).toList();

          final deudaTotal = pagosPendientes.fold(
            0.0,
            (sum, p) => sum + p.saldoPendiente,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.casa.inquilino.isNotEmpty)
                        Text('Inquilino: ${widget.casa.inquilino}'),
                      Text('Email: ${widget.casa.emailPropietario}'),
                      const SizedBox(height: 8),
                      if (widget.casa.saldoAFavor > 0)
                        Text(
                          'Saldo a favor (general): \$${formatoPrecio.format(widget.casa.saldoAFavor)}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w700),
                        ),
                      if (widget.casa.saldoAFavorAdministracion > 0)
                        Text(
                          'Saldo a favor (Administración): \$${formatoPrecio.format(widget.casa.saldoAFavorAdministracion)}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w700),
                        ),
                      if (widget.casa.saldoAFavorExtraordinario > 0)
                        Text(
                          'Saldo a favor (Extraordinario): \$${formatoPrecio.format(widget.casa.saldoAFavorExtraordinario)}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w700),
                        ),
                      if (widget.casa.saldoAFavorOtros > 0)
                        Text(
                          'Saldo a favor (Otros): \$${formatoPrecio.format(widget.casa.saldoAFavorOtros)}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w700),
                        ),
                      const SizedBox(height: 4),
                      if (deudaTotal == 0)
                        const Text(
                          'Paz y salvo ✓',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        )
                      else
                        Text(
                          'Deuda total: \$${formatoPrecio.format(deudaTotal)}',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                    ],
                  ),
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
                    icon: const Icon(Icons.attach_money),
                    label: Text(pagosPendientes.isEmpty
                        ? 'Adelantar Pago'
                        : 'Registrar Pago'),
                    onPressed: () => _elegirCategoriaYPagar(pagosPendientes),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Cobros'),
                      selected: _verCobros,
                      onSelected: (val) => setState(() => _verCobros = true),
                      selectedColor: const Color(0xFF1565C0),
                      labelStyle: TextStyle(
                        color: _verCobros ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Pagos'),
                      selected: !_verCobros,
                      onSelected: (val) => setState(() => _verCobros = false),
                      selectedColor: const Color(0xFF1565C0),
                      labelStyle: TextStyle(
                        color: !_verCobros ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_verCobros) ...[
                  if (pagosCasa.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No hay cobros para esta casa',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...pagosCasa.map((pago) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  pago.pagado ? Colors.green : Colors.red,
                              child: Icon(
                                pago.pagado ? Icons.check : Icons.pending,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              pago.concepto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Valor: \$${formatoPrecio.format(pago.montoTotal)}'),
                                if (!pago.pagado && pago.montoPagado > 0)
                                  Text(
                                      'Abonado: \$${formatoPrecio.format(pago.montoPagado)}'),
                                if (!pago.pagado)
                                  Text(
                                    'Debe: \$${formatoPrecio.format(pago.saldoPendiente)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                if (pago.pagado)
                                  const Text('Paz y salvo',
                                      style: TextStyle(color: Colors.green)),
                                Text(_labelCategoria(pago.categoria),
                                    style: const TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontWeight: FontWeight.w600)),
                                if (pago.numeroRecibo != null)
                                  Text('Recibo: ${pago.numeroRecibo}'),
                                Text(formatoFecha.format(pago.fechaCobro)),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        )),
                ] else ...[
                  ...pagosCasa.map((pago) => _AbonosCard(
                        pago: pago,
                        formatoPrecio: formatoPrecio,
                        formatoFecha: formatoFecha,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AbonosCard extends ConsumerWidget {
  final Pago pago;
  final NumberFormat formatoPrecio;
  final DateFormat formatoFecha;

  const _AbonosCard({
    required this.pago,
    required this.formatoPrecio,
    required this.formatoFecha,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonosAsync = ref.watch(abonosStreamProvider(pago.id));

    return abonosAsync.when(
      loading: () => const SizedBox(),
      error: (e, _) => Text('Error: $e'),
      data: (abonos) {
        if (abonos.isEmpty) return const SizedBox();

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pago.concepto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const Divider(),
                ...abonos.map((abono) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attach_money,
                          color: Colors.green),
                      title: Text('\$${formatoPrecio.format(abono.monto)}'),
                      subtitle: Text(formatoFecha.format(abono.fecha)),
                      trailing: abono.esEditable
                          ? IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar abono'),
                                    content: const Text(
                                        '¿Estás seguro de que quieres eliminar este abono?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmar == true) {
                                  await ref
                                      .read(cobroControllerProvider.notifier)
                                      .eliminarAbono(
                                        pago: pago,
                                        abono: abono,
                                      );
                                }
                              },
                            )
                          : null,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}