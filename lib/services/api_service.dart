import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service gọi API .NET 8
class ApiService {
  // Đổi thành IP máy nếu chạy trên điện thoại thật
  // Dùng localhost cho Linux/Chrome, đổi thành 10.0.2.2 nếu chạy Android emulator
  static const String baseUrl = 'http://localhost:5000/api';

  // ==================== ĐĂNG NHẬP ====================
  static Future<Map<String, dynamic>?> login(int id, String matKhau) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'matKhau': matKhau}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ==================== DANH MỤC ====================
  static Future<List<Map<String, dynamic>>> getDanhMuc(String loai) async {
    final response = await http.get(Uri.parse('$baseUrl/danhmuc?loai=$loai'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ==================== GIAO DỊCH ====================
  static Future<bool> themGiaoDich(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/giaodich'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> getGiaoDich(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/giaodich?userId=$userId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ==================== TỔNG HỢP ====================
  static Future<Map<String, dynamic>> getTongHop(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/giaodich/tonghop?userId=$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'tongThu': 0, 'tongChi': 0};
  }
}
