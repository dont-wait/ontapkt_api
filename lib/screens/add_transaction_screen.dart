import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'summary_screen.dart';

/// Màn hình thêm giao dịch (thu/chi)
class AddTransactionScreen extends StatefulWidget {
  final int userId;
  final String hoTen;

  const AddTransactionScreen({
    super.key,
    required this.userId,
    required this.hoTen,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _loai = 'chi'; // Mặc định là "chi"
  final _moTaController = TextEditingController();
  final _soTienController = TextEditingController();
  DateTime _ngay = DateTime.now();
  int? _danhMucId;
  String? _hinhBase64;
  List<Map<String, dynamic>> _danhMucs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDanhMuc();
  }

  /// Tải danh mục theo loại (thu/chi)
  Future<void> _loadDanhMuc() async {
    final list = await ApiService.getDanhMuc(_loai);
    setState(() {
      _danhMucs = list;
      _danhMucId = null; // Reset khi đổi loại
    });
  }

  /// Chọn ngày
  Future<void> _chonNgay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _ngay = picked);
    }
  }

  /// Chọn hình ảnh từ thư viện hoặc camera
  Future<void> _chonHinh(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 800);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _hinhBase64 = base64Encode(bytes);
      });
    }
  }

  /// Lưu giao dịch
  Future<void> _luu() async {
    // Validate
    if (_moTaController.text.trim().isEmpty) {
      _showError('Vui lòng nhập tên thu chi');
      return;
    }
    if (_soTienController.text.trim().isEmpty) {
      _showError('Vui lòng nhập số tiền');
      return;
    }
    final soTien = double.tryParse(_soTienController.text.trim());
    if (soTien == null || soTien <= 0) {
      _showError('Số tiền không hợp lệ');
      return;
    }
    if (_danhMucId == null) {
      _showError('Vui lòng chọn danh mục');
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'ngay': DateFormat('yyyy-MM-dd').format(_ngay),
      'loai': _loai,
      'tongTien': soTien,
      'moTa': _moTaController.text.trim(),
      'danhMucId': _danhMucId,
      'hinhMinhHoa': _hinhBase64 ?? '',
      'userId': widget.userId,
    };

    try {
      final ok = await ApiService.themGiaoDich(data);
      if (ok && mounted) {
        // Chuyển sang trang tổng hợp
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(
              userId: widget.userId,
              hoTen: widget.hoTen,
            ),
          ),
        );
      } else {
        _showError('Lưu thất bại');
      }
    } catch (e) {
      _showError('Không thể kết nối server');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle Thu / Chi
            _buildLoaiToggle(),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              _loai == 'chi' ? 'Thêm chi tiêu' : 'Thêm thu nhập',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),

            // Tên thu chi
            TextField(
              controller: _moTaController,
              decoration: InputDecoration(
                labelText: 'Tên thu chi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Số tiền
            TextField(
              controller: _soTienController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền',
                suffixText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Chọn ngày
            InkWell(
              onTap: _chonNgay,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_ngay)),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown danh mục
            DropdownButtonFormField<int>(
              initialValue: _danhMucId,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _danhMucs.map((dm) {
                return DropdownMenuItem<int>(
                  value: dm['id'],
                  child: Text(dm['tenDanhMuc']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _danhMucId = val),
            ),
            const SizedBox(height: 16),

            // Chọn hình ảnh
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _chonHinh(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Thư viện'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _chonHinh(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Preview hình đã chọn
            if (_hinhBase64 != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(_hinhBase64!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _luu,
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
                    : const Text('LƯU'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget toggle Thu / Chi
  Widget _buildLoaiToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Nút Thu
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _loai = 'thu');
                _loadDanhMuc();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _loai == 'thu' ? const Color(0xFF4A6CF7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Thu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _loai == 'thu' ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Nút Chi
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _loai = 'chi');
                _loadDanhMuc();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _loai == 'chi' ? const Color(0xFF4A6CF7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Chi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _loai == 'chi' ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
