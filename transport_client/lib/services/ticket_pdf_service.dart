import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../utils/qr_payload.dart';

class TicketPdfService {
  static final _success = PdfColor.fromInt(0xFF16A34A);
  static final _warning = PdfColor.fromInt(0xFFF59E0B);
  static final _primary = PdfColor.fromInt(0xFF1E5EFF);
  static final _grey700 = PdfColor.fromInt(0xFF4A4A4A);
  static final _border = PdfColor.fromInt(0xFFE2E4EA);

  // Dimensions personnalisées du billet (pas un format papier standard)
  static const double _cardWidth = 210;
  static const double _cardHeight = 370;
  static const double _margeExterne = 15;


  // concernant l'expiration de billet

  static bool _estExpire(Reservation reservation) {
  final finValidite = reservation.trajet.heureDepart.add(const Duration(hours: 24));
  return DateTime.now().isAfter(finValidite);
  }

  static Future<void> imprimerBillet({
    required Reservation reservation,
    required String nomPassager,
  }) async {
    final doc = pw.Document();
    final t = reservation.trajet;
    final confirmee = reservation.statut.toLowerCase() == 'confirmee';
    final qrData = buildQrPayload(reservation, nomPassager);

    final expire = _estExpire(reservation);

    final pageFormat = PdfPageFormat(
      _cardWidth + _margeExterne * 2,
      _cardHeight + _margeExterne * 2,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(_margeExterne),
        build: (context) {

    return pw.Container(
    width: _cardWidth,
    height: _cardHeight,
    decoration: pw.BoxDecoration(
    borderRadius: pw.BorderRadius.circular(24),
    border: pw.Border.all(color: _border, width: 1),
  ),
  child: pw.Column(
    children: [
      // Bandeau supérieur — coins arrondis en haut uniquement
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 16),
        decoration: pw.BoxDecoration(
          color: _primary,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(23),
            topRight: pw.Radius.circular(23),
          ),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              'TRAFFICO',
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 2.5,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Billet de voyage',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.white),
            ),
          ],
        ),
      ),

      // Corps du billet (inchangé)
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    '${t.villeDepart}  ->  ${t.villeArrivee}',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 12),
                  _ligne('Passager', nomPassager),
                  _ligne('Départ', DateFormat('dd/MM/yy HH:mm').format(t.heureDepart)),
                  _ligne('Agence', t.agence?.nom ?? '—'),
                  _ligne('Place', reservation.numeroSiege),
                  _ligne('Prix', '${t.tarif.toStringAsFixed(0)} FBu'),
                  _ligne('Statut', confirmee ? 'Confirmée' : 'En attente',
                  couleur: confirmee ? _success : _warning),
                ],
              ),
              expire
                ? pw.Container(
                  width: 88,
                  height: 88,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey700)),
                  child: pw.Text('QR EXPIRÉ', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                )

                :pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 88,
                  height: 88,
                ),
            ],
          ),
        ),
      ),

      // Bandeau inférieur — coins arrondis en bas uniquement
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          color: _primary,
          borderRadius: const pw.BorderRadius.only(
            bottomLeft: pw.Radius.circular(23),
            bottomRight: pw.Radius.circular(23),
          ),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              expire ? 'BILLET EXPIRE' : 'PRÉSENTE CE BILLET AU CONTRÔLEUR',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 1,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              reservation.qrCode.substring(0, 8).toUpperCase(),
              style: pw.TextStyle(fontSize: 7, color: PdfColors.white, font: pw.Font.courier()),
                ),
              ],
            ),
            ),
            ],
          ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'billet_${reservation.id}.pdf',
    );
  }

  static pw.Widget _ligne(String label, String valeur, {PdfColor? couleur}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8.5, color: _grey700)),
          pw.Text(
            valeur, 
            style: pw.TextStyle(
              fontSize: 8.5, 
              fontWeight: pw.FontWeight.bold,
              color: couleur
              )
            ),
        ],
      ),
    );
  }
}