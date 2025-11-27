import 'package:intl/intl.dart';

class Article {
  final int idBerita;
  final String judulBerita;
  final String isi;
  final String? articleImages;
  final int? idKategori;
  final String? tanggalPublish;
  final int? idUser;
  final int? hits;
  final String? statusBerita;

  Article({
    required this.idBerita,
    required this.judulBerita,
    required this.isi,
    this.articleImages,
    this.idKategori,
    this.tanggalPublish,
    this.idUser,
    this.hits,
    this.statusBerita,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Support both API response format (camelCase) and old format (snake_case)
    return Article(
      idBerita: json['id'] is int
          ? json['id']
          : (json['id_berita'] is int
                ? json['id_berita']
                : int.parse((json['id'] ?? json['id_berita']).toString())),
      judulBerita: json['title'] ?? json['judul_berita'] ?? '',
      isi: json['content'] ?? json['isi'] ?? '',
      articleImages: json['article_images'],
      idKategori: (json['id_kategori'] ?? json['category_id']) != null
          ? int.tryParse(
              (json['id_kategori'] ?? json['category_id']).toString(),
            )
          : null,
      tanggalPublish: json['created_at'] ?? json['tanggal_publish'],
      idUser: (json['id_user'] ?? json['author_id']) != null
          ? int.tryParse((json['id_user'] ?? json['author_id']).toString())
          : null,
      hits: (json['viewCount'] ?? json['hits']) != null
          ? int.tryParse((json['viewCount'] ?? json['hits']).toString())
          : null,
      statusBerita: json['status'] ?? json['status_berita'],
    );
  }

  String get formattedDate {
    if (tanggalPublish == null || tanggalPublish!.isEmpty) {
      return '';
    }
    try {
      final date = DateTime.parse(tanggalPublish!);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return tanggalPublish ?? '';
    }
  }

  // Getters for ArticleDetailScreen compatibility
  String get namaKategori =>
      'Berita'; // Default value as backend doesn't seem to provide category name directly yet
  DateTime? get createdAt =>
      tanggalPublish != null ? DateTime.tryParse(tanggalPublish!) : null;
  String? get namaStaff =>
      'Admin'; // Default value as backend provides ID but not name directly yet
}
