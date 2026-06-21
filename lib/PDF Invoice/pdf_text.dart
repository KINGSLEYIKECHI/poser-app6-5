import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font bangla;
  final pw.Font arabic;
  final pw.Font deva;
  final pw.Font cjk;
  final pw.Font gujarati;
  final pw.Font kannada;
  final pw.Font malayalam;
  final pw.Font tamil;
  final pw.Font telugu;
  final pw.Font khmer;
  final pw.Font armenian;
  final pw.Font georgian;
  final pw.Font lao;
  final pw.Font oriya;
  final pw.Font sinhala;
  final pw.Font thai;
  final pw.Font amharic;
  final pw.Font hebrew;
  final pw.Font burmese;
  final pw.Font punjabi;

  PdfFonts({
    required this.regular,
    required this.bold,
    required this.bangla,
    required this.arabic,
    required this.deva,
    required this.cjk,
    required this.gujarati,
    required this.kannada,
    required this.malayalam,
    required this.tamil,
    required this.telugu,
    required this.khmer,
    required this.armenian,
    required this.georgian,
    required this.lao,
    required this.oriya,
    required this.sinhala,
    required this.thai,
    required this.amharic,
    required this.hebrew,
    required this.burmese,
    required this.punjabi,
  });
}

Future<PdfFonts> loadPdfFonts() async {
  final fonts = await Future.wait([
    rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
    rootBundle.load('assets/fonts/AnekGujarati-Regular.ttf'),
    rootBundle.load('assets/fonts/AnekKannada-Regular.ttf'),
    rootBundle.load('assets/fonts/AnekMalayalam-Regular.ttf'),
    rootBundle.load('assets/fonts/AnekTamil-Regular.ttf'),
    rootBundle.load('assets/fonts/AnekTelugu-Regular.ttf'),
    rootBundle.load('assets/fonts/Khmer-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansArmenian-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansGeorgian-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansLaoLooped-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansOriya-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansSinhala-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansThai-Regular.ttf'),
    rootBundle.load('assets/fonts/GoogleSans-Regular.ttf'),
    rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'),
    rootBundle.load('assets/fonts/Padauk-Regular.ttf'),
    rootBundle.load('assets/fonts/GoogleSans-Regular.ttf'),
  ]);

  return PdfFonts(
    regular: pw.Font.ttf(fonts[0]),
    bold: pw.Font.ttf(fonts[1]),
    bangla: pw.Font.ttf(fonts[2]),
    arabic: pw.Font.ttf(fonts[3]),
    deva: pw.Font.ttf(fonts[4]),
    cjk: pw.Font.ttf(fonts[5]),
    gujarati: pw.Font.ttf(fonts[6]),
    kannada: pw.Font.ttf(fonts[7]),
    malayalam: pw.Font.ttf(fonts[8]),
    tamil: pw.Font.ttf(fonts[9]),
    telugu: pw.Font.ttf(fonts[10]),
    khmer: pw.Font.ttf(fonts[11]),
    armenian: pw.Font.ttf(fonts[12]),
    georgian: pw.Font.ttf(fonts[13]),
    lao: pw.Font.ttf(fonts[14]),
    oriya: pw.Font.ttf(fonts[15]),
    sinhala: pw.Font.ttf(fonts[16]),
    thai: pw.Font.ttf(fonts[17]),
    amharic: pw.Font.ttf(fonts[18]),
    hebrew: pw.Font.ttf(fonts[19]),
    burmese: pw.Font.ttf(fonts[20]),
    punjabi: pw.Font.ttf(fonts[21]),
  );
}

pw.Font resolveFont(String code, PdfFonts f) {
  switch (code) {
    case 'bn':
      return f.bangla;
    case 'ar':
    case 'fa':
    case 'ur':
      return f.arabic;
    case 'hi':
    case 'mr':
    case 'ne':
      return f.deva;
    case 'zh':
    case 'ja':
    case 'ko':
      return f.cjk;
    case 'gu':
      return f.gujarati;
    case 'kn':
      return f.kannada;
    case 'ml':
      return f.malayalam;
    case 'ta':
      return f.tamil;
    case 'te':
      return f.telugu;
    case 'th':
      return f.thai;
    case 'he':
      return f.hebrew;
    case 'my':
      return f.burmese;
    case 'si':
      return f.sinhala;
    default:
      return f.regular;
  }
}

pw.Text pdfText(
  String text, {
  required PdfFonts fonts,
  String? langCode,
  bool bold = false,
  double size = 10,
  pw.TextDirection textDirection = pw.TextDirection.ltr,
  PdfColor color = PdfColors.black,
  pw.TextAlign align = pw.TextAlign.left,
}) {
  final resolvedFont = resolveFont(langCode ?? 'en', fonts);

  String processedText = text;

  // Apply Bangla fix if language is Bengali
  if (langCode == 'bn') {
    processedText = fixBangla(processedText);
  }

  return pw.Text(
    processedText,
    textAlign: align,
    style: pw.TextStyle(
      font: bold ? fonts.bold : resolvedFont,
      fontSize: size,
      color: color,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontFallback: [
        fonts.regular,
        fonts.bangla, // important for Bangla
        fonts.arabic,
        fonts.deva,
        fonts.cjk,
        fonts.tamil,
        fonts.telugu,
        fonts.thai,
        fonts.burmese,
      ],
    ),
    textDirection: textDirection,
  );
}

/// Fix Bangla ligatures, vowels, conjuncts for PDF
String fixBangla(String text) {
  String t = text;

  // Remove zero-width joiners if any
  t = t.replaceAll('\u200C', '').replaceAll('\u200D', '');

  // Pre-base vowels: ি, ী, ে, ো, ৌ
  t = t.replaceAllMapped(
    RegExp(r'([ক-হ][্]?)([িীেোৌ])'),
    (m) => '${m[2]}${m[1]}',
  );

  return t;
}
