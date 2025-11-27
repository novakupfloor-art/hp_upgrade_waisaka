class User {
  final int idUser;
  final String username;
  final String nama;
  final String email;
  final String aksesLevel;
  final int? staffId;
  final String? statusStaff;
  final int sisaKuotaIklan;
  final int totalKuotaIklan;
  final String? gambar;
  final String? telepon;

  User({
    required this.idUser,
    required this.username,
    required this.nama,
    required this.email,
    required this.aksesLevel,
    this.staffId,
    this.statusStaff,
    this.sisaKuotaIklan = 0,
    this.totalKuotaIklan = 0,
    this.gambar,
    this.telepon,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.parse(json['id_user'].toString()),
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      aksesLevel: json['akses_level'] ?? 'User',
      staffId: json['staff_id'] != null
          ? int.tryParse(json['staff_id'].toString())
          : null,
      statusStaff: json['status_staff'],
      sisaKuotaIklan: json['sisa_kuota_iklan'] != null
          ? int.parse(json['sisa_kuota_iklan'].toString())
          : 0,
      totalKuotaIklan: json['total_kuota_iklan'] != null
          ? int.parse(json['total_kuota_iklan'].toString())
          : 0,
      gambar: json['gambar'],
      telepon: json['telepon'],
    );
  }
}
