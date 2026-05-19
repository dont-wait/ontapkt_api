import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

import 'summary_screen.dart';

/// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;   // Ẩn/hiện mật khẩu
  bool _rememberMe = false;       // Ghi nhớ đăng nhập
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Tải thông tin đăng nhập đã lưu
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('saved_id') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    if (savedId.isNotEmpty) {
      setState(() {
        _idController.text = savedId;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  /// Xử lý đăng nhập
  Future<void> _login() async {
    final idText = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (idText.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    final id = int.tryParse(idText);
    if (id == null) {
      _showError('ID phải là số');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ApiService.login(id, password);

      if (user != null) {
        // Lưu thông tin nếu chọn ghi nhớ
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('saved_id', idText);
          await prefs.setString('saved_password', password);
        } else {
          await prefs.remove('saved_id');
          await prefs.remove('saved_password');
        }

        if (!mounted) return;

        // Chuyển sang trang tổng hợp
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(userId: user['id'], hoTen: user['hoTen']),
          ),
        );
      } else {
        _showError('Sai ID hoặc mật khẩu');
      }
    } catch (e) {
      _showError('Không thể kết nối server');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tiêu đề
              const Text(
                'Đăng Nhập',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 32),

              // Ô nhập Username (ID)
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Ô nhập Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Checkbox ghi nhớ mật khẩu
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    activeColor: const Color(0xFF4A6CF7),
                  ),
                  const Text('Ghi nhớ mật khẩu'),
                ],
              ),
              const SizedBox(height: 20),

              // Nút đăng nhập
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ĐĂNG NHẬP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
