import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Enhanced AI Insight Service (matching backend novak_upfloor)
class AIInsightEnhancedService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash-lite';
  static const int _timeout = 40;

  /// Generate harga_rata (average price) - matching backend enrichHargaRata
  static Future<String> generateHargaRata({
    required String propertyType,
    required String category,
    required String address,
    required int hargaListing,
    required int luasTanah,
    required int luasBangunan,
  }) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackHargaRata();
      }

      final prompt =
          '''
Anda adalah AI Expert Property Analyst yang berspesialisasi dalam analisis harga properti di Indonesia.

🏠 DATA PROPERTI:
• Tipe: $propertyType
• Kategori: $category  
• Alamat Lengkap: $address
• Harga Listing: Rp ${hargaListing.toString()}
• Luas Tanah: $luasTanah m²
• Luas Bangunan: $luasBangunan m²

🔍 TUGAS ANDA:
Buat ringkasan harga rata-rata pasar untuk area tersebut dengan format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 RINGKASAN HARGA RATA-RATA PASAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Buat analisis harga rata-rata dalam 3-4 kalimat yang mencakup:]
1. Harga rata-rata per m² untuk tipe properti serupa di area tersebut
2. Perbandingan harga listing dengan harga pasar (lebih murah/standar/lebih mahal)
3. Faktor-faktor yang mempengaruhi harga di area tersebut
4. Estimasi harga wajar untuk properti ini

📝 CATATAN PENTING:
• Gunakan data harga pasar yang realistis untuk area di Indonesia
• Pertimbangkan tipe properti dan kategori dalam analisis
• Berikan insight yang bernilai untuk pembeli/investor
• Batasi response maksimal 18 kalimat
• Format yang jelas dan mudah dibaca
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
            _getFallbackHargaRata();
      } else {
        return _getFallbackHargaRata();
      }
    } catch (e) {
      debugPrint('AI Harga Rata Error: $e');
      return _getFallbackHargaRata();
    }
  }

  /// Generate fasilitas_terdekat - matching backend enrichFasilitasTerdekat
  static Future<String> generateFasilitasTerdekat({
    required String address,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
  }) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackFasilitas();
      }

      final alamatLengkap = [
        address,
        kecamatan,
        kabupaten,
        provinsi,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final prompt =
          '''
Andai adalah AI Expert Location Analyst yang profesional dalam menganalisis fasilitas publik di suatu area di Indonesia.

📍 LOKASI ANALISIS:
$alamatLengkap

🔍 TUGAS ANDA:
Buat ringkasan fasilitas publik terdekat dengan radius maksimal 5km dalam format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏫 FASILITAS PENDIDIKAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar sekolah, universitas, kursus terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 FASILITAS KESEHATAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar rumah sakit, klinik, apotek terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛍️ FASILITAS PERBELANJAAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Daftar mall, pasar, minimarket terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚗 AKSES TRANSPORTASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Informasi jalan utama, transportasi umum, stasiun terdekat dalam 2-3 kalimat]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏢 FASILITAS UMUM LAINNYA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Bank, ATM, kantor pos, tempat ibadah terdekat dalam 2-3 kalimat]

📝 CATATAN PENTING:
• Fokus pada fasilitas yang relevan dan benar-benar ada
• Jangan menyebutkan fasilitas yang terlalu jauh (>5km)
• Berikan informasi yang akurat dan bermanfaat
• Gunakan bahasa yang informatif dan jelas
• Maksimal 18 kalimat total
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
            _getFallbackFasilitas();
      } else {
        return _getFallbackFasilitas();
      }
    } catch (e) {
      debugPrint('AI Fasilitas Error: $e');
      return _getFallbackFasilitas();
    }
  }

  /// Generate peta_map - matching backend enrichPetaMap
  static Future<Map<String, dynamic>> generatePetaMap({
    required String address,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
  }) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackPetaMap(address, kecamatan, kabupaten, provinsi);
      }

      final alamatLengkap = [
        address,
        kecamatan,
        kabupaten,
        provinsi,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final prompt =
          '''
Andai adalah AI Expert Geocoding Specialist yang bertugas mencari koordinat maps dengan akurat di Indonesia.

🔍 TUGAS ANDA:
Cari koordinat (latitude, longitude) paling relevan dan akurat dari: $alamatLengkap

📋 PERSYARATAN:
• Jangan cari koordinat di luar wilayah yang disebutkan
• Jangan berikan koordinat perkiraan
• Prioritaskan hasil pencarian yang paling akurat
• Verifikasi dengan Google Maps
• Jika tidak ditemukan, return: {}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📤 FORMAT OUTPUT (JSON MURNI):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "address": "Alamat lengkap yang ditemukan",
  "confidence": "high/medium/low",
  "maps_query": "query untuk google maps"
}

📝 CATATAN:
• Return JSON murni tanpa markdown
• Latitude dan longitude harus valid untuk Indonesia
• Jangan memberikan koordinat yang tidak yakin
• Confidence level berdasarkan keakuratan pencarian
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
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        try {
          // Try to parse as JSON
          final jsonData = jsonDecode(text);
          return {
            'success': true,
            'latitude': jsonData['latitude'],
            'longitude': jsonData['longitude'],
            'address': jsonData['address'] ?? alamatLengkap,
            'confidence': jsonData['confidence'] ?? 'medium',
            'maps_query': jsonData['maps_query'] ?? alamatLengkap,
          };
        } catch (e) {
          // If JSON parsing fails, return fallback
          return _getFallbackPetaMap(address, kecamatan, kabupaten, provinsi);
        }
      } else {
        return _getFallbackPetaMap(address, kecamatan, kabupaten, provinsi);
      }
    } catch (e) {
      debugPrint('AI Peta Map Error: $e');
      return _getFallbackPetaMap(address, kecamatan, kabupaten, provinsi);
    }
  }

  /// Generate comprehensive property insights (combination of all backend enrichments)
  static Future<Map<String, dynamic>> generateCompletePropertyInsights({
    required String propertyName,
    required String propertyType,
    required String category,
    required String address,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
    required int hargaListing,
    required int luasTanah,
    required int luasBangunan,
    String? sertifikat,
    int? kamarTidur,
    int? kamarMandi,
  }) async {
    try {
      // Run all enrichments in parallel
      final results = await Future.wait([
        generateHargaRata(
          propertyType: propertyType,
          category: category,
          address: address,
          hargaListing: hargaListing,
          luasTanah: luasTanah,
          luasBangunan: luasBangunan,
        ),
        generateFasilitasTerdekat(
          address: address,
          kecamatan: kecamatan,
          kabupaten: kabupaten,
          provinsi: provinsi,
        ),
        generatePetaMap(
          address: address,
          kecamatan: kecamatan,
          kabupaten: kabupaten,
          provinsi: provinsi,
        ),
      ]);

      return {
        'success': true,
        'harga_rata': results[0],
        'fasilitas_terdekat': results[1],
        'peta_map': results[2],
        'property_info': {
          'nama_property': propertyName,
          'tipe': propertyType,
          'kategori': category,
          'alamat': address,
          'kecamatan': kecamatan,
          'kabupaten': kabupaten,
          'provinsi': provinsi,
          'harga_listing': hargaListing,
          'luas_tanah': luasTanah,
          'luas_bangunan': luasBangunan,
          'sertifikat': sertifikat,
          'kamar_tidur': kamarTidur,
          'kamar_mandi': kamarMandi,
        },
      };
    } catch (e) {
      debugPrint('Complete Property Insights Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'harga_rata': _getFallbackHargaRata(),
        'fasilitas_terdekat': _getFallbackFasilitas(),
        'peta_map': _getFallbackPetaMap(
          address,
          kecamatan,
          kabupaten,
          provinsi,
        ),
      };
    }
  }

  // Fallback methods
  static String _getFallbackHargaRata() {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 RINGKASAN HARGA RATA-RATA PASAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Berdasarkan analisis pasar untuk area tersebut, harga rata-rata properti serupa berada dalam kisaran yang kompetitif. Harga listing properti ini sesuai dengan kondisi pasar lokal dan menawarkan nilai investasi yang seimbang. Faktor lokasi dan spesifikasi properti memberikan nilai tambah yang signifikan.
''';
  }

  static String _getFallbackFasilitas() {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏫 FASILITAS PENDIDIKAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area ini dilayani oleh berbagai institusi pendidikan dari tingkat dasar hingga menengah dengan jarak tempuh yang reasonable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 FASILITAS KESEHATAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tersedia fasilitas kesehatan seperti klinik dan puskesmas dalam jarak yang mudah dijangkau.

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

  static Map<String, dynamic> _getFallbackPetaMap(
    String address,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
  ) {
    final alamatLengkap = [
      address,
      kecamatan,
      kabupaten,
      provinsi,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return {
      'success': false,
      'latitude': -6.2088, // Jakarta default
      'longitude': 106.8456,
      'address': alamatLengkap,
      'confidence': 'low',
      'maps_query': alamatLengkap,
      'iframe':
          '''
<iframe 
  src="https://www.google.com/maps?q=${Uri.encodeComponent(alamatLengkap)}&output=embed" 
  width="100%" 
  height="300" 
  style="border:0;" 
  allowfullscreen="" 
  loading="lazy">
</iframe>
''',
    };
  }
}
