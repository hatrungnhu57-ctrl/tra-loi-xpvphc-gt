import re

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'r', encoding='utf-8') as f:
    app = f.read()

# 1. Update renderOffenseCard badges
old_card_badges = '''  var pointsBadge = off.points ? '<span class="badge badge-points">Trừ ' + off.points + 'đ GPLX</span>' : '';
  var detBadge = off.detention ? '<span class="badge badge-detention">Tạm giữ xe (Đ.48)</span>' : '';
  var remedyBadge = off.hasRemedy ? '<span class="badge badge-remedy">🔧 Khắc phục hậu quả</span>' : '';
  var editBadge = off.sourceNote ? '<span class="badge badge-edit">Sửa bởi NĐ 238</span>' : '';
  var midBadge = midpoint ? '<div class="fine-midpoint">Mức TB: ' + formatMoney(midpoint) + '</div>' : '';

  return '<div class="card" onclick="openDetailModal(\\'' + off.id + '\\')" style="cursor: pointer;">' +
    '<div class="card-header">' +
      '<span class="vehicle-tag">' + off.vehicleLabel + '</span>' +
      '<span class="legal-ref">' + off.primaryRef + '</span>' +
    '</div>' +
    '<div class="offense-name">' + off.canonical + '</div>' +
    '<div class="fine-row">' +
      '<div class="fine-amount ' + (off.isWarning ? 'fine-warning' : '') + '">' + fineText + '</div>' +
      midBadge +
    '</div>' +
    orgText +
    '<div class="badges-row">' +
      pointsBadge + detBadge + remedyBadge + editBadge +
    '</div>' +
  '</div>';'''

new_card_badges = '''  var pointsBadge = off.points ? '<span class="badge badge-points">Trừ ' + off.points + 'đ GPLX</span>' : '';
  var suspBadge = off.suspension ? '<span class="badge badge-suspension">🚫 Tước GPLX ' + off.suspension + '</span>' : '';
  var detBadge = off.detention ? '<span class="badge badge-detention">Tạm giữ xe (Đ.48)</span>' : '';
  var remedyBadge = off.hasRemedy ? '<span class="badge badge-remedy">🔧 Khắc phục hậu quả</span>' : '';
  var editBadge = off.sourceNote ? '<span class="badge badge-edit">Sửa bởi NĐ 238</span>' : '';
  var midBadge = midpoint ? '<div class="fine-midpoint">Mức TB: ' + formatMoney(midpoint) + '</div>' : '';

  return '<div class="card" onclick="openDetailModal(\\'' + off.id + '\\')" style="cursor: pointer;">' +
    '<div class="card-header">' +
      '<span class="vehicle-tag">' + off.vehicleLabel + '</span>' +
      '<span class="legal-ref">' + off.primaryRef + '</span>' +
    '</div>' +
    '<div class="offense-name">' + off.canonical + '</div>' +
    '<div class="fine-row">' +
      '<div class="fine-amount ' + (off.isWarning ? 'fine-warning' : '') + '">' + fineText + '</div>' +
      midBadge +
    '</div>' +
    orgText +
    '<div class="badges-row">' +
      pointsBadge + suspBadge + detBadge + remedyBadge + editBadge +
    '</div>' +
  '</div>';'''

app = app.replace(old_card_badges, new_card_badges)

# 2. Update openDetailModal
old_detail = '''      var pointsHtml = off.points ? '<div style="font-weight:700; font-size:12.5px; color:var(--danger); margin-bottom:3px;">2. Trừ điểm GPLX:</div><div style="font-size:13px; margin-bottom:12px;">Trừ <b>' + off.points + ' điểm</b> vào hệ thống dữ liệu GPLX (Điều 50 & 51).</div>' : '';
      var detHtml = off.detention ? '<div style="font-weight:700; font-size:12.5px; color:var(--warning); margin-bottom:3px;">3. Tạm giữ phương tiện / giấy tờ:</div><div style="font-size:13px; margin-bottom:12px;">' + (off.detentionNote || 'Tạm giữ phương tiện theo Điều 48.') + '</div>' : '';
      var remHtml = (off.remedies && off.remedies.length > 0) ? '<div style="font-weight:700; font-size:12.5px; color:#00695C; margin-bottom:3px;">4. Biện pháp khắc phục hậu quả:</div><div style="font-size:13px; margin-bottom:12px; color:#004D40; background:#E0F2F1; border-left:3px solid #00897B; padding:8px 10px; border-radius:6px; line-height:1.45;">' + off.remedies.map(function(r) { return '• ' + r; }).join('<br>') + '</div>' : '';
      var excHtml = (off.exceptions && Array.isArray(off.exceptions)) ? '<div style="font-weight:700; font-size:12.5px; color:var(--success); margin-bottom:3px;">5. Trường hợp ngoại lệ:</div><div style="font-size:13px; margin-bottom:12px;">' + off.exceptions.map(function(e) { return '• ' + e; }).join('<br>') + '</div>' : '';

      el.innerHTML = '<div class="modal-header">' +
          '<div>' +
            '<span class="vehicle-tag">' + off.vehicleLabel + '</span>' +
            '<span class="legal-ref" style="margin-left:6px;">' + off.primaryRef + '</span>' +
          '</div>' +
          '<button class="btn-close" onclick="closeDetailModal()">✕</button>' +
        '</div>' +
        '<div style="font-size:16px; font-weight:800; margin-bottom:10px; color:#212121;">' + off.canonical + '</div>' +
        '<div style="margin-bottom:12px;">' +
          '<div style="font-size:18px; font-weight:900; color:var(--danger);">' +
            (off.isWarning ? 'Phạt cảnh cáo' : (formatMoney(off.fineMin) + ' - ' + formatMoney(off.fineMax) + ' đồng')) +
          '</div>' +
          midHtml +
        '</div>' +
        '<div style="font-weight:700; font-size:12.5px; color:var(--primary); margin-bottom:3px;">1. Quy định chi tiết:</div>' +
        '<div style="font-size:13px; margin-bottom:12px; color:#37474F; line-height:1.45;">' + (off.fullDescription || off.desc || off.canonical) + '</div>' +
        pointsHtml + detHtml + remHtml + excHtml +
        '<div style="font-weight:700; font-size:12.5px; color:#455A64; margin-bottom:3px;">6. Căn cứ pháp lý:</div>\''''

new_detail = '''      var pointsHtml = off.points ? '<div style="font-weight:700; font-size:12.5px; color:var(--danger); margin-bottom:3px;">2. Trừ điểm GPLX:</div><div style="font-size:13px; margin-bottom:12px;">Trừ <b>' + off.points + ' điểm</b> vào hệ thống dữ liệu GPLX (Điều 50 & 51).</div>' : '';
      var suspHtml = off.suspension ? '<div style="font-weight:700; font-size:12.5px; color:#6A1B9A; margin-bottom:3px;">3. Tước quyền sử dụng GPLX:</div><div style="font-size:13px; margin-bottom:12px; color:#4A148C; background:#F3E5F5; border-left:3px solid #8E24AA; padding:8px 10px; border-radius:6px; line-height:1.45;">Tước quyền sử dụng giấy phép lái xe từ <b>' + off.suspension + '</b> (' + (off.suspensionBasis || 'Quy định hình thức xử phạt bổ sung') + ').<br><span style="font-size:12px; color:#6A1B9A;">* Lưu ý: Theo Khoản 2 Điều 5 và Điểm đ Khoản 1 Điều 50, khi bị tước GPLX thì KHÔNG áp dụng trừ điểm GPLX.</span></div>' : '';
      var detHtml = off.detention ? '<div style="font-weight:700; font-size:12.5px; color:var(--warning); margin-bottom:3px;">4. Tạm giữ phương tiện / giấy tờ:</div><div style="font-size:13px; margin-bottom:12px;">' + (off.detentionNote || 'Tạm giữ phương tiện theo Điều 48.') + '</div>' : '';
      var remHtml = (off.remedies && off.remedies.length > 0) ? '<div style="font-weight:700; font-size:12.5px; color:#00695C; margin-bottom:3px;">5. Biện pháp khắc phục hậu quả:</div><div style="font-size:13px; margin-bottom:12px; color:#004D40; background:#E0F2F1; border-left:3px solid #00897B; padding:8px 10px; border-radius:6px; line-height:1.45;">' + off.remedies.map(function(r) { return '• ' + r; }).join('<br>') + '</div>' : '';
      var excHtml = (off.exceptions && Array.isArray(off.exceptions)) ? '<div style="font-weight:700; font-size:12.5px; color:var(--success); margin-bottom:3px;">6. Trường hợp ngoại lệ:</div><div style="font-size:13px; margin-bottom:12px;">' + off.exceptions.map(function(e) { return '• ' + e; }).join('<br>') + '</div>' : '';

      el.innerHTML = '<div class="modal-header">' +
          '<div>' +
            '<span class="vehicle-tag">' + off.vehicleLabel + '</span>' +
            '<span class="legal-ref" style="margin-left:6px;">' + off.primaryRef + '</span>' +
          '</div>' +
          '<button class="btn-close" onclick="closeDetailModal()">✕</button>' +
        '</div>' +
        '<div style="font-size:16px; font-weight:800; margin-bottom:10px; color:#212121;">' + off.canonical + '</div>' +
        '<div style="margin-bottom:12px;">' +
          '<div style="font-size:18px; font-weight:900; color:var(--danger);">' +
            (off.isWarning ? 'Phạt cảnh cáo' : (formatMoney(off.fineMin) + ' - ' + formatMoney(off.fineMax) + ' đồng')) +
          '</div>' +
          midHtml +
        '</div>' +
        '<div style="font-weight:700; font-size:12.5px; color:var(--primary); margin-bottom:3px;">1. Quy định chi tiết:</div>' +
        '<div style="font-size:13px; margin-bottom:12px; color:#37474F; line-height:1.45;">' + (off.fullDescription || off.desc || off.canonical) + '</div>' +
        pointsHtml + suspHtml + detHtml + remHtml + excHtml +
        '<div style="font-weight:700; font-size:12.5px; color:#455A64; margin-bottom:3px;">7. Căn cứ pháp lý:</div>\''''

app = app.replace(old_detail, new_detail)

# 3. Update TTKS checklist
old_ttks_badges = '''        if (off.points || off.detention || off.hasRemedy) {
          badges = '<div style="font-size:11px; font-weight:700; margin-top:2px;">' +
            (off.points ? '<span style="color:#C62828;">Trừ ' + off.points + 'đ GPLX</span> ' : '') +
            (off.detention ? '<span style="color:#D84315;">• Tạm giữ xe (Đ.48)</span> ' : '') +
            (off.hasRemedy ? '<span style="color:#00695C;">• Có khắc phục hậu quả</span>' : '') +
          '</div>';
        }'''

new_ttks_badges = '''        if (off.points || off.suspension || off.detention || off.hasRemedy) {
          badges = '<div style="font-size:11px; font-weight:700; margin-top:2px;">' +
            (off.points ? '<span style="color:#C62828;">Trừ ' + off.points + 'đ GPLX</span> ' : '') +
            (off.suspension ? '<span style="color:#6A1B9A;">• Tước GPLX ' + off.suspension + '</span> ' : '') +
            (off.detention ? '<span style="color:#D84315;">• Tạm giữ xe (Đ.48)</span> ' : '') +
            (off.hasRemedy ? '<span style="color:#00695C;">• Có khắc phục hậu quả</span>' : '') +
          '</div>';
        }'''

app = app.replace(old_ttks_badges, new_ttks_badges)

# 4. Update TTKS selected items
old_tray_item = '''(o.points ? ' | <b style="color:#C62828;">-' + o.points + 'đ</b>' : '') +
                (o.detention ? ' | <b style="color:#D84315;">Tạm giữ</b>' : '') +'''

new_tray_item = '''(o.points ? ' | <b style="color:#C62828;">-' + o.points + 'đ</b>' : '') +
                (o.suspension ? ' | <b style="color:#6A1B9A;">Tước ' + o.suspension + '</b>' : '') +
                (o.detention ? ' | <b style="color:#D84315;">Tạm giữ</b>' : '') +'''

app = app.replace(old_tray_item, new_tray_item)

# 5. Update TTKS Live Summary for Suspension
old_live_summary = '''      document.getElementById('ttksFineSummary').innerText = formatMoney(totalMin) + ' - ' + formatMoney(totalMax) + ' đồng';
      document.getElementById('ttksMidpointSummary').innerText = 'Mức trung bình: ' + formatMoney(totalMid) + ' đồng';
      document.getElementById('ttksPointsSummary').innerText = maxPoints > 0 ? ('Trừ: ' + maxPoints + ' điểm (Đ.50.1.b)') : 'Không trừ điểm';
      document.getElementById('ttksDetentionSummary').innerText = hasDetention ? 'Tạm giữ phương tiện (Đ.48)' : '';'''

new_live_summary = '''      document.getElementById('ttksFineSummary').innerText = formatMoney(totalMin) + ' - ' + formatMoney(totalMax) + ' đồng';
      document.getElementById('ttksMidpointSummary').innerText = 'Mức trung bình: ' + formatMoney(totalMid) + ' đồng';
      
      var hasSuspension = selected.some(function(o) { return o.suspension; });
      if (hasSuspension) {
        var suspOff = selected.find(function(o) { return o.suspension; });
        document.getElementById('ttksPointsSummary').innerText = 'Tước GPLX: ' + suspOff.suspension;
        document.getElementById('ttksPointsSummary').style.color = '#CE93D8';
      } else {
        document.getElementById('ttksPointsSummary').innerText = maxPoints > 0 ? ('Trừ: ' + maxPoints + ' điểm (Đ.50.1.b)') : 'Không trừ điểm';
        document.getElementById('ttksPointsSummary').style.color = '#FFD54F';
      }
      document.getElementById('ttksDetentionSummary').innerText = hasDetention ? 'Tạm giữ phương tiện (Đ.48)' : '';'''

app = app.replace(old_live_summary, new_live_summary)

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/app.js', 'w', encoding='utf-8') as f:
    f.write(app)

print('app.js successfully updated with suspension!')
