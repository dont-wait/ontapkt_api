import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';
import 'login_screen.dart';

/// Màn hình tổng hợp thu chi
class SummaryScreen extends StatefulWidget {
  final int userId;
  final String hoTen;

  const SummaryScreen({
    super.key,
    required this.userId,
    required this.hoTen,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  double _tongThu = 0;
  double _tongChi = 0;
  bool _isLoading = true;

  /// Format số tiền kiểu Việt Nam: 5.000.000
  final _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTongHop(widget.userId);
      setState(() {
        _tongThu = (data['tongThu'] as num).toDouble();
        _tongChi = (data['tongChi'] as num).toDouble();
      });
    } catch (e) {
      // Xử lý lỗi
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Xin chào, ${widget.hoTen}'),
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
        actions: [
          // Nút đăng xuất
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Card tổng thu
                  _buildCard(
                    label: 'Tổng thu',
                    amount: _tongThu,
                    color: const Color(0xFF2E5BBA),
                  ),
                  const SizedBox(height: 24),

                  // Card tổng chi
                  _buildCard(
                    label: 'Tổng chi',
                    amount: -_tongChi,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 40),

                  // Số dư
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Số dư',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatter.format(_tongThu - _tongChi),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: (_tongThu - _tongChi) >= 0
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

      // FAB thêm giao dịch
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(
                userId: widget.userId,
                hoTen: widget.hoTen,
              ),
            ),
          );
          _loadData(); // Refresh sau khi thêm
        },
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch'),
      ),
    );
  }

  /// Widget card hiển thị tổng thu hoặc tổng chi
  Widget _buildCard({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatter.format(amount),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
