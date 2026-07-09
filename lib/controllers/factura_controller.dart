import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/factura.dart';
import '../repositories/factura_repository.dart';

final facturasStreamProvider = StreamProvider<List<Factura>>((ref) {
  return FacturaRepository.instance.getFacturas();
});