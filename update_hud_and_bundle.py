import re

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'r', encoding='utf-8') as f:
    app = f.read()

# Update HUD vars
old_vars = '''    var isGenericLicenseQuery = unaccented.includes('giay phep') || unaccented.includes('bang') || unaccented.includes('gplx');
    var isHelmetQuery = unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai');
    var isOverloadQuery = unaccented.includes('qua tai') || unaccented.includes('tai trong') || unaccented.includes('cho qua tai');
    var isAlcoholQuery = unaccented.includes('con') || unaccented.includes('ndc') || unaccented.includes('thoi con');'''

new_vars = '''    var isGenericLicenseQuery = unaccented.includes('giay phep') || unaccented.includes('bang') || unaccented.includes('gplx');
    var isHelmetQuery = unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai');
    var isOverloadQuery = unaccented.includes('qua tai') || unaccented.includes('tai trong') || unaccented.includes('cho qua tai');
    var isAlcoholQuery = unaccented.includes('con') || unaccented.includes('ndc') || unaccented.includes('thoi con');
    var isRoiVaiQuery = unaccented.includes('roi vai') || unaccented.includes('che bat') || unaccented.includes('bun dat') || unaccented.includes('do rac') || unaccented.includes('vat lieu');
    var isTrafficLightQuery = unaccented.includes('den do') || unaccented.includes('vuot den') || unaccented.includes('den vang');'''

app = app.replace(old_vars, new_vars)

# Insert roi vai and traffic light HUD
roi_vai_hud = '''    if (isRoiVaiQuery) {
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

app = app.replace('    if (isOverloadQuery) {', roi_vai_hud + 'if (isOverloadQuery) {')

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'w', encoding='utf-8') as f:
    f.write(app)

print('app.js updated successfully!')
