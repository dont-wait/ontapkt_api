/// Model User tương ứng với API Models/User.cs
class User {
  final int id;
  final String matKhau;
  final String hoTen;
  final String gioiTinh;
  final String hinhMinhHoa;

  User({
    required this.id,
    this.matKhau = '',
    required this.hoTen,
    this.gioiTinh = '',
    this.hinhMinhHoa = '',
  });

  /// Tạo User từ JSON (response API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      matKhau: json['matKhau'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      gioiTinh: json['gioiTinh'] as String? ?? '',
      hinhMinhHoa: json['hinhMinhHoa'] as String? ?? '',
    );
  }

  /// Chuyển User thành JSON (gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matKhau': matKhau,
      'hoTen': hoTen,
      'gioiTinh': gioiTinh,
      'hinhMinhHoa': hinhMinhHoa,
    };
  }

  @override
  String toString() => 'User(id: $id, hoTen: $hoTen)';
}
