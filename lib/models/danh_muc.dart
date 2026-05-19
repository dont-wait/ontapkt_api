/// Model DanhMuc tương ứng với API Models/DanhMuc.cs
class DanhMuc {
  final int id;
  final String tenDanhMuc;
  final int? idDanhMucCha;
  final String loaiDanhMuc; // "thu" hoặc "chi"

  DanhMuc({
    required this.id,
    required this.tenDanhMuc,
    this.idDanhMucCha,
    required this.loaiDanhMuc,
  });

  /// Tạo DanhMuc từ JSON (response API)
  factory DanhMuc.fromJson(Map<String, dynamic> json) {
    return DanhMuc(
      id: json['id'] as int,
      tenDanhMuc: json['tenDanhMuc'] as String? ?? '',
      idDanhMucCha: json['idDanhMucCha'] as int?,
      loaiDanhMuc: json['loaiDanhMuc'] as String? ?? '',
    );
  }

  /// Chuyển DanhMuc thành JSON (gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenDanhMuc': tenDanhMuc,
      'idDanhMucCha': idDanhMucCha,
      'loaiDanhMuc': loaiDanhMuc,
    };
  }

  @override
  String toString() => 'DanhMuc(id: $id, tenDanhMuc: $tenDanhMuc)';
}
