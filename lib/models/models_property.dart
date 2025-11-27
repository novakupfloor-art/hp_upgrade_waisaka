import 'package:intl/intl.dart';
import '../config/app_config.dart';

class CategoryProperty {
  final int idKategoriProperty;
  final String namaKategoriProperty;
  final String slugKategoriProperty;

  CategoryProperty({
    required this.idKategoriProperty,
    required this.namaKategoriProperty,
    required this.slugKategoriProperty,
  });

  factory CategoryProperty.fromJson(Map<String, dynamic> json) {
    return CategoryProperty(
      idKategoriProperty: json['id_kategori_property'] ?? 0,
      namaKategoriProperty: json['nama_kategori_property'] ?? '',
      slugKategoriProperty: json['slug_kategori_property'] ?? '',
    );
  }
}

class Property {
  final int idProperty;
  final String namaProperty;
  final String kode;
  final String tipe; // Stored as backend format: "jual" or "sewa"
  final double harga;
  final String alamat;
  final int? lt;
  final int? lb;
  final int? kamarTidur;
  final int? kamarMandi;
  final int? lantai;
  final String? surat;
  final String? isi;
  final String? mainImageProperty;
  final List<String> images;
  final String? namaStaff;
  final String? teleponStaff;
  final CategoryProperty? kategoriProperty;
  final String? hargaRata; // AI Insight
  final String? fasilitasTerdekat; // AI Insight
  final String? fasilitasDekorasi; // AI Insight
  final Map<String, dynamic>? petaMap; // AI Insight

  Property({
    required this.idProperty,
    required this.namaProperty,
    required this.kode,
    required this.tipe,
    required this.harga,
    required this.alamat,
    this.lt,
    this.lb,
    this.kamarTidur,
    this.kamarMandi,
    this.lantai,
    this.surat,
    this.isi,
    this.mainImageProperty,
    this.images = const [],
    this.namaStaff,
    this.teleponStaff,
    this.kategoriProperty,
    this.hargaRata,
    this.fasilitasTerdekat,
    this.fasilitasDekorasi,
    this.petaMap,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Helper to parse images
    List<String> imgList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        for (var img in json['images']) {
          if (img is Map) {
            // Handle both formats: 'property_images' (MobilePropertyController) and 'gambar' (AiWaisakaSearchController)
            if (img['property_images'] != null) {
              imgList.add(img['property_images']);
            } else if (img['gambar'] != null) {
              imgList.add(img['gambar']);
            }
          } else if (img is String) {
            // If it's a string, check if it's already a full URL
            if (img.startsWith('http')) {
              imgList.add(img);
            } else {
              imgList.add(AppConfig.buildPropertyImages(img));
            }
          }
        }
      }
    }

    // Normalize tipe to lowercase backend format
    String tipeValue = (json['tipe'] ?? '').toString().toLowerCase();

    return Property(
      idProperty: json['id_property'] is int
          ? json['id_property']
          : int.parse(json['id_property'].toString()),
      namaProperty: json['nama_property'] ?? '',
      kode: json['kode'] ?? '',
      tipe: tipeValue,
      harga: json['harga'] is double
          ? json['harga']
          : double.parse(json['harga'].toString()),
      alamat: json['alamat'] ?? '',
      lt: json['lt'] != null ? int.tryParse(json['lt'].toString()) : null,
      lb: json['lb'] != null ? int.tryParse(json['lb'].toString()) : null,
      kamarTidur: json['kamar_tidur'] != null
          ? int.tryParse(json['kamar_tidur'].toString())
          : null,
      kamarMandi: json['kamar_mandi'] != null
          ? int.tryParse(json['kamar_mandi'].toString())
          : null,
      lantai: json['lantai'] != null
          ? int.tryParse(json['lantai'].toString())
          : null,
      surat: json['surat'],
      isi: json['isi'],
      mainImageProperty:
          json['main_image_url'] ?? (imgList.isNotEmpty ? imgList.first : null),
      images: imgList,
      namaStaff: json['nama_staff'],
      teleponStaff: json['telepon_staff'],
      kategoriProperty: json['kategori_property'] != null
          ? CategoryProperty.fromJson(json['kategori_property'])
          : null,
      hargaRata: json['harga_rata'],
      fasilitasTerdekat: json['fasilitas_terdekat'],
      fasilitasDekorasi: json['fasilitas_dekorasi'],
      petaMap: json['peta_map'] is Map<String, dynamic>
          ? json['peta_map']
          : null,
    );
  }

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  // Display-friendly tipe (capitalized for UI)
  String get tipeDisplay {
    if (tipe == 'jual') return 'Dijual';
    if (tipe == 'sewa') return 'Disewa';
    return tipe;
  }

  // Backend-compatible tipe (lowercase)
  String get tipeBackend {
    return tipe; // Already in backend format
  }

  // Getter untuk backward compatibility
  String? get propertyImages => mainImageProperty;

  // Getter untuk kemudahan akses
  String? get imagesProperty => mainImageProperty;

  // Getter untuk main image URL (prioritas: images array, fallback: mainImageProperty)
  String? get mainImageUrl {
    if (images.isNotEmpty) {
      return images.first;
    }
    return mainImageProperty;
  }
}
