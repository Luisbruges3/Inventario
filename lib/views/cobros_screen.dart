import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/cobro_controller.dart';
import '../controllers/visita_controller.dart';
import '../models/casa.dart';

class CobrosScreen extends ConsumerStatefulWidget {
  const CobrosScreen({super.key});

  @override
  ConsumerState<CobrosScreen> createState() => _CobrosScreenState();
}

class _CobrosScreenState extends ConsumerState<CobrosScreen> {
  final formatoPrecio = NumberFormat('#,###', 'es_CO');
  final formatoFecha = DateFormat('dd/MM/yyyy', 'es_CO');

  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  bool _esMasivo = true;
  bool? _filtroMasivo;
  Casa? _casaSeleccionada;

  String _categoria = 'administracion'; // NUEVO
  String _mesSeleccionado = _meses[DateTime.now().month - 1]; // NUEVO

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  // NUEVO: arma el concepto final según la categoría elegida
  String _obtenerConcepto() {
    if (_categoria == 'administracion') {
      return 'Administración $_mesSeleccionado';
    }
    return _conceptoController.text;
  }

  Future<void> _crearCobro(List<Casa> casas) async {
    final casaParaCobro = _casaSeleccionada;
    setState(() => _casaSeleccionada = null);

    final esAdministracion = _categoria == 'administracion';

    if (!esAdministracion && _conceptoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena el concepto')),
      );
      return;
    }

    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena el monto')),
      );
      return;
    }

    if (!_esMasivo && casaParaCobro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una casa')),
      );
      return;
    }

    final monto = double.parse(_montoController.text);
    final concepto = _obtenerConcepto();
    final mes = esAdministracion
        ? '$_mesSeleccionado ${DateTime.now().year}'
        : null;

    if (_esMasivo) {
      await ref.read(cobroControllerProvider.notifier).crearCobroMasivo(
            concepto: concepto,
            montoTotal: monto,
            casas: casas,
            categoria: _categoria,
            mes: mes,
          );
    } else {
      await ref.read(cobroControllerProvider.notifier).crearCobroIndividual(
            concepto: concepto,
            montoTotal: monto,
            casa: casaParaCobro!,
            categoria: _categoria,
            mes: mes,
          );
    }

    setState(() {
      _conceptoController.clear();
      _montoController.clear();
      _esMasivo = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cobro creado exitosamente')),
      );
    }
  }

  // NUEVO: helper visual para etiquetas de categoría en el historial
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

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'administracion':
        return const Color(0xFF1565C0);
      case 'extraordinario':
        return Colors.deepPurple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final casasAsync = ref.watch(casasStreamProvider);
    final cobrosAsync = ref.watch(cobrosStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          casasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (casas) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear Cobro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NUEVO: selector de categoría
                  const Text(
                    'Categoría',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('Administración'),
                        selected: _categoria == 'administracion',
                        onSelected: (val) =>
                            setState(() => _categoria = 'administracion'),
                        selectedColor: const Color(0xFF1565C0),
                        labelStyle: TextStyle(
                          color: _categoria == 'administracion'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Extraordinario'),
                        selected: _categoria == 'extraordinario',
                        onSelected: (val) =>
                            setState(() => _categoria = 'extraordinario'),
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: _categoria == 'extraordinario'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Otros'),
                        selected: _categoria == 'otros',
                        onSelected: (val) =>
                            setState(() => _categoria = 'otros'),
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: _categoria == 'otros'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // NUEVO: si es Administración, dropdown de mes en vez de concepto libre
                  if (_categoria == 'administracion') ...[
                    DropdownButtonFormField<String>(
                      value: _mesSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '¿Qué mes vas a cobrar?',
                        border: OutlineInputBorder(),
                      ),
                      items: _meses.map((mes) {
                        return DropdownMenuItem(value: mes, child: Text(mes));
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _mesSeleccionado = val!),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _conceptoController,
                      decoration: const InputDecoration(
                        labelText: 'Concepto',
                        hintText: 'Ej: Cuota extraordinaria portón',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      const Text(
                        'Tipo de cobro',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Masivo'),
                            selected: _esMasivo,
                            onSelected: (val) => setState(() {
                              _esMasivo = true;
                              _casaSeleccionada = null;
                            }),
                            selectedColor: const Color(0xFF1565C0),
                            labelStyle: TextStyle(
                              color: _esMasivo ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('Individual'),
                            selected: !_esMasivo,
                            onSelected: (val) =>
                                setState(() => _esMasivo = false),
                            selectedColor: const Color(0xFF1565C0),
                            labelStyle: TextStyle(
                              color: !_esMasivo ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_esMasivo) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Casa>(
                      value: _casaSeleccionada,
                      hint: const Text('Selecciona una casa'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Casa',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      itemHeight: 48,
                      items: casas.map((casa) {
                        return DropdownMenuItem<Casa>(
                          value: casa,
                          child: Text(
                            'Casa ${casa.numero} — ${casa.propietario}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (casa) => setState(() => _casaSeleccionada = casa),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _crearCobro(casas),
                      child: const Text('Crear Cobro'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Historial de Cobros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filtroMasivo == null,
                    onSelected: (val) => setState(() => _filtroMasivo = null),
                    selectedColor: const Color(0xFF1565C0),
                    labelStyle: TextStyle(
                      color: _filtroMasivo == null ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Masivo'),
                    selected: _filtroMasivo == true,
                    onSelected: (val) => setState(() => _filtroMasivo = true),
                    selectedColor: const Color(0xFF1565C0),
                    labelStyle: TextStyle(
                      color: _filtroMasivo == true ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Individual'),
                    selected: _filtroMasivo == false,
                    onSelected: (val) => setState(() => _filtroMasivo = false),
                    selectedColor: const Color(0xFF1565C0),
                    labelStyle: TextStyle(
                      color: _filtroMasivo == false ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          cobrosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (cobros) {
              final cobrosFiltrados = _filtroMasivo == null
                  ? cobros
                  : cobros.where((c) => c.esMasivo == _filtroMasivo).toList();

              if (cobrosFiltrados.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay cobros registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cobrosFiltrados.length,
                itemBuilder: (context, index) {
                  final cobro = cobrosFiltrados[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1565C0),
                        child: Icon(
                          cobro.esMasivo ? Icons.group : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        cobro.concepto,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monto: \$${formatoPrecio.format(cobro.montoTotal)}'),
                          Text('Fecha: ${formatoFecha.format(cobro.fecha)}'),
                          Row(
                            children: [
                              Text(
                                cobro.esMasivo
                                    ? 'Masivo'
                                    : 'Individual — Casa ${cobro.casaNumero ?? ''}',
                                style: TextStyle(
                                  color: cobro.esMasivo
                                      ? const Color(0xFF1565C0)
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(' · '),
                              Text(
                                _labelCategoria(cobro.categoria), // NUEVO
                                style: TextStyle(
                                  color: _colorCategoria(cobro.categoria),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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