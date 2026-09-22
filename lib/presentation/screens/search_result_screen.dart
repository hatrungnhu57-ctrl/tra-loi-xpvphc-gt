import 'package:flutter/material.dart';
import '../../engine/search/search_engine.dart';
import '../widgets/offense_card.dart';
import 'offense_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final SearchResponse searchResponse;

  const SearchResultScreen({super.key, required this.searchResponse});

  @override
  Widget build(BuildContext context) {
    final eval = searchResponse.caseEvaluation;
    final results = searchResponse.results;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text('Kết quả: "${searchResponse.intent.rawQuery}"'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy hành vi phù hợp',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng thử lại với từ khóa khác như "xe máy 150 không bằng", "oto 76/60", "kẹp 3"...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Case Summary Box if available
                if (eval != null && eval.matchedOffenses.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.gavel_rounded, color: Color(0xFF1A237E), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ĐÁNH GIÁ TỔNG HỢP VỤ VIỆC',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          'Mức phạt cá nhân: ${eval.individualFineSummary}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFC62828)),
                        ),
                        if (eval.totalFineMinOrganization > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Mức phạt tổ chức: ${eval.organizationFineSummary}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                          ),
                        ],
                        if (eval.hasLicenseSuspension) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Tước quyền sử dụng GPLX: ${eval.maxSuspensionMonthsMin?.toInt()} - ${eval.maxSuspensionMonthsMax?.toInt()} tháng (${eval.suspensionLegalBasis})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6A1B9A)),
                          ),
                        ],
                        if (eval.maxPointsDeducted != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Trừ điểm GPLX: ${eval.maxPointsDeducted} điểm (Điểm b Khoản 1 Điều 50)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD32F2F)),
                          ),
                        ],
                        if (eval.activeDetentions.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Tạm giữ: ${eval.activeDetentions.map((d) => d.detentionTarget.label).toSet().join(", ")} (${eval.activeDetentions.first.legalBasisText})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE65100)),
                          ),
                        ],
                        if (eval.legalExplanations.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...eval.legalExplanations.map((exp) => Text(
                                '• $exp',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF37474F)),
                              )),
                        ],
                      ],
                    ),
                  ),

                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Các hành vi vi phạm xác định (${results.length}):',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF455A64)),
                  ),
                ),

                // Offense Cards
                ...results.map((r) {
                  return OffenseCard(
                    offense: r.offense,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OffenseDetailScreen(offense: r.offense),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
