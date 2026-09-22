import re

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'r', encoding='utf-8') as f:
    app = f.read()

# Enhance performSearch with Smart Semantic Matchers
search_enhancements = '''
  // 10. Rơi vãi / Bạt / Bùn đất (Điều 17 & Điều 36)
  if (matched.length === 0 && (unaccented.includes('roi vai') || unaccented.includes('roi') || unaccented.includes('che bat') || unaccented.includes('bun dat') || unaccented.includes('vat lieu') || unaccented.includes('do rac'))) {
    matched = pool.filter(function(o) {
      return (o.articleNo === 17 && ['2','3'].includes(o.clauseNo ? o.clauseNo.toString() : '')) ||
             (o.articleNo === 36 && o.clauseNo === '1' && o.pointNo === 'c') ||
             (o.articleNo === 20 && o.clauseNo === '3' && o.pointNo === 'đ') ||
             (o.articleNo === 12 && o.clauseNo === '11' && o.pointNo === 'a') ||
             o.canonical.toLowerCase().includes('rơi vãi') ||
             o.canonical.toLowerCase().includes('bùn');
    });
    matchReason = 'Khớp quy định về vệ sinh môi trường, chở hàng rơi vãi, không che bạt (Điều 17 / Điều 36)';
  }

  // 11. Đèn đỏ / Tín hiệu giao thông
  if (matched.length === 0 && (unaccented.includes('den do') || unaccented.includes('vuot den') || unaccented.includes('den vang') || unaccented.includes('tin hieu den'))) {
    matched = pool.filter(function(o) {
      return (o.articleNo === 6 && o.clauseNo === '9' && o.pointNo === 'b') ||
             (o.articleNo === 7 && o.clauseNo === '7' && o.pointNo === 'c') ||
             (o.articleNo === 8 && o.clauseNo === '7' && o.pointNo === 'c') ||
             (o.articleNo === 9 && o.clauseNo === '2' && o.pointNo === 'đ');
    });
    matchReason = 'Khớp hành vi không chấp hành hiệu lệnh của đèn tín hiệu giao thông (Vượt đèn đỏ / vàng)';
  }

  // 12. Đi ngược chiều / Đường cấm
  if (matched.length === 0 && (unaccented.includes('nguoc chieu') || unaccented.includes('duong cam') || unaccented.includes('bien cam'))) {
    matched = pool.filter(function(o) {
      return (o.canonical.toLowerCase().includes('ngược chiều') || o.canonical.toLowerCase().includes('đường cấm') || o.canonical.toLowerCase().includes('khu vực cấm'));
    });
    matchReason = 'Khớp hành vi đi ngược chiều hoặc đi vào đường có biển báo cấm';
  }

  // 13. Lùi xe / Quay đầu xe
  if (matched.length === 0 && (unaccented.includes('lui xe') || unaccented.includes('quay dau'))) {
    matched = pool.filter(function(o) {
      return (o.canonical.toLowerCase().includes('lùi xe') || o.canonical.toLowerCase().includes('quay đầu'));
    });
    matchReason = 'Khớp quy định về lùi xe, quay đầu xe';
  }

  // 14. Điện thoại / Thiết bị điện tử
  if (matched.length === 0 && (unaccented.includes('dien thoai') || unaccented.includes('dung tay') || unaccented.includes('dt'))) {
    matched = pool.filter(function(o) {
      return (o.canonical.toLowerCase().includes('điện thoại') || o.fullDescription.toLowerCase().includes('điện thoại'));
    });
    matchReason = 'Khớp hành vi dùng tay cầm và sử dụng điện thoại khi điều khiển xe';
  }
'''

app = app.replace('  // 9. Mirrors', search_enhancements + '\n  // 9. Mirrors')

# Update HUD logic
old_hud_vars = '''        var isGenericLicenseQuery = unaccented.includes('giay phep') || unaccented.includes('bang') || unaccented.includes('gplx');
        var isHelmetQuery = unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai');
        var isOverloadQuery = unaccented.includes('qua tai') || unaccented.includes('tai trong') || unaccented.includes('cho qua tai');
        var isAlcoholQuery = unaccented.includes('con') || unaccented.includes('ndc') || unaccented.includes('thoi con');'''

new_hud_vars = '''        var isGenericLicenseQuery = unaccented.includes('giay phep') || unaccented.includes('bang') || unaccented.includes('gplx');
        var isHelmetQuery = unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai');
        var isOverloadQuery = unaccented.includes('qua tai') || unaccented.includes('tai trong') || unaccented.includes('cho qua tai');
        var isAlcoholQuery = unaccented.includes('con') || unaccented.includes('ndc') || unaccented.includes('thoi con');
        var isRoiVaiQuery = unaccented.includes('roi vai') || unaccented.includes('roi') || unaccented.includes('che bat') || unaccented.includes('bun dat') || unaccented.includes('do rac');
        var isTrafficLightQuery = unaccented.includes('den do') || unaccented.includes('vuot den') || unaccented.includes('den vang');'''

app = app.replace(old_hud_vars, new_hud_vars)

# Add HUD block for Rơi vãi and Traffic light
roi_vai_hud = '''        if (isRoiVaiQuery) {
          hudContent = '<div class="case-hud">' +
            '<div class="hud-title">⚖️ QUY ĐỊNH CHỞ HÀNG RƠI VÃI & BẢO VỆ MÔI TRƯỜNG (ĐIỀU 17 & 36)</div>' +
            '<div style="font-size: 13px; line-height: 1.55; color: #212121;">' +
              '<div style="background:white; padding:8px 10px; border-radius:8px; margin-bottom:6px; border:1px solid #E0E0E0;">' +
                '🚚 <b>Xe Ô tô chở vật liệu, đất đá, phế thải không che đậy / để rơi vãi:</b><br>' +
                '• Mức phạt: <span style="color:var(--danger); font-weight:800;">2 - 4 triệu đồng</span> <span class="fine-midpoint">Mức TB: 3 triệu</span> (Điểm a Khoản 2 Điều 17)<br>' +
                '• Biện pháp: <span style="color:#00695C; font-weight:bold;">Buộc thu dọn và khôi phục tình trạng ban đầu (Đ.17.4).</span>' +
              '</div>' +
              '<div style="background:white; padding:8px 10px; border-radius:8px; margin-bottom:6px; border:1px solid #E0E0E0;">' +
                '🚚 <b>Lôi kéo bùn, đất, cát, vật liệu ra đường gây mất ATGT:</b><br>' +
                '• Mức phạt: <span style="color:var(--danger); font-weight:800;">2 - 4 triệu đồng</span> <span class="fine-midpoint">Mức TB: 3 triệu</span> (Điểm b Khoản 2 Điều 17)' +
              '</div>' +
              '<div style="background:white; padding:8px 10px; border-radius:8px; margin-bottom:6px; border:1px solid #E0E0E0;">' +
                '🛵 <b>Xe Mô tô / Xe máy vận chuyển vật liệu, phế thải để rơi vãi:</b><br>' +
                '• Mức phạt: <span style="color:var(--danger); font-weight:800;">300 - 400 nghìn đồng</span> <span class="fine-midpoint">Mức TB: 350 nghìn</span> (Điểm c Khoản 1 Điều 36)<br>' +
                '• Biện pháp: <span style="color:#00695C; font-weight:bold;">Buộc thu dọn vật liệu rơi vãi (Đ.36.2).</span>' +
              '</div>' +
              '<div style="background:white; padding:8px 10px; border-radius:8px; border:1px solid #E0E0E0;">' +
                '⚠️ <b>Đổ trái phép rác, đất, cát, phế thải ra đường bộ:</b><br>' +
                '• Mức phạt: <span style="color:var(--danger); font-weight:800;">4 - 6 triệu đồng</span> <span class="fine-midpoint">Mức TB: 5 triệu</span> (Khoản 3 Điều 17)' +
              '</div>' +
            '</div>' +
          '</div>';
        } else if (isTrafficLightQuery) {
          hudContent = '<div class="case-hud">' +
            '<div class="hud-title">🚦 QUY ĐỊNH VƯỢT ĐÈN ĐỎ / ĐÈN VÀNG (TÍN HIỆU GIAO THÔNG)</div>' +
            '<div style="font-size: 13px; line-height: 1.6; color: #212121;">' +
              '<div>🚗 <b>Xe Ô tô không chấp hành đèn tín hiệu:</b> <span style="color:var(--danger); font-weight:800;">18 - 20 triệu đồng</span> <span class="fine-midpoint">Mức TB: 19tr</span> | <span style="color:#C62828; font-weight:bold;">Trừ 04 điểm GPLX</span> (Điểm b Khoản 9 Điều 6)</div>' +
              '<div style="margin-top:4px;">🛵 <b>Xe Mô tô / Xe máy không chấp hành đèn tín hiệu:</b> <span style="color:var(--danger); font-weight:800;">4 - 6 triệu đồng</span> <span class="fine-midpoint">Mức TB: 5tr</span> | <span style="color:#C62828; font-weight:bold;">Trừ 04 điểm GPLX</span> (Điểm c Khoản 7 Điều 7)</div>' +
              '<div style="margin-top:4px;">🚜 <b>Xe máy chuyên dùng:</b> <span style="color:var(--danger); font-weight:800;">4 - 6 triệu đồng</span> <span class="fine-midpoint">Mức TB: 5tr</span> | <span style="color:#C62828; font-weight:bold;">Trừ 04 điểm GPLX</span> (Điểm c Khoản 7 Điều 8)</div>' +
              '<div style="margin-top:4px;">🚲 <b>Xe đạp / Xe đạp điện:</b> <span style="color:var(--danger); font-weight:800;">150 - 250 nghìn đồng</span> (Điểm đ Khoản 2 Điều 9)</div>' +
            '</div>' +
          '</div>';
        } else '''

app = app.replace('        if (isOverloadQuery) {', roi_vai_hud + 'if (isOverloadQuery) {')

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'w', encoding='utf-8') as f:
    f.write(app)

print('app.js successfully enhanced with Smart Semantic Matchers!')
