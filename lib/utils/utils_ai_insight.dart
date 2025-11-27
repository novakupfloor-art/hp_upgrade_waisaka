import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AIInsightService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash-lite';
  static const int _timeout = 40;

  /// Generate AI insights for property
  static Future<Map<String, String>> generatePropertyInsights({
    required String propertyName,
    required String propertyType,
    required String address,
    required String price,
    required int landSize,
    required int buildingSize,
    required int? bedrooms,
    required int? bathrooms,
    String? certificate,
  }) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackInsights();
      }

      final prompt = _buildPropertyInsightPrompt(
        propertyName: propertyName,
        propertyType: propertyType,
        address: address,
        price: price,
        landSize: landSize,
        buildingSize: buildingSize,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        certificate: certificate,
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: _timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        return _parseAIResponse(text);
      } else {
        debugPrint('AI Service Error: ${response.statusCode}');
        return _getFallbackInsights();
      }
    } catch (e) {
      debugPrint('AI Service Exception: $e');
      return _getFallbackInsights();
    }
  }

  static String _buildPropertyInsightPrompt({
    required String propertyName,
    required String propertyType,
    required String address,
    required String price,
    required int landSize,
    required int buildingSize,
    required int? bedrooms,
    required int? bathrooms,
    String? certificate,
  }) {
    return '''
Anda adalah AI Expert Property Analyst yang profesional dan berpengalaman dalam menganalisis properti di Indonesia.

🏠 ANALISIS PROPERTI:
• Nama: $propertyName
• Tipe: $propertyType
• Alamat: $address
• Harga: $price
• Luas Tanah: $landSize m²
• Luas Bangunan: $buildingSize m²
• Kamar Tidur: ${bedrooms ?? 'Tidak disebutkan'}
• Kamar Mandi: ${bathrooms ?? 'Tidak disebutkan'}
• Sertifikat: ${certificate ?? 'Tidak disebutkan'}

🔍 TUGAS ANDA:
Buat analisis properti yang komprehensif dengan format berikut:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ANALISIS INVESTASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Poin-poin analisis investasi dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 POTENSI PERTUMBUHAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Potensi pertumbuhan area dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 ESTIMASI HARGA PASAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Estimasi harga pasar wajar dalam 2 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏗️ KONDISI BANGUNAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Kondisi bangunan berdasarkan spesifikasi dalam 2 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 NILAI LOKASI STRATEGIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Analisis lokasi dan aksesibilitas dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ RISIKO & PERTIMBANGAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Risiko dan hal yang perlu dipertimbangkan dalam 2-3 kalimat]

📝 CATATAN:
• Analisis harus objektif dan berbasis data
• Fokus pada aspek investasi dan nilai properti
• Gunakan bahasa yang profesional namun mudah dipahami
• Hindari spekulasi yang berlebihan
• Berikan insight yang bermanfaat bagi pembeli/investor
''';
  }

  static Map<String, String> _parseAIResponse(String response) {
    final insights = <String, String>{};

    // Parse sections based on markers
    final sections = {
      '📊 ANALISIS INVESTASI': 'investment_analysis',
      '🎯 POTENSI PERTUMBUHAN': 'growth_potential',
      '💰 ESTIMASI HARGA PASAR': 'market_price_estimate',
      '🏗️ KONDISI BANGUNAN': 'building_condition',
      '📍 NILAI LOKASI STRATEGIS': 'location_value',
      '⚠️ RISIKO & PERTIMBANGAN': 'risks_considerations',
    };

    for (final entry in sections.entries) {
      final pattern = RegExp(
        '${entry.key}[\\s\\S]*?━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      final match = pattern.firstMatch(response);

      if (match != null) {
        String content = match.group(0) ?? '';
        // Remove markers and clean up
        content = content.replaceAll(entry.key, '').trim();
        content = content
            .replaceAll(RegExp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'), '')
            .trim();
        content = content.replaceAll(RegExp('📝 CATATAN:[\\s\\S]*'), '').trim();

        if (content.isNotEmpty) {
          insights[entry.value] = content;
        }
      }
    }

    return insights.isNotEmpty ? insights : _getFallbackInsights();
  }

  static Map<String, String> _getFallbackInsights() {
    return {
      'investment_analysis':
          'Properti ini menawarkan potensi investasi yang menarik dengan lokasi yang strategis dan harga yang kompetitif di pasaran.',
      'growth_potential':
          'Area ini menunjukkan tren pertumbuhan yang positif didukung oleh pengembangan infrastruktur dan aksesibilitas yang baik.',
      'market_price_estimate':
          'Harga properti berada dalam kisaran wajar untuk area dan tipe properti serupa, memberikan nilai investasi yang seimbang.',
      'building_condition':
          'Berdasarkan spesifikasi, properti ini memiliki kondisi bangunan yang baik dengan perbandingan luas tanah dan bangunan yang optimal.',
      'location_value':
          'Lokasi properti memberikan nilai tambah dengan akses mudah ke fasilitas umum, transportasi, dan pusat komersial.',
      'risks_considerations':
          'Pertimbangkan faktor pasar lokal dan perencanaan pembangunan area untuk investasi jangka panjang yang optimal.',
    };
  }

  /// Generate nearby facilities summary
  static Future<String> generateNearbyFacilities(String address) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackFacilities();
      }

      final prompt =
          '''
Anda adalah AI Expert Location Analyst yang profesional dalam menganalisis fasilitas publik di suatu area.

📍 LOKASI: $address

🔍 TUGAS ANDA:
Buat ringkasan fasilitas publik terdekat dalam format berikut:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏫 FASILITAS PENDIDIKAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar fasilitas pendidikan terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 FASILITAS KESEHATAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar fasilitas kesehatan terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛍️ FASILITAS PERBELANJAAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar pusat perbelanjaan dan pasar terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚗 AKSES TRANSPORTASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Informasi akses transportasi umum dan jalan utama dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏢 FASILITAS UMUM LAINNYA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Fasilitas umum lainnya seperti bank, ATM, kantor pos dalam 2-3 kalimat]

📝 CATATAN:
• Fokus pada fasilitas yang relevan dan terdekat
• Berikan informasi yang akurat dan bermanfaat
• Jangan menyebutkan fasilitas yang terlalu jauh (>5km)
• Gunakan bahasa yang informatif dan jelas
''';

      final response = await http
          .post(
            Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: _timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            _getFallbackFacilities();
      } else {
        return _getFallbackFacilities();
      }
    } catch (e) {
      debugPrint('AI Facilities Service Exception: $e');
      return _getFallbackFacilities();
    }
  }

  static String _getFallbackFacilities() {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏫 FASILITAS PENDIDIKAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area ini dilayani oleh berbagai institusi pendidikan dari tingkat dasar hingga menengah dengan jarak tempuh yang reasonable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 FASILITAS KESEHATAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tersedia fasilitas kesehatan seperti klinik dan puskesmas dalam jarak yang mudah dijangkau untuk kebutuhan medis dasar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛍️ FASILITAS PERBELANJAAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area ini memiliki akses ke pusat perbelanjaan lokal dan pasar tradisional untuk kebutuhan sehari-hari.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚗 AKSES TRANSPORTASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Lokasi ini terhubung dengan baik melalui jalan utama dan tersedia akses transportasi umum.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏢 FASILITAS UMUM LAINNYA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fasilitas pendukung seperti bank, ATM, dan kantor pos tersedia dalam radius yang wajar.
''';
  }
}
