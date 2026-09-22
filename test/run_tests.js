// Verification Runner in Node.js for Tra Lỗi GT Pro Core Engine & Test Suite
const assert = require('assert');

// 1. Text Normalizer
class TextNormalizer {
  static removeDiacritics(input) {
    if (!input) return '';
    return input
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/[đĐ]/g, 'd');
  }

  static normalize(input) {
    if (!input || !input.trim()) return '';
    let text = input.trim().toLowerCase();
    text = text.replace(/[,;!?()"\x27\[\]{}]/g, ' ');
    text = text.replace(/(?<![a-zA-Z0-9])\.|\.(?![a-zA-Z0-9])/g, ' ');
    text = text.replace(/\s+/g, ' ').trim();
    return text;
  }
}

// 2. Citation Parser
class CitationParser {
  static parse(input) {
    if (!input || !input.trim()) return null;
    const rawTrimmed = input.trim().toLowerCase();
    const rawUnaccented = TextNormalizer.removeDiacritics(rawTrimmed);

    // Pattern Dot Shorthand: "g.2.7"
    const pDot = /^([a-zd])\.([0-9]+[a-z]?)\.([0-9]+)$/i;
    const mDot = rawUnaccented.match(pDot);
    if (mDot) {
      return { pointNo: mDot[1].toLowerCase(), clauseNo: mDot[2].toLowerCase(), articleNo: parseInt(mDot[3], 10) };
    }

    const norm = TextNormalizer.normalize(input);
    const unaccented = TextNormalizer.removeDiacritics(norm);

    // Pattern Space: "g 2 7"
    const pSpace = /^([a-zd])\s+([0-9]+[a-z]?)\s+([0-9]+)$/i;
    const mSpace = unaccented.match(pSpace);
    if (mSpace) {
      return { pointNo: mSpace[1].toLowerCase(), clauseNo: mSpace[2].toLowerCase(), articleNo: parseInt(mSpace[3], 10) };
    }

    // Pattern 1: "điểm g khoản 2 điều 7"
    const p1 = /diem\s+([a-zd])\s+khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)/i;
    const m1 = unaccented.match(p1);
    if (m1) {
      return { pointNo: m1[1].toLowerCase(), clauseNo: m1[2].toLowerCase(), articleNo: parseInt(m1[3], 10) };
    }

    // Pattern 2: "khoản 2 điều 7"
    const p2 = /khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)/i;
    const m2 = unaccented.match(p2);
    if (m2) {
      return { clauseNo: m2[1].toLowerCase(), articleNo: parseInt(m2[2], 10) };
    }

    // Pattern 3: "điều 32 khoản 7"
    const p3 = /dieu\s+([0-9]+)\s+khoan\s+([0-9]+[a-z]?)/i;
    const m3 = unaccented.match(p3);
    if (m3) {
      return { articleNo: parseInt(m3[1], 10), clauseNo: m3[2].toLowerCase() };
    }

    // Pattern 4: "k2 d7 g"
    const p4 = /k\.?\s*([0-9]+[a-z]?)\s*d\.?\s*([0-9]+)(?:\s*([a-zd]))?/i;
    const m4 = unaccented.match(p4);
    if (m4) {
      return { clauseNo: m4[1].toLowerCase(), articleNo: parseInt(m4[2], 10), pointNo: m4[3] ? m4[3].toLowerCase() : undefined };
    }

    return null;
  }
}

// 3. Intent & Fact Extractor
class IntentFactExtractor {
  static extract(rawQuery) {
    const norm = TextNormalizer.normalize(rawQuery);
    const unaccented = TextNormalizer.removeDiacritics(norm);
    const citation = CitationParser.parse(rawQuery);

    let vehicle = null;
    if (/\b(o\s*to|oto|xe\s*hoi|xe\s*tai)\b/i.test(unaccented)) {
      vehicle = 'car';
    } else if (/\b(xe\s*may|mo\s*to|moto|150cc|125cc|110cc)\b/i.test(unaccented)) {
      vehicle = 'motorcycle';
    }

    let engineCc = null;
    const ccMatch = unaccented.match(/\b([0-9]{2,4})\s*(?:cc|cm3)?\b/);
    if (ccMatch && !unaccented.includes('/')) {
      const val = parseFloat(ccMatch[1]);
      if ([50, 110, 125, 135, 150, 155, 160, 175].includes(val) || val >= 200) {
        engineCc = val;
        vehicle = vehicle || 'motorcycle';
      }
    }

    let hasValidLicense = null;
    if (/\b(khong\s*(?:co\s*)?(?:bang|gplx|blx)|k\s*(?:co\s*)?(?:bang|gplx)|khong\s*bang|k\s*gplx|ko\s*bang)\b/i.test(unaccented)) {
      hasValidLicense = false;
    }

    let speedMeasured = null;
    let speedLimit = null;
    let speedExcess = null;
    const slashSpeed = unaccented.match(/\b([0-9]{2,3})\s*\/\s*([0-9]{2,3})\b/);
    if (slashSpeed) {
      speedMeasured = parseFloat(slashSpeed[1]);
      speedLimit = parseFloat(slashSpeed[2]);
      speedExcess = speedMeasured - speedLimit;
    }

    let alcoholBreath = null;
    const breathMatch = unaccented.match(/\b(?:con|ndc)?\s*(0\.[0-9]{1,3})\b/);
    if (breathMatch) {
      alcoholBreath = parseFloat(breathMatch[1]);
    }

    let passengerCount = null;
    if (/\b(kep\s*3|cho\s*3|cho\s*3\s*nguoi|3\s*nguoi)\b/i.test(unaccented)) {
      passengerCount = 3;
      vehicle = vehicle || 'motorcycle';
    } else if (/\b(kep\s*2|cho\s*2|cho\s*2\s*nguoi|2\s*nguoi)\b/i.test(unaccented)) {
      passengerCount = 2;
      vehicle = vehicle || 'motorcycle';
    }

    let isOwner = /\b(giao\s*xe|chu\s*xe|cho\s*muon\s*xe)\b/i.test(unaccented);
    if (unaccented.includes('giao xe') && (unaccented.includes('khong bang') || unaccented.includes('k bang') || unaccented.includes('k gplx'))) {
      isOwner = true;
      hasValidLicense = false;
    }

    return {
      rawQuery,
      normalizedQuery: norm,
      vehicleType: vehicle,
      subjectType: isOwner ? 'owner_individual' : 'driver',
      citation,
      speedMeasured,
      speedLimit,
      speedExcess,
      alcoholBreathMgL: alcoholBreath,
      engineCc,
      passengerCount,
      hasValidLicense,
      isOwnerLiabilityLookup: isOwner,
    };
  }
}

// 4. Calculators
class SpeedCalculator {
  static evaluate(measured, limit, vehicle) {
    const excess = measured - limit;
    if (excess < 5) return null;

    if (vehicle === 'car') {
      if (excess >= 5 && excess < 10) return { bracket: '5-<10', legalRef: 'Điểm a Khoản 3 Điều 6', fineMin: 800000, fineMax: 1000000, points: null };
      if (excess >= 10 && excess <= 20) return { bracket: '10-20', legalRef: 'Điểm đ Khoản 5 Điều 6', fineMin: 4000000, fineMax: 6000000, points: 2 };
      if (excess > 20 && excess <= 35) return { bracket: '20-35', legalRef: 'Điểm a Khoản 6 Điều 6', fineMin: 6000000, fineMax: 8000000, points: 4 };
      return { bracket: '>35', legalRef: 'Điểm a Khoản 7 Điều 6', fineMin: 12000000, fineMax: 14000000, points: 6 };
    } else {
      if (excess >= 5 && excess < 10) return { bracket: '5-<10', legalRef: 'Điểm b Khoản 2 Điều 7', fineMin: 400000, fineMax: 600000, points: null };
      if (excess >= 10 && excess <= 20) return { bracket: '10-20', legalRef: 'Điểm a Khoản 4 Điều 7', fineMin: 800000, fineMax: 1000000, points: null };
      return { bracket: '>20', legalRef: 'Điểm a Khoản 8 Điều 7', fineMin: 6000000, fineMax: 8000000, points: 4 };
    }
  }
}

class AlcoholCalculator {
  static evaluate(breath, vehicle) {
    if (!breath) return null;
    let level = 1;
    if (breath > 0.40) level = 3;
    else if (breath > 0.25) level = 2;

    if (vehicle === 'car') {
      if (level === 1) return { level: 1, legalRef: 'Điểm c Khoản 6 Điều 6', fineMin: 6000000, fineMax: 8000000, points: 4, detention: true };
      if (level === 2) return { level: 2, legalRef: 'Điểm a Khoản 9 Điều 6', fineMin: 18000000, fineMax: 20000000, points: 10, detention: true };
      return { level: 3, legalRef: 'Điểm a Khoản 11 & Điểm c Khoản 15 Điều 6', fineMin: 30000000, fineMax: 40000000, suspensionMin: 22, detention: true };
    } else {
      if (level === 1) return { level: 1, legalRef: 'Điểm a Khoản 6 Điều 7', fineMin: 2000000, fineMax: 3000000, points: 4, detention: true };
      if (level === 2) return { level: 2, legalRef: 'Điểm b Khoản 8 Điều 7', fineMin: 6000000, fineMax: 8000000, points: 10, detention: true };
      return { level: 3, legalRef: 'Điểm d Khoản 9 & Điểm c Khoản 12 Điều 7', fineMin: 8000000, fineMax: 10000000, suspensionMin: 22, detention: true };
    }
  }
}

class LicenseChecker {
  static evaluate(vehicle, engineCc) {
    if (vehicle === 'car') {
      return { legalRef: 'Điểm b Khoản 9 Điều 18', fineMin: 18000000, fineMax: 20000000, detention: true };
    } else {
      if (engineCc && engineCc > 125) {
        return { legalRef: 'Điểm b Khoản 7 Điều 18', fineMin: 6000000, fineMax: 8000000, detention: true };
      } else {
        return { legalRef: 'Điểm a Khoản 5 Điều 18', fineMin: 2000000, fineMax: 4000000, detention: true };
      }
    }
  }
}

class OwnerLiabilityResolver {
  static resolveHandover(vehicle) {
    if (vehicle === 'car') {
      return { legalRef: 'Điểm i Khoản 14 Điều 32', fineMinInd: 28000000, fineMaxInd: 30000000, fineMinOrg: 56000000, fineMaxOrg: 60000000, detention: true };
    } else {
      return { legalRef: 'Khoản 10 Điều 32', fineMinInd: 8000000, fineMaxInd: 10000000, fineMinOrg: 16000000, fineMaxOrg: 20000000, detention: true };
    }
  }
}

// 5. Seed Offenses Database
const SEED_OFFENSES = [
  {
    id: 'off_1',
    code: 'MOTO-007-02-G',
    canonical: 'Chở theo 02 người trên xe mô tô, xe gắn máy',
    primaryRef: 'Điểm g Khoản 2 Điều 7',
    vehicle: 'motorcycle',
    fineMin: 400000,
    fineMax: 600000,
    aliases: ['chở 2', 'cho 2', 'điểm g khoản 2 điều 7', 'diem g khoan 2 dieu 7', 'g.2.7'],
    searchText: 'chở theo 02 người trên xe mô tô xe gắn máy điểm g khoản 2 điều 7',
  },
  {
    id: 'off_2',
    code: 'MOTO-007-03-B',
    canonical: 'Chở theo từ 03 người trở lên trên xe mô tô, xe gắn máy (kẹp 3)',
    primaryRef: 'Điểm b Khoản 3 Điều 7',
    vehicle: 'motorcycle',
    fineMin: 600000,
    fineMax: 800000,
    points: 2,
    aliases: ['kẹp 3', 'kep 3', 'chở 3', 'cho 3', 'chở 3 người', 'điểm b khoản 3 điều 7'],
    searchText: 'chở theo từ 03 người trở lên trên xe mô tô xe gắn máy kẹp 3 điểm b khoản 3 điều 7',
  },
  {
    id: 'off_3',
    code: 'MOTO-007-08-B',
    canonical: 'Nồng độ cồn xe mô tô vượt quá 50 - 80 mg/100ml hoặc > 0.25 - 0.40 mg/1L',
    primaryRef: 'Điểm b Khoản 8 Điều 7',
    vehicle: 'motorcycle',
    fineMin: 6000000,
    fineMax: 8000000,
    points: 10,
    detention: true,
    aliases: ['cồn 0.32 moto', 'cồn 0.32', 'thổi cồn xe máy'],
    searchText: 'nồng độ cồn mô tô xe máy 0 25 0 4 cồn 0.32 moto điểm b khoản 8 điều 7',
  },
  {
    id: 'off_4',
    code: 'CAR-006-05-DE',
    canonical: 'Điều khiển xe ô tô chạy quá tốc độ quy định từ 10 km/h đến 20 km/h',
    primaryRef: 'Điểm đ Khoản 5 Điều 6',
    vehicle: 'car',
    fineMin: 4000000,
    fineMax: 6000000,
    points: 2,
    aliases: ['oto 76/60', 'oto 76 60', 'quá tốc độ ô tô 10 20'],
    searchText: 'điều khiển xe ô tô chạy quá tốc độ từ 10 đến 20 km h oto 76 60 điểm đ khoản 5 điều 6',
  },
  {
    id: 'off_5',
    code: 'DRIVER-018-07-B-OVER-125CC',
    canonical: 'Không có GPLX điều khiển xe mô tô có dung tích xi lanh trên 125 cm3 (>125cc)',
    primaryRef: 'Điểm b Khoản 7 Điều 18',
    vehicle: 'motorcycle',
    fineMin: 6000000,
    fineMax: 8000000,
    detention: true,
    aliases: ['xe máy 150 không bằng', '150cc k gplx', '150cc không bằng'],
    searchText: 'xe máy 150 không bằng 150cc k gplx không có gplx mô tô trên 125cm3 điểm b khoản 7 điều 18',
  },
  {
    id: 'off_6',
    code: 'DRIVER-018-05-A-UNDER-125CC',
    canonical: 'Không có GPLX điều khiển xe mô tô có dung tích xi lanh đến 125 cm3 (<=125cc)',
    primaryRef: 'Điểm a Khoản 5 Điều 18',
    vehicle: 'motorcycle',
    fineMin: 2000000,
    fineMax: 4000000,
    detention: true,
    aliases: ['110cc không bằng', 'không bằng xe 110'],
    searchText: 'không có gplx mô tô đến 125 cm3 điểm a khoản 5 điều 18',
  },
  {
    id: 'off_7',
    code: 'OWNER-032-10-MOTO-HANDOVER',
    canonical: 'Chủ xe mô tô giao xe hoặc để cho người không đủ điều kiện điều khiển xe',
    primaryRef: 'Khoản 10 Điều 32',
    vehicle: 'motorcycle',
    fineMin: 8000000,
    fineMax: 10000000,
    fineMinOrg: 16000000,
    fineMaxOrg: 20000000,
    detention: true,
    aliases: ['giao xe cho người không bằng', 'giao xe cho nguoi khong bang', 'chủ xe giao xe'],
    searchText: 'giao xe cho người không bằng giao xe cho người không đủ điều kiện khoản 10 điều 32',
  }
];

// 6. Case Aggregator & Incident Report
class CaseAggregator {
  static aggregate(offenses) {
    let totalFineMin = 0;
    let totalFineMax = 0;
    let maxPoints = 0;
    let maxPointsBasis = '';
    let detentions = [];

    for (const off of offenses) {
      totalFineMin += off.fineMin || 0;
      totalFineMax += off.fineMax || 0;
      if (off.points && off.points > maxPoints) {
        maxPoints = off.points;
        maxPointsBasis = off.primaryRef;
      }
      if (off.detention) {
        detentions.push(`Phương tiện (${off.primaryRef})`);
      }
    }

    return {
      totalFineMin,
      totalFineMax,
      maxPointsDeducted: maxPoints > 0 ? maxPoints : null,
      maxPointsBasis: maxPointsBasis || null,
      detentions,
    };
  }
}

class IncidentReport {
  static formatVND(amount) {
    if (amount >= 1000000) {
      const trieu = amount / 1000000;
      return trieu === Math.floor(trieu) ? `${trieu} triệu` : `${trieu.toFixed(1)} triệu`;
    }
    return `${amount.toLocaleString()} VNĐ`;
  }

  static generateMinutes({ violatorName, licensePlate, offenses }) {
    const agg = CaseAggregator.aggregate(offenses);
    let output = `BIÊN BẢN VI PHẠM HÀNH CHÍNH\n`;
    output += `Đối tượng: ${violatorName || 'Chưa rõ'} - Biển số: ${licensePlate || 'Chưa rõ'}\n`;
    output += `Hành vi vi phạm (${offenses.length}):\n`;
    offenses.forEach((o, i) => {
      output += `${i + 1}. ${o.canonical} (${o.primaryRef})\n`;
    });
    output += `Tổng tiền phạt: ${IncidentReport.formatVND(agg.totalFineMin)} - ${IncidentReport.formatVND(agg.totalFineMax)} đồng\n`;
    if (agg.maxPointsDeducted) {
      output += `Trừ điểm GPLX: ${agg.maxPointsDeducted} điểm (Điểm b Khoản 1 Điều 50: theo ${agg.maxPointsBasis})\n`;
    }
    if (agg.detentions.length > 0) {
      output += `Tạm giữ: ${agg.detentions.join(', ')} theo Khoản 1 Điều 48\n`;
    }
    return output;
  }
}

// 7. Search Engine
class SearchEngine {
  constructor(db) {
    this.db = db;
  }

  search(query) {
    const intent = IntentFactExtractor.extract(query);
    const results = [];

    // Citation
    if (intent.citation) {
      const c = intent.citation;
      for (const off of this.db) {
        if (c.articleNo && off.primaryRef.includes(`Điều ${c.articleNo}`)) {
          if (c.clauseNo && off.primaryRef.includes(`Khoản ${c.clauseNo}`)) {
            if (!c.pointNo || off.primaryRef.toLowerCase().includes(`điểm ${c.pointNo}`)) {
              results.push({ offense: off, score: 500, reason: `Khớp trích dẫn: ${off.primaryRef}` });
            }
          }
        }
      }
    }

    // Speed
    if ((intent.speedExcess !== null || intent.speedMeasured !== null) && results.length === 0) {
      const v = intent.vehicleType || 'motorcycle';
      const speedRes = SpeedCalculator.evaluate(intent.speedMeasured || (50 + (intent.speedExcess || 0)), intent.speedLimit || 50, v);
      if (speedRes) {
        for (const off of this.db) {
          if (off.primaryRef.includes(speedRes.legalRef)) {
            results.push({ offense: off, score: 400, reason: `Khớp khung tốc độ: ${speedRes.bracket} (${speedRes.legalRef})` });
          }
        }
      }
    }

    // Alcohol
    if (intent.alcoholBreathMgL !== null && results.length === 0) {
      const v = intent.vehicleType || 'motorcycle';
      const alcRes = AlcoholCalculator.evaluate(intent.alcoholBreathMgL, v);
      if (alcRes) {
        for (const off of this.db) {
          if (off.primaryRef.includes(alcRes.legalRef)) {
            results.push({ offense: off, score: 400, reason: `Khớp khung cồn: Mức ${alcRes.level} (${alcRes.legalRef})` });
          }
        }
      }
    }

    // License
    if (intent.hasValidLicense === false && !intent.isOwnerLiabilityLookup && results.length === 0) {
      const v = intent.vehicleType || 'motorcycle';
      const licRes = LicenseChecker.evaluate(v, intent.engineCc);
      for (const off of this.db) {
        if (off.primaryRef.includes(licRes.legalRef)) {
          results.push({ offense: off, score: 400, reason: `Khớp quy định GPLX (${licRes.legalRef})` });
        }
      }
    }

    // Owner Handover
    if (intent.isOwnerLiabilityLookup && intent.hasValidLicense === false && results.length === 0) {
      const v = intent.vehicleType || 'motorcycle';
      const ownerRes = OwnerLiabilityResolver.resolveHandover(v);
      for (const off of this.db) {
        if (off.primaryRef.includes(ownerRes.legalRef)) {
          results.push({ offense: off, score: 400, reason: `Khớp trách nhiệm chủ phương tiện: ${ownerRes.legalRef}` });
        }
      }
    }

    // Passenger count
    if (intent.passengerCount !== null && results.length === 0) {
      for (const off of this.db) {
        if (intent.passengerCount >= 3 && off.code === 'MOTO-007-03-B') {
          results.push({ offense: off, score: 400, reason: 'Khớp kẹp 3 mô tô (Điểm b Khoản 3 Điều 7)' });
        } else if (intent.passengerCount === 2 && off.code === 'MOTO-007-02-G') {
          results.push({ offense: off, score: 400, reason: 'Khớp chở 2 người mô tô (Điểm g Khoản 2 Điều 7)' });
        }
      }
    }

    // Keyword / Alias Fallback
    if (results.length === 0) {
      const qNorm = TextNormalizer.removeDiacritics(intent.normalizedQuery);
      for (const off of this.db) {
        for (const alias of off.aliases) {
          if (qNorm.includes(TextNormalizer.removeDiacritics(alias))) {
            results.push({ offense: off, score: 100, reason: 'Khớp alias' });
            break;
          }
        }
      }
    }

    return { intent, results };
  }
}

// ==========================================
// TEST EXECUTION
// ==========================================
console.log('--- STARTING VERIFICATION TEST SUITE ---');

const engine = new SearchEngine(SEED_OFFENSES);

// Test 1: Citation Parser
{
  const c1 = CitationParser.parse('điểm g khoản 2 điều 7');
  assert.strictEqual(c1.pointNo, 'g');
  assert.strictEqual(c1.clauseNo, '2');
  assert.strictEqual(c1.articleNo, 7);
  console.log('✔ Test 1: Citation "điểm g khoản 2 điều 7" parsed correctly');

  const c2 = CitationParser.parse('g.2.7');
  assert.strictEqual(c2.pointNo, 'g');
  assert.strictEqual(c2.clauseNo, '2');
  assert.strictEqual(c2.articleNo, 7);
  console.log('✔ Test 2: Citation shorthand "g.2.7" parsed correctly');

  const c3 = CitationParser.parse('k2 d7 g');
  assert.strictEqual(c3.pointNo, 'g');
  assert.strictEqual(c3.clauseNo, '2');
  assert.strictEqual(c3.articleNo, 7);
  console.log('✔ Test 3: Citation shorthand "k2 d7 g" parsed correctly');
}

// Test 2: Required Query 1 - "xe máy 150 không bằng"
{
  const res = engine.search('xe máy 150 không bằng');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'DRIVER-018-07-B-OVER-125CC');
  assert.strictEqual(top.primaryRef, 'Điểm b Khoản 7 Điều 18');
  assert.strictEqual(top.fineMin, 6000000);
  assert.strictEqual(top.fineMax, 8000000);
  assert.strictEqual(top.detention, true);
  console.log('✔ Test 4: Query "xe máy 150 không bằng" -> Điểm b Khoản 7 Điều 18 (6-8tr, tạm giữ xe)');
}

// Test 3: Required Query 2 - "150cc k gplx"
{
  const res = engine.search('150cc k gplx');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'DRIVER-018-07-B-OVER-125CC');
  assert.strictEqual(top.primaryRef, 'Điểm b Khoản 7 Điều 18');
  console.log('✔ Test 5: Query "150cc k gplx" -> Điểm b Khoản 7 Điều 18');
}

// Test 4: Required Query 3 - "oto 76/60"
{
  const res = engine.search('oto 76/60');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'CAR-006-05-DE');
  assert.strictEqual(top.primaryRef, 'Điểm đ Khoản 5 Điều 6');
  assert.strictEqual(top.fineMin, 4000000);
  assert.strictEqual(top.fineMax, 6000000);
  assert.strictEqual(top.points, 2);
  console.log('✔ Test 6: Query "oto 76/60" (vượt 16km/h) -> Điểm đ Khoản 5 Điều 6 (4-6tr, trừ 2 điểm)');
}

// Test 5: Required Query 4 - "cồn 0.32 moto"
{
  const res = engine.search('cồn 0.32 moto');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'MOTO-007-08-B');
  assert.strictEqual(top.primaryRef, 'Điểm b Khoản 8 Điều 7');
  assert.strictEqual(top.fineMin, 6000000);
  assert.strictEqual(top.fineMax, 8000000);
  assert.strictEqual(top.points, 10);
  assert.strictEqual(top.detention, true);
  console.log('✔ Test 7: Query "cồn 0.32 moto" -> Điểm b Khoản 8 Điều 7 (6-8tr, trừ 10 điểm, tạm giữ xe)');
}

// Test 6: Required Query 5 - "kẹp 3"
{
  const res = engine.search('kẹp 3');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'MOTO-007-03-B');
  assert.strictEqual(top.primaryRef, 'Điểm b Khoản 3 Điều 7');
  assert.strictEqual(top.fineMin, 600000);
  assert.strictEqual(top.fineMax, 800000);
  assert.strictEqual(top.points, 2);
  console.log('✔ Test 8: Query "kẹp 3" -> Điểm b Khoản 3 Điều 7 (600-800k, trừ 2 điểm)');
}

// Test 7: Required Query 6 - "giao xe cho người không bằng"
{
  const res = engine.search('giao xe cho người không bằng');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'OWNER-032-10-MOTO-HANDOVER');
  assert.strictEqual(top.primaryRef, 'Khoản 10 Điều 32');
  assert.strictEqual(top.fineMin, 8000000);
  assert.strictEqual(top.fineMax, 10000000);
  assert.strictEqual(top.fineMinOrg, 16000000);
  assert.strictEqual(top.fineMaxOrg, 20000000);
  assert.strictEqual(top.detention, true);
  console.log('✔ Test 9: Query "giao xe cho người không bằng" -> Khoản 10 Điều 32 (8-10tr cá nhân, 16-20tr tổ chức, tạm giữ xe)');
}

// Test 8: Required Query 7 - "điểm g khoản 2 điều 7"
{
  const res = engine.search('điểm g khoản 2 điều 7');
  assert.ok(res.results.length > 0, 'Must return results');
  const top = res.results[0].offense;
  assert.strictEqual(top.code, 'MOTO-007-02-G');
  assert.strictEqual(top.primaryRef, 'Điểm g Khoản 2 Điều 7');
  assert.strictEqual(top.fineMin, 400000);
  assert.strictEqual(top.fineMax, 600000);
  console.log('✔ Test 10: Query "điểm g khoản 2 điều 7" -> Điểm g Khoản 2 Điều 7 (400-600k)');
}

// Test 9: TTKS Incident Report & Highest Points Aggregation Test
{
  const offKep3 = SEED_OFFENSES.find(o => o.code === 'MOTO-007-03-B'); // trừ 2 điểm
  const offCon = SEED_OFFENSES.find(o => o.code === 'MOTO-007-08-B');  // trừ 10 điểm
  const minutes = IncidentReport.generateMinutes({
    violatorName: 'NGUYỄN VĂN A',
    licensePlate: '29B1-999.99',
    offenses: [offKep3, offCon],
  });
  assert.ok(minutes.includes('NGUYỄN VĂN A'));
  assert.ok(minutes.includes('29B1-999.99'));
  assert.ok(minutes.includes('6.6 triệu - 8.8 triệu đồng'));
  assert.ok(minutes.includes('Trừ điểm GPLX: 10 điểm (Điểm b Khoản 1 Điều 50: theo Điểm b Khoản 8 Điều 7)'));
  assert.ok(minutes.includes('Tạm giữ: Phương tiện (Điểm b Khoản 8 Điều 7) theo Khoản 1 Điều 48'));
  console.log('✔ Test 11: TTKS Incident Report generation with highest points deduction & detention verified');
}

console.log('\n--- ALL 11 TEST SUITES PASSED SUCCESSFULLY! ---');
