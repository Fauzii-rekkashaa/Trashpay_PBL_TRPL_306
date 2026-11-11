class UserModel {
  final int id;
  final String nama;
  final String noHp;
  final String? email;
  final String role;
  final String? alamat;
  final double saldoAktif;

  UserModel({
    required this.id,
    required this.nama,
    required this.noHp,
    this.email,
    required this.role,
    this.alamat,
    required this.saldoAktif,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['name'] ?? json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'warga',
      alamat: json['alamat'],
      saldoAktif: double.tryParse(json['saldo_aktif'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nama,
      'no_hp': noHp,
      'email': email,
      'role': role,
      'alamat': alamat,
      'saldo_aktif': saldoAktif,
    };
  }
}