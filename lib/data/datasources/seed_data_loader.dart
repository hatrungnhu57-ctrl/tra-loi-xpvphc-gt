import '../../domain/entities/offense.dart';
import '../../domain/entities/penalty.dart';
import '../../domain/entities/detention_rule.dart';
import '../../domain/entities/remedial_measure.dart';
import '../../domain/entities/exception_rule.dart';
import '../../domain/entities/related_offense.dart';
import '../../domain/enums/vehicle_type.dart';
import '../../domain/enums/subject_type.dart';
import '../../domain/enums/penalty_type.dart';
import '../../domain/enums/detention_target.dart';
import '../../domain/enums/legal_status.dart';

class SeedDataLoader {
  static List<Offense> getSeedOffenses() {
    final effectiveFrom2025 = DateTime(2025, 1, 1);
    final effectiveFrom2026 = DateTime(2026, 8, 15);

    return [
      // =========================================================================
      // 1. ĐIỀU 7: MÔ TÔ, XE GẮN MÁY VI PHẠM QUY TẮC GIAO THÔNG
      // =========================================================================

      // Điều 7 Khoản 2 Điểm g: Chở theo 02 người trên xe mô tô
      Offense(
        id: 'off_moto_007_02_g',
        offenseCode: 'MOTO-007-02-G',
        canonicalName: 'Chở theo 02 người trên xe mô tô, xe gắn máy',
        shortName: 'Chở 2 người trên xe máy',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Chở theo 02 người trên xe, trừ trường hợp chở người bệnh đi cấp cứu, trẻ em dưới 12 tuổi, người già yếu hoặc người khuyết tật, áp giải người có hành vi vi phạm pháp luật',
        primaryLegalRef: 'Điểm g Khoản 2 Điều 7',
        legalDocumentNumber: '168/2024/NĐ-CP',
        legalDocumentTitle: 'Nghị định 168/2024/NĐ-CP (sửa đổi bởi NĐ 238/2026/NĐ-CP)',
        penalties: [
          const Penalty(
            id: 'pen_moto_007_02_g',
            offenseId: 'off_moto_007_02_g',
            penaltyType: PenaltyType.fine,
            fineMin: 400000,
            fineMax: 600000,
          ),
        ],
        exceptions: [
          const ExceptionRule(
            id: 'exc_moto_007_02_g',
            offenseId: 'off_moto_007_02_g',
            exceptionCode: 'EXC_007_02_G',
            description: 'Chở người bệnh đi cấp cứu, trẻ em dưới 12 tuổi, người già yếu hoặc người khuyết tật, áp giải người có hành vi vi phạm pháp luật',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_moto_007_02_g',
            toOffenseId: 'MOTO-007-10-ACCIDENT',
            relationType: 'accident_variant',
            description: 'Gây tai nạn giao thông khi vi phạm Điểm g Khoản 2 Điều 7 bị phạt 10 - 14 triệu, trừ 10 điểm (Khoản 10 Điều 7)',
          ),
        ],
        aliases: ['chở 2', 'cho 2', 'chở 2 người', 'cho 2 nguoi', 'điểm g khoản 2 điều 7', 'diem g khoan 2 dieu 7', 'g.2.7'],
        tags: ['số người', 'chở quá người'],
        searchText: 'chở theo 02 người trên xe mô tô xe gắn máy điểm g khoản 2 điều 7 cho 2 nguoi kep 2',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'passenger_count', 'eq': 2},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 7 Khoản 3 Điểm b: Chở theo từ 03 người trở lên (Kẹp 3)
      Offense(
        id: 'off_moto_007_03_b',
        offenseCode: 'MOTO-007-03-B',
        canonicalName: 'Chở theo từ 03 người trở lên trên xe mô tô, xe gắn máy (kẹp 3)',
        shortName: 'Kẹp 3 xe máy',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Chở theo từ 03 người trở lên trên xe',
        primaryLegalRef: 'Điểm b Khoản 3 Điều 7',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_moto_007_03_b',
            offenseId: 'off_moto_007_03_b',
            penaltyType: PenaltyType.fine,
            fineMin: 600000,
            fineMax: 800000,
            points: 2,
            notes: 'Phạt tiền từ 600.000 đ đến 800.000 đ, trừ 02 điểm GPLX (Điểm a Khoản 13 Điều 7)',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_moto_007_03_b',
            toOffenseId: 'MOTO-007-10-ACCIDENT',
            relationType: 'accident_variant',
            description: 'Gây tai nạn giao thông khi vi phạm Điểm b Khoản 3 Điều 7 bị phạt 10 - 14 triệu, trừ 10 điểm (Khoản 10 Điều 7)',
          ),
        ],
        aliases: ['kẹp 3', 'kep 3', 'chở 3', 'cho 3', 'chở 3 người', 'kẹp ba', 'cho 3 nguoi', 'điểm b khoản 3 điều 7'],
        tags: ['kẹp 3', 'số người', 'chở 3'],
        searchText: 'chở theo từ 03 người trở lên trên xe mô tô xe gắn máy kẹp 3 kep 3 cho 3 nguoi điểm b khoản 3 điều 7',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'passenger_count', 'gte': 3},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 7 Khoản 2 Điểm h: Không đội mũ bảo hiểm
      Offense(
        id: 'off_moto_007_02_h',
        offenseCode: 'MOTO-007-02-H',
        canonicalName: 'Không đội mũ bảo hiểm cho người đi mô tô, xe máy',
        shortName: 'Không đội nón bảo hiểm',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Không đội “mũ bảo hiểm cho người đi mô tô, xe máy” hoặc đội “mũ bảo hiểm cho người đi mô tô, xe máy” không cài quai đúng quy cách khi điều khiển xe tham gia giao thông trên đường bộ',
        primaryLegalRef: 'Điểm h Khoản 2 Điều 7',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_moto_007_02_h',
            offenseId: 'off_moto_007_02_h',
            penaltyType: PenaltyType.fine,
            fineMin: 400000,
            fineMax: 600000,
          ),
        ],
        aliases: ['không nón', 'khong non', 'không mũ', 'khong mu', 'ko mu', 'ko non', 'mbh', 'không đội mũ', 'không đội nón', 'cài quai'],
        tags: ['mũ bảo hiểm', 'nón bảo hiểm'],
        searchText: 'không đội mũ bảo hiểm cho người đi mô tô xe máy không cài quai không nón ko mu mbh điểm h khoản 2 điều 7',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'has_helmet', 'eq': false},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 7 Khoản 8 Điểm b: Nồng độ cồn mô tô mức 2 (vượt 0.25 - 0.40 mg/L)
      Offense(
        id: 'off_moto_007_08_b',
        offenseCode: 'MOTO-007-08-B',
        canonicalName: 'Điều khiển xe mô tô trên đường mà trong máu hoặc hơi thở có nồng độ cồn vượt quá 50 - 80 mg/100ml máu hoặc vượt quá 0,25 - 0,4 mg/1L khí thở',
        shortName: 'Cồn mô tô mức 2 (0.25 - 0.40)',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Điều khiển xe trên đường mà trong máu hoặc hơi thở có nồng độ cồn vượt quá 50 miligam đến 80 miligam/100 mililít máu hoặc vượt quá 0,25 miligam đến 0,4 miligam/1 lít khí thở',
        primaryLegalRef: 'Điểm b Khoản 8 Điều 7',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_moto_007_08_b',
            offenseId: 'off_moto_007_08_b',
            penaltyType: PenaltyType.fine,
            fineMin: 6000000,
            fineMax: 8000000,
            points: 10,
            notes: 'Phạt tiền 6 - 8 triệu, trừ 10 điểm GPLX (Điểm d Khoản 13 Điều 7), tạm giữ xe (Khoản 1 Điểm b Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_moto_007_08_b',
            offenseId: 'off_moto_007_08_b',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm b Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        aliases: ['cồn 0.32', 'cồn 0.32 moto', 'con 0.32', 'thổi cồn xe máy', 'nồng độ cồn xe máy 0.3', 'điểm b khoản 8 điều 7'],
        tags: ['nồng độ cồn', 'thổi cồn'],
        searchText: 'nồng độ cồn mô tô xe máy vượt quá 0 25 den 0 4 mg l khí thở con 0 32 moto điểm b khoản 8 điều 7',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'alcohol_breath', 'gt': 0.25},
            {'field': 'alcohol_breath', 'lte': 0.40},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 7 Khoản 10: Gây tai nạn giao thông mô tô
      Offense(
        id: 'off_moto_007_10_accident',
        offenseCode: 'MOTO-007-10-ACCIDENT',
        canonicalName: 'Vi phạm quy tắc giao thông xe mô tô, xe gắn máy gây tai nạn giao thông',
        shortName: 'Xe máy gây TNGT',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Điều khiển xe không quan sát, giảm tốc độ hoặc vi phạm quy tắc giao thông mà gây tai nạn giao thông',
        primaryLegalRef: 'Khoản 10 Điều 7',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_moto_007_10_accident',
            offenseId: 'off_moto_007_10_accident',
            penaltyType: PenaltyType.fine,
            fineMin: 10000000,
            fineMax: 14000000,
            points: 10,
            notes: 'Phạt tiền 10 - 14 triệu, trừ 10 điểm GPLX (Điểm d Khoản 13 Điều 7)',
          ),
        ],
        aliases: ['xe máy gây tai nạn', 'xe may gay tngt', 'khoản 10 điều 7'],
        tags: ['tai nạn giao thông', 'TNGT'],
        searchText: 'xe mô tô xe máy gây tai nạn giao thông tngt khoản 10 điều 7',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'caused_accident', 'eq': true},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // =========================================================================
      // 2. ĐIỀU 6: Ô TÔ VI PHẠM QUY TẮC GIAO THÔNG
      // =========================================================================

      // Điều 6 Khoản 1a: Chở trẻ em dưới 10 tuổi cao dưới 1.35m (NĐ 238 bổ sung) -> CẢNH CÁO
      Offense(
        id: 'off_car_006_01a',
        offenseCode: 'CAR-006-01A',
        canonicalName: 'Chở trẻ em dưới 10 tuổi và chiều cao dưới 1,35 mét trên xe ô tô không sử dụng thiết bị an toàn phù hợp',
        shortName: 'Trẻ em dưới 10 tuổi không gh��� an toàn',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.car,
        description: 'Phạt cảnh cáo đối với người điều khiển xe ô tô thực hiện hành vi chở trẻ em dưới 10 tuổi và chiều cao dưới 1,35 mét trên xe mà không sử dụng thiết bị an toàn phù hợp cho trẻ em theo quy định (trừ xe ô tô kinh doanh vận tải hành khách)',
        primaryLegalRef: 'Khoản 1a Điều 6',
        legalDocumentNumber: '168/2024/NĐ-CP',
        sourceNote: 'Khoản này được bổ sung theo quy định tại Khoản 1 Điều 2 Nghị định số 238/2026/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_car_006_01a',
            offenseId: 'off_car_006_01a',
            penaltyType: PenaltyType.warning,
            isWarning: true,
            notes: 'Phạt cảnh cáo',
          ),
        ],
        aliases: ['trẻ em dưới 10 tuổi', 'ghế trẻ em', 'thiết bị an toàn trẻ em', 'khoản 1a điều 6'],
        tags: ['trẻ em', 'cảnh cáo'],
        searchText: 'chở trẻ em dưới 10 tuổi chiều cao dưới 1 35 mét không thiết bị an toàn khoản 1a điều 6',
        effectiveFrom: effectiveFrom2026,
        status: LegalStatus.active,
      ),

      // Điều 6 Khoản 5 Điểm đ: Ô tô chạy quá tốc độ từ 10 km/h đến 20 km/h (oto 76/60 -> quá 16km/h)
      Offense(
        id: 'off_car_006_05_de',
        offenseCode: 'CAR-006-05-DE',
        canonicalName: 'Điều khiển xe ô tô chạy quá tốc độ quy định từ 10 km/h đến 20 km/h',
        shortName: 'Ô tô quá tốc độ 10 - 20 km/h',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.car,
        description: 'Điều khiển xe chạy quá tốc độ quy định từ 10 km/h đến 20 km/h',
        primaryLegalRef: 'Điểm đ Khoản 5 Điều 6',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_car_006_05_de',
            offenseId: 'off_car_006_05_de',
            penaltyType: PenaltyType.fine,
            fineMin: 4000000,
            fineMax: 6000000,
            points: 2,
            notes: 'Phạt tiền từ 4.000.000 đ đến 6.000.000 đ, trừ 02 điểm GPLX (Điểm a Khoản 16 Điều 6)',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_car_006_05_de',
            toOffenseId: 'CAR-006-10-ACCIDENT',
            relationType: 'accident_variant',
            description: 'Gây tai nạn giao thông khi chạy quá tốc độ bị phạt 20 - 22 triệu, trừ 10 điểm (Khoản 10 Điều 6)',
          ),
        ],
        aliases: ['oto 76/60', 'ô tô quá tốc độ 10 20', 'oto qua toc do 16km', 'oto 76 60', 'điểm đ khoản 5 điều 6'],
        tags: ['tốc độ', 'quá tốc độ ô tô'],
        searchText: 'điều khiển xe ô tô chạy quá tốc độ quy định từ 10 km h đến 20 km h oto 76 60 điểm đ khoản 5 điều 6',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'car'},
            {'field': 'speed_excess', 'gte': 10},
            {'field': 'speed_excess', 'lte': 20},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 6 Khoản 10: Gây tai nạn giao thông ô tô
      Offense(
        id: 'off_car_006_10_accident',
        offenseCode: 'CAR-006-10-ACCIDENT',
        canonicalName: 'Vi phạm quy tắc giao thông xe ô tô gây tai nạn giao thông',
        shortName: 'Ô tô gây TNGT',
        categoryCode: 'RULES',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.car,
        description: 'Điều khiển xe không quan sát, giảm tốc độ hoặc vi phạm quy tắc giao thông mà gây tai nạn giao thông',
        primaryLegalRef: 'Khoản 10 Điều 6',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_car_006_10_accident',
            offenseId: 'off_car_006_10_accident',
            penaltyType: PenaltyType.fine,
            fineMin: 20000000,
            fineMax: 22000000,
            points: 10,
            notes: 'Phạt tiền 20 - 22 triệu, trừ 10 điểm GPLX (Điểm d Khoản 16 Điều 6)',
          ),
        ],
        aliases: ['ô tô gây tai nạn', 'oto gay tngt', 'khoản 10 điều 6'],
        tags: ['tai nạn giao thông', 'TNGT'],
        searchText: 'xe ô tô gây tai nạn giao thông tngt khoản 10 điều 6',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'car'},
            {'field': 'caused_accident', 'eq': true},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // =========================================================================
      // 3. ĐIỀU 18: ĐIỀU KIỆN NGƯỜI ĐIỀU KHIỂN (GPLX, TUỔI)
      // =========================================================================

      // Điều 18 Khoản 1: Người từ đủ 14 đến dưới 16 tuổi điều khiển xe -> CẢNH CÁO + TẠM GIỮ
      Offense(
        id: 'off_driver_018_01_age',
        offenseCode: 'DRIVER-018-01-AGE',
        canonicalName: 'Người từ đủ 14 tuổi đến dưới 16 tuổi điều khiển xe mô tô, xe gắn máy hoặc xe ô tô',
        shortName: 'Từ 14 đến dưới 16 tuổi lái xe',
        categoryCode: 'DRIVER',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.all,
        description: 'Phạt cảnh cáo người từ đủ 14 tuổi đến dưới 16 tuổi điều khiển xe mô tô, xe gắn máy, các loại xe tương tự xe mô tô và các loại xe tương tự xe gắn máy hoặc điều khiển xe ô tô',
        primaryLegalRef: 'Khoản 1 Điều 18',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_driver_018_01_age',
            offenseId: 'off_driver_018_01_age',
            penaltyType: PenaltyType.warning,
            isWarning: true,
            notes: 'Phạt cảnh cáo, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_driver_018_01_age',
            offenseId: 'off_driver_018_01_age',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm i Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        aliases: ['14 tuổi lái xe', '15 tuổi lái xe', 'chưa đủ tuổi lái xe', 'học sinh lái xe', 'khoản 1 điều 18'],
        tags: ['độ tuổi', 'cảnh cáo'],
        searchText: 'người từ đủ 14 tuổi đến dưới 16 tuổi điều khiển xe mô tô xe ô tô khoản 1 điều 18',
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 18 Khoản 5 Điểm a: Không có GPLX xe mô tô dung tích <= 125cm3 (2tr - 4tr)
      Offense(
        id: 'off_driver_018_05_a_under_125cc',
        offenseCode: 'DRIVER-018-05-A-UNDER-125CC',
        canonicalName: 'Không có giấy phép lái xe điều khiển xe mô tô hai bánh có dung tích xi-lanh đến 125 cm3 hoặc công suất điện đến 11 kW',
        shortName: 'Không GPLX xe máy <= 125cc',
        categoryCode: 'DRIVER',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Không có giấy phép lái xe hoặc sử dụng giấy phép lái xe đã bị trừ hết điểm hoặc sử dụng giấy phép lái xe không do cơ quan có thẩm quyền cấp, giấy phép lái xe bị tẩy xóa, giấy phép lái xe không còn hiệu lực',
        primaryLegalRef: 'Điểm a Khoản 5 Điều 18',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_driver_018_05_a',
            offenseId: 'off_driver_018_05_a_under_125cc',
            penaltyType: PenaltyType.fine,
            fineMin: 2000000,
            fineMax: 4000000,
            notes: 'Phạt tiền từ 2.000.000 đ đến 4.000.000 đ, tạm giữ xe (Khoản 1 Điểm i Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_driver_018_05_a',
            offenseId: 'off_driver_018_05_a_under_125cc',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm i Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_driver_018_05_a_under_125cc',
            toOffenseId: 'OWNER-032-10-MOTO-HANDOVER',
            relationType: 'owner_liability',
            description: 'Chủ xe giao xe cho người không đủ điều kiện bị phạt 8 - 10 triệu (Khoản 10 Điều 32)',
          ),
        ],
        aliases: ['không bằng xe 110', 'không có bằng lái xe 125cc', '125cc không bằng', 'k gplx 110cc', 'điểm a khoản 5 điều 18'],
        tags: ['GPLX', 'bằng lái'],
        searchText: 'không có giấy phép lái xe mô tô hai bánh dung tích đến 125 cm3 11kw điểm a khoản 5 điều 18',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'has_valid_license', 'eq': false},
            {'field': 'engine_cc', 'lte': 125},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 18 Khoản 7 Điểm b: Không có GPLX xe mô tô dung tích > 125cm3 (150cc...) -> 6tr - 8tr
      Offense(
        id: 'off_driver_018_07_b_over_125cc',
        offenseCode: 'DRIVER-018-07-B-OVER-125CC',
        canonicalName: 'Không có giấy phép lái xe điều khiển xe mô tô hai bánh có dung tích xi-lanh trên 125 cm3 (>125cc) hoặc công suất điện trên 11 kW',
        shortName: 'Không GPLX xe máy 150cc (>125cc)',
        categoryCode: 'DRIVER',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.motorcycle,
        description: 'Không có giấy phép lái xe hoặc sử dụng giấy phép lái xe đã bị trừ hết điểm, giấy phép lái xe không do cơ quan có thẩm quyền cấp, giấy phép lái xe bị tẩy xóa, giấy phép lái xe không còn hiệu lực đối với xe mô tô có dung tích xi-lanh trên 125 cm3 hoặc công suất động cơ điện trên 11 kW',
        primaryLegalRef: 'Điểm b Khoản 7 Điều 18',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_driver_018_07_b',
            offenseId: 'off_driver_018_07_b_over_125cc',
            penaltyType: PenaltyType.fine,
            fineMin: 6000000,
            fineMax: 8000000,
            notes: 'Phạt tiền từ 6.000.000 đ đến 8.000.000 đ, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_driver_018_07_b',
            offenseId: 'off_driver_018_07_b_over_125cc',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm i Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_driver_018_07_b_over_125cc',
            toOffenseId: 'OWNER-032-10-MOTO-HANDOVER',
            relationType: 'owner_liability',
            description: 'Chủ xe giao xe cho người không đủ điều kiện bị phạt 8 - 10 triệu (Khoản 10 Điều 32)',
          ),
        ],
        aliases: [
          'xe máy 150 không bằng',
          '150cc k gplx',
          '150cc không bằng',
          'xe 150cc khong bang',
          'không bằng xe 150',
          'sh150 không bằng',
          'exciter không bằng',
          'điểm b khoản 7 điều 18',
        ],
        tags: ['GPLX', '150cc', 'trên 125cc', 'bằng lái'],
        searchText: 'xe máy 150 không bằng 150cc k gplx không có giấy phép lái xe mô tô dung tích trên 125 cm3 điểm b khoản 7 điều 18',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'has_valid_license', 'eq': false},
            {'field': 'engine_cc', 'gt': 125},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 18 Khoản 9 Điểm b: Không có GPLX ô tô (18tr - 20tr)
      Offense(
        id: 'off_driver_018_09_b_car',
        offenseCode: 'DRIVER-018-09-B-CAR',
        canonicalName: 'Không có giấy phép lái xe điều khiển xe ô tô',
        shortName: 'Không GPLX ô tô',
        categoryCode: 'DRIVER',
        subjectType: SubjectType.driver,
        vehicleType: VehicleType.car,
        description: 'Không có giấy phép lái xe hoặc sử dụng giấy phép lái xe đã bị trừ hết điểm hoặc sử dụng giấy phép lái xe không do cơ quan có thẩm quyền cấp, giấy phép lái xe bị tẩy xóa, giấy phép lái xe không còn hiệu lực điều khiển xe ô tô',
        primaryLegalRef: 'Điểm b Khoản 9 Điều 18',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_driver_018_09_b_car',
            offenseId: 'off_driver_018_09_b_car',
            penaltyType: PenaltyType.fine,
            fineMin: 18000000,
            fineMax: 20000000,
            notes: 'Phạt tiền từ 18.000.000 đ đến 20.000.000 đ, tạm giữ phương tiện (Khoản 1 Điểm i Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_driver_018_09_b_car',
            offenseId: 'off_driver_018_09_b_car',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm i Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        relatedOffenses: [
          const RelatedOffense(
            fromOffenseId: 'off_driver_018_09_b_car',
            toOffenseId: 'OWNER-032-14-I-CAR-HANDOVER',
            relationType: 'owner_liability',
            description: 'Chủ xe ô tô giao xe cho người không đủ điều kiện bị phạt 28 - 30 triệu (cá nhân) / 56 - 60 triệu (tổ chức) (Khoản 14 Điểm i Điều 32)',
          ),
        ],
        aliases: ['không bằng lái ô tô', 'oto khong gplx', 'k gplx oto', 'điểm b khoản 9 điều 18'],
        tags: ['GPLX', 'ô tô', 'bằng lái'],
        searchText: 'không có giấy phép lái xe ô tô k gplx oto điểm b khoản 9 điều 18',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'car'},
            {'field': 'has_valid_license', 'eq': false},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // =========================================================================
      // 4. ĐIỀU 32: TRÁCH NHIỆM CHỦ PHƯƠNG TIỆN (GIAO XE CHO NGƯỜI KHÔNG ĐỦ ĐK)
      // =========================================================================

      // Điều 32 Khoản 10: Chủ xe mô tô giao xe cho người không đủ điều kiện
      Offense(
        id: 'off_owner_032_10_moto_handover',
        offenseCode: 'OWNER-032-10-MOTO-HANDOVER',
        canonicalName: 'Chủ xe mô tô giao xe hoặc để cho người không đủ điều kiện điều khiển xe tham gia giao thông',
        shortName: 'Giao xe máy cho người không bằng',
        categoryCode: 'OWNER',
        subjectType: SubjectType.ownerIndividual,
        vehicleType: VehicleType.motorcycle,
        description: 'Giao xe hoặc để cho người không đủ điều kiện theo quy định tại khoản 1 Điều 56 của Luật Trật tự, an toàn giao thông đường bộ điều khiển xe tham gia giao thông (bao gồm cả trường hợp người điều khiển có GPLX nhưng đang bị tước)',
        primaryLegalRef: 'Khoản 10 Điều 32',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_owner_032_10_moto',
            offenseId: 'off_owner_032_10_moto_handover',
            penaltyType: PenaltyType.fine,
            fineMin: 8000000,
            fineMax: 10000000,
            fineMinOrg: 16000000,
            fineMaxOrg: 20000000,
            notes: 'Cá nhân phạt 8 - 10 triệu, tổ chức phạt 16 - 20 triệu; tạm giữ phương tiện (Khoản 1 Điểm l Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_owner_032_10_moto',
            offenseId: 'off_owner_032_10_moto_handover',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm l Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        aliases: [
          'giao xe cho người không bằng',
          'giao xe cho nguoi khong bang',
          'cho mượn xe không bằng',
          'giao xe máy cho người chưa đủ tuổi',
          'chủ xe giao xe',
          'khoản 10 điều 32',
        ],
        tags: ['chủ xe', 'giao xe', 'chủ phương tiện'],
        searchText: 'giao xe cho người không bằng giao xe hoặc để cho người không đủ điều kiện điều khiển xe mô tô xe máy khoản 10 điều 32',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'motorcycle'},
            {'field': 'subject', 'in': ['owner_individual', 'owner_organization']},
            {'field': 'has_valid_license', 'eq': false},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),

      // Điều 32 Khoản 14 Điểm i: Chủ xe ô tô giao xe cho người không đủ điều kiện
      Offense(
        id: 'off_owner_032_14_i_car_handover',
        offenseCode: 'OWNER-032-14-I-CAR-HANDOVER',
        canonicalName: 'Chủ xe ô tô giao xe hoặc để cho người không đủ điều kiện điều khiển xe tham gia giao thông',
        shortName: 'Giao ô tô cho người không bằng',
        categoryCode: 'OWNER',
        subjectType: SubjectType.ownerIndividual,
        vehicleType: VehicleType.car,
        description: 'Giao xe hoặc để cho người không đủ điều kiện theo quy định tại khoản 1 Điều 56 của Luật Trật tự, an toàn giao thông đường bộ điều khiển xe tham gia giao thông (bao gồm cả trường hợp người điều khiển có GPLX nhưng đã hết hạn hoặc đang bị tước)',
        primaryLegalRef: 'Điểm i Khoản 14 Điều 32',
        legalDocumentNumber: '168/2024/NĐ-CP',
        penalties: [
          const Penalty(
            id: 'pen_owner_032_14_i_car',
            offenseId: 'off_owner_032_14_i_car_handover',
            penaltyType: PenaltyType.fine,
            fineMin: 28000000,
            fineMax: 30000000,
            fineMinOrg: 56000000,
            fineMaxOrg: 60000000,
            notes: 'Cá nhân phạt 28 - 30 triệu, tổ chức phạt 56 - 60 triệu; tạm giữ phương tiện (Khoản 1 Điểm l Điều 48)',
          ),
        ],
        detentionRules: [
          const DetentionRule(
            id: 'det_owner_032_14_i_car',
            offenseId: 'off_owner_032_14_i_car_handover',
            detentionTarget: DetentionTarget.vehicle,
            legalBasisText: 'Khoản 1 Điểm l Điều 48',
            note: 'Tạm giữ phương tiện để ngăn chặn ngay hành vi vi phạm',
          ),
        ],
        aliases: [
          'giao xe ô tô cho người không bằng',
          'giao oto cho nguoi khong bang',
          'cho mượn ô tô không bằng',
          'chủ ô tô giao xe',
          'điểm i khoản 14 điều 32',
        ],
        tags: ['chủ xe', 'giao xe', 'ô tô'],
        searchText: 'giao xe ô tô cho người không bằng giao xe hoặc để cho người không đủ điều kiện điều khiển ô tô điểm i khoản 14 điều 32',
        conditionJson: {
          'all': [
            {'field': 'vehicle.group', 'eq': 'car'},
            {'field': 'subject', 'in': ['owner_individual', 'owner_organization']},
            {'field': 'has_valid_license', 'eq': false},
          ]
        },
        effectiveFrom: effectiveFrom2025,
        status: LegalStatus.active,
      ),
    ];
  }
}
