import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String spreadsheetId = '1URmpVdxm1Eb4_hpAHPuT58OKXW6qobx2y4XevcXxxyQ';
const String gid = '0';
const String csvUrl = 'https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=csv&gid=$gid';
const String l10nPath = 'lib/l10n';

const Map<String, String> normalizedCodes = {
  'aze': 'az',
  'fil': 'tl',
  'cat': 'ca',
  'hat': 'ht',
  'sw': 'sw',
  'swh': 'sw',
  'bel': 'be',
  'bul': 'bg',
  'ces': 'cs',
  'dan': 'da',
  'deu': 'de',
  'ell': 'el',
  'fas': 'fa',
  'fin': 'fi',
  'fra': 'fr',
  'guj': 'gu',
  'heb': 'he',
  'hin': 'hi',
  'hrv': 'hr',
  'hun': 'hu',
  'ind': 'id',
  'ita': 'it',
  'jpn': 'ja',
  'kan': 'kn',
  'kat': 'ka',
  'kor': 'ko',
  'lav': 'lv',
  'lit': 'lt',
  'mal': 'ml',
  'mar': 'mr',
  'mkd': 'mk',
  'mya': 'my',
  'nld': 'nl',
  'nor': 'no',
  'pol': 'pl',
  'por': 'pt',
  'ron': 'ro',
  'rus': 'ru',
  'slk': 'sk',
  'slv': 'sl',
  'spa': 'es',
  'srp': 'sr',
  'swe': 'sv',
  'tam': 'ta',
  'tel': 'te',
  'tha': 'th',
  'tur': 'tr',
  'ukr': 'uk',
  'urd': 'ur',
  'vie': 'vi',
  'zho': 'zh',
};

Future<void> main() async {
  try {
    final response = await http.get(Uri.parse(csvUrl));
    if (response.statusCode != 200) {
      exitCode = 1;
      return;
    }

    final lines = const LineSplitter().convert(response.body);
    if (lines.isEmpty) {
      exitCode = 1;
      return;
    }

    final headers = lines[0].split(',');
    if (headers[0].toLowerCase() != 'key') {
      exitCode = 1;
      return;
    }

    final Map<String, Map<String, String>> translations = {};
    for (var i = 1; i < headers.length; i++) {
      final langCode = headers[i].trim();
      if (langCode.isNotEmpty) {
        translations[langCode] = {};
      }
    }

    for (var i = 2; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.isEmpty || row[0].isEmpty) continue;

      final key = row[0].trim();
      for (var j = 1; j < row.length && j < headers.length; j++) {
        final langCode = headers[j].trim();
        final value = row[j].trim();
        
        // ONLY add if the translation is NOT empty
        // This forces flutter gen-l10n to fallback to the template (English)
        if (translations.containsKey(langCode) && value.isNotEmpty) {
          translations[langCode]![key] = value.replaceAll('"', '\\"');
        }
      }
    }

    final directory = Directory(l10nPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    for (final langCode in translations.keys) {
      final Map<String, String> langData = translations[langCode]!;
      
      var normalized = langCode.replaceAll('-', '_');
      if (normalizedCodes.containsKey(normalized)) {
        normalized = normalizedCodes[normalized]!;
      }

      if (normalized.length > 5 && !normalized.contains('_')) {
        continue;
      }

      final Map<String, dynamic> arbJson = {
        '@@locale': normalized,
      };
      arbJson.addAll(langData);

      final fileName = 'app_$normalized.arb';
      final file = File('$l10nPath/$fileName');
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(arbJson));
    }

  } catch (e) {
    exitCode = 1;
  }
}
