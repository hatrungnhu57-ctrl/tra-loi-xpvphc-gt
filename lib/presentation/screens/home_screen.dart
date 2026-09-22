import 'package:flutter/material.dart';
import '../../data/datasources/seed_data_loader.dart';
import '../../engine/search/search_engine.dart';
import '../widgets/offense_card.dart';
import 'search_result_screen.dart';
import 'speed_calculator_screen.dart';
import 'alcohol_calculator_screen.dart';
import 'license_checker_screen.dart';
import 'owner_liability_screen.dart';
import 'offense_detail_screen.dart';
import 'ttks_patrol_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchEngine _searchEngine = SearchEngine(SeedDataLoader.getSeedOffenses());

  final List<String> _sampleQueries = [
    'xe máy 150 không bằng',
    '150cc k gplx',
    'oto 76/60',
    'cồn 0.32 moto',
    'kẹp 3',
    'giao xe cho người không bằng',
    'điểm g khoản 2 điều 7',
    'không đội mũ',
  ];

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    final response = _searchEngine.search(query);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(searchResponse: response),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'TRA LỖI GT PRO',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Tra Lỗi GT Pro',
                applicationVersion: '1.0.0 (NĐ 168/2024 & NĐ 238/2026)',
                children: const [
                  Text('Nguồn pháp lý gốc: Nghị định 168/2024/NĐ-CP và Nghị định 238/2026/NĐ-CP của Chính phủ.'),
                  SizedBox(height: 8),
                  Text('Ứng dụng hoạt động Offline, tính toán mức phạt, trừ điểm, tước GPLX và tạm giữ bằng Legal Engine hoàn toàn chính xác.'),
                ],
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card Tra Cứu
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tra cứu lỗi giao thông chuẩn xác & Offline',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Nhập lỗi, số đo (76/60), hoặc Điều/Khoản...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D47A1)),
                          onPressed: () => _executeSearch(_searchController.text),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: _executeSearch,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Nút TTKS Lập Biên Bản Nhanh
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        foregroundColor: const Color(0xFF212121),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFE65100)),
                      label: const Text(
                        'CHẾ ĐỘ TTKS & LẬP BIÊN BẢN NHANH',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.3),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TTKSPatrolScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Samples Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gợi ý tra nhanh:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF455A64)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sampleQueries.map((q) {
                      return ActionChip(
                        label: Text(q),
                        backgroundColor: Colors.white,
                        elevation: 1,
                        labelStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
                        onPressed: () {
                          _searchController.text = q;
                          _executeSearch(q);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Tool Calculators Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Công cụ tính toán nghiệp vụ Pro',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF263238)),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildToolCard(
                        title: 'Tính Tốc Độ',
                        subtitle: 'Ô tô / Xe máy quá tốc độ',
                        icon: Icons.speed_rounded,
                        color: const Color(0xFFE53935),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeedCalculatorScreen())),
                      ),
                      _buildToolCard(
                        title: 'Nồng Độ Cồn',
                        subtitle: 'Khí thở / Máu 3 mức',
                        icon: Icons.local_bar_rounded,
                        color: const Color(0xFFFB8C00),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlcoholCalculatorScreen())),
                      ),
                      _buildToolCard(
                        title: 'GPLX & Độ Tuổi',
                        subtitle: '125cc vs 150cc, Hết hạn',
                        icon: Icons.badge_outlined,
                        color: const Color(0xFF1E88E5),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LicenseCheckerScreen())),
                      ),
                      _buildToolCard(
                        title: 'Trách Nhiệm Chủ Xe',
                        subtitle: 'Giao xe, Quá tải (Đ.32)',
                        icon: Icons.supervised_user_circle_rounded,
                        color: const Color(0xFF43A047),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerLiabilityScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danh sách lỗi phổ biến
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Một số lỗi quan trọng NĐ 168 / 238',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF263238)),
              ),
            ),
            const SizedBox(height: 8),

            ...SeedDataLoader.getSeedOffenses().take(4).map((off) {
              return OffenseCard(
                offense: off,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OffenseDetailScreen(offense: off)),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
