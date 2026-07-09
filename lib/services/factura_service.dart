import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/factura.dart';
import '../repositories/factura_repository.dart';
import 'contador_service.dart';
import '../config/api_keys.dart';

class FacturaService {
  static const String _apiKey = ApiKeys.sendGrid;

  static final formatoPrecio = NumberFormat('#,###', 'es_CO');
  static final formatoFecha = DateFormat('dd/MM/yyyy', 'es_CO');

  static Future<void> generarYEnviarFactura({
    required String trabajador,
    required String emailTrabajador,
    required String concepto,
    required double valor,
  }) async {
    final numeroFactura = await ContadorService.generarNumero();

    final configDoc = await FirebaseFirestore.instance
        .collection('config')
        .doc('administracion')
        .get();
    final config = configDoc.data()!;
    final adminNombre = config['nombre'] ?? 'Administradora';
    final adminEmail = config['email'] ?? '';
    final adminTelefono = config['telefono'] ?? '';

    final fecha = formatoFecha.format(DateTime.now());

    final facturaRef = FirebaseFirestore.instance.collection('facturas').doc();
    final factura = Factura(
      id: facturaRef.id,
      numero: numeroFactura,
      trabajador: trabajador,
      emailTrabajador: emailTrabajador,
      concepto: concepto,
      valor: valor,
      fecha: DateTime.now(),
    );
    await FacturaRepository.instance.guardarFactura(factura);

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
                          'Conjunto Residencial App Oasis',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text('FACTURA DE PAGO A TERCEROS',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        numeroFactura,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text('Fecha: $fecha',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),

              _campo('Pagado a', trabajador),
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
                      _celda('Concepto', esEncabezado: true),
                      _celda('Valor', esEncabezado: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _celda(concepto),
                      _celda('\$${formatoPrecio.format(valor)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: \$${formatoPrecio.format(valor)}',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 24),

              pw.Text(
                'La administración del Conjunto Residencial App Oasis certifica '
                'haber realizado el pago a $trabajador por concepto de '
                '$concepto, por un valor de \$${formatoPrecio.format(valor)} '
                'pesos colombianos, con fecha $fecha, correspondiente a la '
                'factura No. $numeroFactura.',
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
                  'Conjunto Residencial App Oasis  ·  Tel: $adminTelefono  ·  $adminEmail',
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
    final fechaArchivo = fecha.replaceAll('/', '-');

    final destinatarios = <Map<String, String>>[
      {'email': emailTrabajador, 'name': trabajador},
      if (adminEmail != emailTrabajador)
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
              'subject': 'Factura $numeroFactura — $concepto',
            }
          ],
          'from': {'email': adminEmail, 'name': 'App Oasis'},
          'reply_to': {'email': adminEmail, 'name': adminNombre},
          'content': [
            {
              'type': 'text/html',
              'value': '''
                <p>Estimado(a) $trabajador,</p>
                <p>Adjunto encontrará la factura <strong>$numeroFactura</strong> 
                correspondiente a <strong>$concepto</strong> por un valor de 
                <strong>\$${formatoPrecio.format(valor)}</strong>.</p>
                <p>Fecha de pago: $fecha</p>
                <p>Atentamente,<br>$adminNombre<br>Administradora<br>
                Conjunto Residencial App Oasis</p>
              ''',
            }
          ],
          'attachments': [
            {
              'content': pdfBase64,
              'filename': '${numeroFactura}_$fechaArchivo.pdf',
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

  static pw.Widget _campo(String label, String valor) {
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

  static pw.Widget _celda(String texto, {bool esEncabezado = false}) {
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