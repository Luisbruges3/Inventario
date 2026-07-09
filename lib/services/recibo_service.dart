import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/casa.dart';
import '../models/detalle_pago.dart';
import '../repositories/cobro_repository.dart';
import 'contador_service.dart';
import '../config/api_keys.dart';

class ReciboService {
  static const String _apiKey = ApiKeys.sendGrid;

  static final formatoPrecio = NumberFormat('#,###', 'es_CO');
  static final formatoFecha = DateFormat('dd/MM/yyyy', 'es_CO');

  static Future<void> generarYEnviarRecibo({
    required Casa casa,
    required List<DetallePago> detalles,
    double excedenteNuevo = 0, // NUEVO: cuando el pago fue mayor a la deuda
    double saldoPendienteRestante = 0, // NUEVO: cuando se usó saldo existente y no alcanzó
    bool cubiertoConSaldoExistente = false, // NUEVO: marca este caso especial
  }) async {
    final montoConceptos = detalles.fold(0.0, (sum, d) => sum + d.monto);
    final montoTotal = montoConceptos + excedenteNuevo;

    final numeroRecibo = await ContadorService.generarNumero();

    final configDoc = await FirebaseFirestore.instance
        .collection('config')
        .doc('administracion')
        .get();
    final config = configDoc.data()!;
    final adminNombre = config['nombre'] ?? 'Administradora';
    final adminEmail = config['email'] ?? '';
    final adminTelefono = config['telefono'] ?? '';

    final fechaPago = formatoFecha.format(DateTime.now());

    await CobroRepository.instance.asignarNumeroRecibo(
      pagoIds: detalles.map((d) => d.pagoId).toList(),
      numeroRecibo: numeroRecibo,
    );

    final logo = await _cargarImagen('assets/icon.png');
    final firma = await _cargarImagen('assets/firma.png');

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(logo, height: 55),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Conjunto Residencial El Oasis',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text('RECIBO DE PAGO',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        numeroRecibo,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text('Fecha: $fechaPago',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),

              _campoRecibo('Casa', casa.numero),
              _campoRecibo('Propietario', casa.propietario),
              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                    children: [
                      _celdaTabla('Concepto', esEncabezado: true),
                      _celdaTabla('Valor', esEncabezado: true),
                    ],
                  ),
                  for (final d in detalles)
                    pw.TableRow(
                      children: [
                        _celdaTabla(d.concepto),
                        _celdaTabla('\$${formatoPrecio.format(d.monto)}'),
                      ],
                    ),
                  // NUEVO: fila de excedente, solo si aplica
                  if (excedenteNuevo > 0)
                    pw.TableRow(
                      children: [
                        _celdaTabla('Saldo a favor (para próximo cobro)'),
                        _celdaTabla('\$${formatoPrecio.format(excedenteNuevo)}'),
                      ],
                    ),
                ],
              ),

              if (cubiertoConSaldoExistente)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text(
                    '* Este cobro fue cubierto utilizando el saldo a favor '
                    'que tenía el propietario.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),

              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: \$${formatoPrecio.format(montoTotal)}',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              // NUEVO: aviso de saldo pendiente cuando se usó saldo existente y no alcanzó
              if (cubiertoConSaldoExistente && saldoPendienteRestante > 0) ...[
                pw.SizedBox(height: 6),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Saldo pendiente restante: \$${formatoPrecio.format(saldoPendienteRestante)}',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.red),
                  ),
                ),
              ],
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 24),

              pw.Text(
                cubiertoConSaldoExistente
                    ? 'La administración del Conjunto Residencial El Oasis certifica '
                        'que se aplicó saldo a favor del propietario de la Casa No. ${casa.numero}, '
                        'señor(a) ${casa.propietario}, por un valor de '
                        '\$${formatoPrecio.format(montoConceptos)} pesos colombianos, '
                        'con fecha $fechaPago, correspondiente al recibo No. $numeroRecibo.'
                        '${saldoPendienteRestante > 0 ? ' Queda un saldo pendiente por pagar de \$${formatoPrecio.format(saldoPendienteRestante)} por este concepto.' : ''}'
                    : 'La administración del Conjunto Residencial El Oasis certifica '
                        'haber recibido el pago de ${casa.propietario}, propietario(a) de '
                        'la Casa ${casa.numero}, por un valor de '
                        '\$${formatoPrecio.format(montoTotal)} pesos colombianos, '
                        'con fecha $fechaPago, correspondiente al recibo No. $numeroRecibo.',
                style: const pw.TextStyle(fontSize: 11),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 36),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(firma, height: 55),
                  pw.Container(
                    width: 180,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(width: 1)),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(adminNombre,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Administradora',
                      style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.Spacer(),

              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Conjunto Residencial El Oasis  ·  Tel: $adminTelefono  ·  $adminEmail',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final pdfBase64 = base64Encode(pdfBytes);
    final fechaArchivo = fechaPago.replaceAll('/', '-');

    final destinatarios = <Map<String, String>>[
      {'email': casa.emailPropietario, 'name': casa.propietario},
      if (adminEmail != casa.emailPropietario)
        {'email': adminEmail, 'name': adminNombre},
    ];

    for (final destinatario in destinatarios) {
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [destinatario],
              'subject': 'Recibo $numeroRecibo — Casa ${casa.numero}',
            }
          ],
          'from': {'email': adminEmail, 'name': 'App Oasis'},
          'reply_to': {'email': adminEmail, 'name': adminNombre},
          'content': [
            {
              'type': 'text/html',
              'value': '''
                <p>Estimado(a) ${casa.propietario},</p>
                <p>Adjunto encontrará el recibo <strong>$numeroRecibo</strong> 
                por un valor de <strong>\$${formatoPrecio.format(montoTotal)}</strong>.</p>
                ${cubiertoConSaldoExistente && saldoPendienteRestante > 0 ? '<p>Nota: aún queda un saldo pendiente de <strong>\$${formatoPrecio.format(saldoPendienteRestante)}</strong> por este concepto.</p>' : ''}
                <p>Fecha: $fechaPago</p>
                <p>Atentamente,<br>$adminNombre<br>Administradora<br>
                Conjunto Residencial App Oasis</p>
              ''',
            }
          ],
          'attachments': [
            {
              'content': pdfBase64,
              'filename': '${numeroRecibo}_casa${casa.numero}_$fechaArchivo.pdf',
              'type': 'application/pdf',
              'disposition': 'attachment',
            },
          ],
        }),
      );

      if (response.statusCode != 202) {
        throw Exception('Error al enviar correo: ${response.body}');
      }
    }
  }

  static Future<pw.MemoryImage> _cargarImagen(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  static pw.Widget _campoRecibo(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text('$label: ',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(valor, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _celdaTabla(String texto, {bool esEncabezado = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: esEncabezado ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: esEncabezado ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }
}