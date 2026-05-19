/// Model GiaoDich tương ứng với API Models/GiaoDich.cs
class GiaoDich {
  final int? id;
  final String ngay;         // yyyy-MM-dd
  final String loai;         // "thu" hoặc "chi"
  final double tongTien;
  final String moTa;
  final int danhMucId;
  final String hinhMinhHoa;
  final int userId;

  GiaoDich({
    this.id,
    required this.ngay,
    required this.loai,
    required this.tongTien,
    required this.moTa,
    required this.danhMucId,
    this.hinhMinhHoa = '',
    required this.userId,
  });

  /// Tạo GiaoDich từ JSON (response API)
  factory GiaoDich.fromJson(Map<String, dynamic> json) {
    return GiaoDich(
      id: json['id'] as int?,
      ngay: json['ngay'] as String? ?? '',
      loai: json['loai'] as String? ?? '',
      tongTien: (json['tongTien'] as num?)?.toDouble() ?? 0,
      moTa: json['moTa'] as String? ?? '',
      danhMucId: json['danhMucId'] as int? ?? 0,
      hinhMinhHoa: json['hinhMinhHoa'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
    );
  }

  /// Chuyển GiaoDich thành JSON (gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ngay': ngay,
      'loai': loai,
      'tongTien': tongTien,
      'moTa': moTa,
      'danhMucId': danhMucId,
      'hinhMinhHoa': hinhMinhHoa,
      'userId': userId,
    };
  }

  @override
  String toString() => 'GiaoDich(id: $id, moTa: $moTa, tongTien: $tongTien)';
}
