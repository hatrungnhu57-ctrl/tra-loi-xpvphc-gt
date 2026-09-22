// TRA LỖI GT PRO - CORE CLIENT APPLICATION

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('./service-worker.js').catch(function() {});
}

// Fetch or load DATABASE
var DATABASE = [];

function removeDiacritics(str) {
  if (!str) return '';
  return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[đĐ]/g, 'd');
}

function normalize(str) {
  if (!str) return '';
  var text = str.trim().toLowerCase();
  text = text.replace(/[,;!?()"\x27\[\]{}]/g, ' ');
  text = text.replace(/(?<![a-zA-Z0-9])\.|\.(?![a-zA-Z0-9])/g, ' ');
  return text.replace(/\s+/g, ' ').trim();
}

function formatMoney(amount) {
  if (!amount) return '0 đ';
  if (amount >= 1000000) {
    var trieu = amount / 1000000;
    return (trieu === Math.floor(trieu) ? trieu : trieu.toFixed(1)) + ' triệu';
  }
  return (amount / 1000) + ' nghìn';
}

var searchInput = document.getElementById('searchInput');
var btnClear = document.getElementById('btnClear');
if (searchInput && btnClear) {
  searchInput.addEventListener('input', function() {
    btnClear.style.display = searchInput.value.length > 0 ? 'block' : 'none';
  });
}

function clearSearch() {
  if (searchInput) {
    searchInput.value = '';
    if (btnClear) btnClear.style.display = 'none';
  }
  performSearch();
}

function startVoiceRecognition() {
  var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    alert('Trình duyệt chưa hỗ trợ giọng nói. Bạn hãy gõ vào ô tìm kiếm nhé!');
    return;
  }
  var recognition = new SpeechRecognition();
  recognition.lang = 'vi-VN';
  recognition.interimResults = false;
  var micBtn = document.getElementById('btnMic');
  if (micBtn) micBtn.innerText = '🔴';
  recognition.start();
  recognition.onresult = function(e) {
    var transcript = e.results[0][0].transcript;
    if (searchInput) {
      searchInput.value = transcript;
      if (btnClear) btnClear.style.display = 'block';
    }
    if (micBtn) micBtn.innerText = '🎙️';
    performSearch();
  };
  recognition.onerror = function() { if (micBtn) micBtn.innerText = '🎙️'; };
  recognition.onend = function() { if (micBtn) micBtn.innerText = '🎙️'; };
}

var currentCategoryFilter = 'all';
function filterCategory(cat) {
  currentCategoryFilter = cat;
  var pills = ['catAll', 'catMoto', 'catCar', 'catDriver', 'catRemedy', 'catTransport', 'catOwner', 'catVehicle'];
  pills.forEach(function(id) {
    var el = document.getElementById(id);
    if (el) el.classList.remove('active');
  });

  var activeMap = {
    'all': 'catAll',
    'motorcycle': 'catMoto',
    'car': 'catCar',
    'DRIVER': 'catDriver',
    'REMEDY': 'catRemedy',
    'TRANSPORT': 'catTransport',
    'OWNER': 'catOwner',
    'VEHICLE': 'catVehicle'
  };
  var activeEl = document.getElementById(activeMap[cat] || 'catAll');
  if (activeEl) activeEl.classList.add('active');

  if (cat === 'all') {
    document.getElementById('resultsHeader').innerText = 'Toàn bộ ' + DATABASE.length + ' hành vi vi phạm (NĐ 168/2024 & NĐ 238/2026):';
    renderList(DATABASE);
  } else if (cat === 'REMEDY') {
    var filtered = DATABASE.filter(function(o) { return o.hasRemedy; });
    document.getElementById('resultsHeader').innerText = 'Danh mục có áp dụng Biện pháp khắc phục hậu quả (' + filtered.length + ' hành vi):';
    renderList(filtered);
  } else if (cat === 'motorcycle' || cat === 'car') {
    var filtered = DATABASE.filter(function(o) { return o.vehicle === cat || o.vehicle === 'all'; });
    document.getElementById('resultsHeader').innerText = 'Danh mục ' + (cat === 'car' ? 'Xe Ô tô' : 'Xe Mô tô') + ' (' + filtered.length + ' hành vi):';
    renderList(filtered);
  } else {
    var filtered = DATABASE.filter(function(o) { return o.category === cat; });
    var catLabels = {
      'DRIVER': 'GPLX, Giấy tờ & Độ tuổi (Điều 18)',
      'TRANSPORT': 'Vận tải hành khách & Quá tải (Điều 20, 21)',
      'OWNER': 'Trách nhiệm Chủ phương tiện (Điều 32)',
      'VEHICLE': 'Thiết bị kỹ thuật & Đăng kiểm (Điều 13, 14, 16)'
    };
    document.getElementById('resultsHeader').innerText = 'Danh mục ' + (catLabels[cat] || cat) + ' (' + filtered.length + ' hành vi):';
    renderList(filtered);
  }
}

function renderOffenseCard(off) {
  var fineText = off.isWarning ? 'Phạt cảnh cáo' : (formatMoney(off.fineMin) + ' - ' + formatMoney(off.fineMax) + ' đồng');
  var midpoint = (off.fineMin && off.fineMax) ? Math.round((off.fineMin + off.fineMax) / 2) : null;

  var orgText = '';
  if (off.fineMinOrg) {
    var orgMid = Math.round((off.fineMinOrg + off.fineMaxOrg) / 2);
    orgText = '<div style="font-size:12px; font-weight:700; color:#2E7D32; margin-top:2px;">Tổ chức: ' + formatMoney(off.fineMinOrg) + ' - ' + formatMoney(off.fineMaxOrg) + ' đồng (Mức TB: ' + formatMoney(orgMid) + ')</div>';
  }

  var pointsBadge = off.points ? '<span class="badge badge-points">Trừ ' + off.points + 'đ GPLX</span>' : '';
  var detBadge = off.detention ? '<span class="badge badge-detention">Tạm giữ xe (Đ.48)</span>' : '';
  var remedyBadge = off.hasRemedy ? '<span class="badge badge-remedy">🔧 Khắc phục hậu quả</span>' : '';
  var editBadge = off.sourceNote ? '<span class="badge badge-edit">Sửa bởi NĐ 238</span>' : '';
  var midBadge = midpoint ? '<div class="fine-midpoint">Mức TB: ' + formatMoney(midpoint) + '</div>' : '';

  return '<div class="card" onclick="openDetailModal(\'' + off.id + '\')" style="cursor: pointer;">' +
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
  '</div>';
}

function renderList(list) {
  var el = document.getElementById('offenseList');
  if (!list || list.length === 0) {
    el.innerHTML = '<div style="text-align:center; padding:30px; color:var(--text-muted);">Không tìm thấy hành vi vi phạm phù hợp.</div>';
    return;
  }
  el.innerHTML = list.map(renderOffenseCard).join('');
}

function performSearch() {
  var inputEl = document.getElementById('searchInput');
  var query = inputEl ? inputEl.value.trim() : '';
  if (!query) {
    renderList(DATABASE);
    document.getElementById('caseHudContainer').style.display = 'none';
    return;
  }

  var norm = normalize(query);
  var unaccented = removeDiacritics(norm);

  var matched = [];
  var matchReason = '';

  // 1. Citation match
  var p1 = /diem\s+([a-zd])\s+khoan\s+([0-9]+[a-z]?)\s+dieu\s+([0-9]+)/i;
  var m1 = unaccented.match(p1);
  var pDot = /^([a-zd])\.([0-9]+[a-z]?)\.([0-9]+)$/i;
  var mDot = unaccented.match(pDot);

  if (m1 || mDot) {
    var pNo = (m1 ? m1[1] : mDot[1]).toLowerCase();
    var kNo = (m1 ? m1[2] : mDot[2]).toLowerCase();
    var dNo = m1 ? m1[3] : mDot[3];
    matched = DATABASE.filter(function(o) { return o.primaryRef.toLowerCase().includes('điều ' + dNo) && o.primaryRef.toLowerCase().includes('khoản ' + kNo); });
    matchReason = 'Khớp trích dẫn Điều ' + dNo + ' Khoản ' + kNo;
  }

  // 2. Speed 76/60
  if (matched.length === 0 && unaccented.includes('/')) {
    var slash = unaccented.match(/([0-9]{2,3})\s*\/\s*([0-9]{2,3})/);
    if (slash) {
      var excess = parseFloat(slash[1]) - parseFloat(slash[2]);
      if (excess >= 10 && excess <= 20) {
        matched = DATABASE.filter(function(o) { return o.code.includes('006-05-D') || (o.articleNo === 6 && o.clauseNo === '5' && o.pointNo === 'đ'); });
        matchReason = 'Khớp tốc độ vượt ' + excess + ' km/h (khung 10-20 km/h: Điểm đ Khoản 5 Điều 6)';
      }
    }
  }

  // 3. Alcohol 0.32
  if (matched.length === 0 && (unaccented.includes('con') || unaccented.includes('0.'))) {
    var alc = unaccented.match(/0\.[0-9]+/);
    if (alc && parseFloat(alc[0]) > 0.25 && parseFloat(alc[0]) <= 0.40) {
      matched = DATABASE.filter(function(o) { return o.code.includes('007-08-B') || (o.articleNo === 7 && o.clauseNo === '8' && o.pointNo === 'b'); });
      matchReason = 'Khớp nồng độ cồn ' + alc[0] + ' mg/L (Mức 2: Điểm b Khoản 8 Điều 7)';
    }
  }

  // 4. Helmet match
  if (matched.length === 0 && (unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai'))) {
    matched = DATABASE.filter(function(o) { return (o.articleNo === 7 && o.clauseNo === '2' && (o.pointNo === 'h' || o.pointNo === 'i')) || (o.articleNo === 9 && o.clauseNo === '4' && (o.pointNo === 'd' || o.pointNo === 'đ')); });
    matchReason = 'Khớp quy định về đội mũ bảo hiểm và cài quai đúng quy cách (Khoản 2 Điều 7)';
  }

  // 5. 150cc license
  if (matched.length === 0 && (unaccented.includes('150') && (unaccented.includes('khong bang') || unaccented.includes('k gplx') || unaccented.includes('k bang')))) {
    matched = DATABASE.filter(function(o) { return o.code.includes('018-07-B') || (o.articleNo === 18 && o.clauseNo === '7' && o.pointNo === 'b'); });
    matchReason = 'Khớp lỗi không có GPLX xe mô tô > 125cm3 (Điểm b Khoản 7 Điều 18)';
  }

  // 6. Kep 3
  if (matched.length === 0 && (unaccented.includes('kep 3') || unaccented.includes('cho 3'))) {
    matched = DATABASE.filter(function(o) { return o.code.includes('007-03-B') || (o.articleNo === 7 && o.clauseNo === '3' && o.pointNo === 'b'); });
    matchReason = 'Khớp hành vi kẹp 3 xe máy (Điểm b Khoản 3 Điều 7)';
  }

  // 7. Owner handover
  if (matched.length === 0 && unaccented.includes('giao xe')) {
    matched = DATABASE.filter(function(o) { return o.code.includes('032-10') || (o.articleNo === 32 && o.clauseNo === '10'); });
    matchReason = 'Khớp trách nhiệm chủ xe giao xe cho người không đủ ĐK (Khoản 10 Điều 32)';
  }

  // 8. Mirrors
  if (matched.length === 0 && (unaccented.includes('guong') || unaccented.includes('kinh chieu hau'))) {
    matched = DATABASE.filter(function(o) { return (o.articleNo === 14 && o.clauseNo === '1' && o.pointNo === 'a') || (o.articleNo === 13 && o.clauseNo === '1' && o.pointNo === 'a'); });
    matchReason = 'Khớp quy định về gương chiếu hậu phương tiện (Điều 14 / Điều 13)';
  }

  // 9. Text fallback
  if (matched.length === 0) {
    matched = DATABASE.filter(function(o) {
      var offNorm = removeDiacritics(o.searchText);
      return (o.aliases && o.aliases.some(function(a) { return unaccented.includes(removeDiacritics(a)); })) || offNorm.includes(unaccented);
    });
  }

  renderList(matched);

  // Render HUD
  var hud = document.getElementById('caseHudContainer');
  if (matched.length > 0) {
    var isGenericLicenseQuery = unaccented.includes('giay phep') || unaccented.includes('bang') || unaccented.includes('gplx');
    var isHelmetQuery = unaccented.includes('mu') || unaccented.includes('non') || unaccented.includes('mbh') || unaccented.includes('cai quai');

    var hudContent = '';
    if (isHelmetQuery) {
      hudContent = '<div class="case-hud">' +
        '<div class="hud-title">⚖️ QUY ĐỊNH VỀ MŨ BẢO HIỂM (KHOẢN 2 ĐIỀU 7)</div>' +
        '<div style="font-size: 13px; line-height: 1.55; color: #212121;">' +
          '<div>🧢 <b>Người trực tiếp lái xe không đội mũ (hoặc không cài quai):</b> <span style="color:var(--danger); font-weight:800;">400 - 600 nghìn đồng</span> <span class="fine-midpoint">Mức TB: 500 nghìn</span> <span style="font-size:11.5px; color:#546E7A;">(Điểm h Khoản 2 Điều 7)</span></div>' +
          '<div style="margin-top:3px;">👥 <b>Chở người ngồi sau không đội mũ (hoặc không cài quai):</b> <span style="color:var(--danger); font-weight:800;">400 - 600 nghìn đồng</span> <span class="fine-midpoint">Mức TB: 500 nghìn</span> <span style="font-size:11.5px; color:#546E7A;">(Điểm i Khoản 2 Điều 7)</span></div>' +
          '<div style="font-size:11.5px; color:#2E7D32; margin-top:4px;">* Ngoại lệ không phạt người ngồi sau: Chở người bệnh đi cấp cứu, trẻ em dưới 06 tuổi, áp giải người vi phạm pháp luật.</div>' +
        '</div>' +
      '</div>';
    } else if (isGenericLicenseQuery && matched.some(function(o) { return o.articleNo === 18; })) {
      hudContent = '<div class="case-hud">' +
        '<div class="hud-title">⚖️ PHÂN ĐỊNH MỨC PHẠT THEO LOẠI XE & DUNG TÍCH (ĐIỀU 18)</div>' +
        '<div style="font-size: 13px; line-height: 1.55; color: #212121;">' +
          '<div>🛵 <b>Xe máy ≤ 125 cm³ (≤11kW, ví dụ 110cc):</b> <span style="color:var(--danger); font-weight:800;">2 - 4 triệu đồng</span> <span class="fine-midpoint">Mức TB: 3 triệu</span> <span style="font-size:11.5px; color:#546E7A;">(Điểm a Khoản 5 Điều 18)</span></div>' +
          '<div style="margin-top:3px;">🏍️ <b>Xe máy > 125 cm³ (>11kW, ví dụ 150cc), xe 3 bánh:</b> <span style="color:var(--danger); font-weight:800;">6 - 8 triệu đồng</span> <span class="fine-midpoint">Mức TB: 7 triệu</span> <span style="font-size:11.5px; color:#546E7A;">(Điểm b Khoản 7 Điều 18)</span></div>' +
          '<div style="margin-top:3px;">🚗 <b>Xe Ô tô:</b> <span style="color:var(--danger); font-weight:800;">18 - 20 triệu đồng</span> <span class="fine-midpoint">Mức TB: 19 triệu</span> <span style="font-size:11.5px; color:#546E7A;">(Điểm b Khoản 9 Điều 18)</span></div>' +
        '</div>' +
        '<div style="font-weight:700; color:#D84315; font-size:12px; margin-top:5px;">⚠️ Biện pháp: Tạm giữ phương tiện đến 07 ngày (Khoản 1 Điểm i Điều 48)</div>' +
      '</div>';
    } else {
      var fineSumMin = matched.reduce(function(acc, cur) { return acc + (cur.fineMin || 0); }, 0);
      var fineSumMax = matched.reduce(function(acc, cur) { return acc + (cur.fineMax || 0); }, 0);
      var midSum = Math.round((fineSumMin + fineSumMax) / 2);
      var maxPoints = Math.max.apply(null, [0].concat(matched.map(function(o) { return o.points || 0; })));
      var hasDetention = matched.some(function(o) { return o.detention; });
      var remediesList = [];
      matched.forEach(function(o) {
        if (o.remedies && o.remedies.length > 0) {
          o.remedies.forEach(function(r) { if (!remediesList.includes(r)) remediesList.push(r); });
        }
      });

      hudContent = '<div class="case-hud">' +
        '<div class="hud-title">⚖️ ĐÁNH GIÁ TỔNG HỢP VỤ VIỆC</div>' +
        '<div style="display:flex; align-items:baseline; gap:8px; flex-wrap:wrap;">' +
          '<div style="font-weight:bold; color:var(--danger); font-size:14.5px;">Mức phạt tiền: ' + formatMoney(fineSumMin) + ' - ' + formatMoney(fineSumMax) + ' đồng</div>' +
          '<div class="fine-midpoint">Mức TB: ' + formatMoney(midSum) + '</div>' +
        '</div>' +
        (maxPoints > 0 ? '<div style="font-weight:700; color:#D32F2F; font-size:12.5px; margin-top:3px;">Trừ điểm GPLX: <b>' + maxPoints + ' điểm</b> (Áp dụng Điều 50.1.b: Chỉ trừ điểm lỗi cao nhất)</div>' : '') +
        (hasDetention ? '<div style="font-weight:700; color:#D84315; font-size:12.5px; margin-top:3px;">Biện pháp ngăn chặn: Tạm giữ phương tiện theo Điều 48</div>' : '') +
        (remediesList.length > 0 ? '<div style="font-weight:700; color:#00695C; font-size:12.5px; margin-top:3px;">Biện pháp khắc phục hậu quả: ' + remediesList.join('; ') + '</div>' : '') +
        (matchReason ? '<div style="font-size:12px; color:var(--text-muted); margin-top:4px;">• ' + matchReason + '</div>' : '') +
      '</div>';
    }

    hud.style.display = 'block';
    hud.innerHTML = hudContent;
  } else {
    hud.style.display = 'none';
  }
}

function quickSearch(text) {
  if (searchInput) {
    searchInput.value = text;
    if (btnClear) btnClear.style.display = 'block';
  }
  performSearch();
}

// TTKS PATROL
var ttksSelectedVehicle = 'motorcycle';
var selectedOffenseIds = new Set();

function setTtksVehicle(v) {
  ttksSelectedVehicle = v;
  document.getElementById('ttksVehMoto').className = v === 'motorcycle' ? 'cat-pill active' : 'cat-pill';
  document.getElementById('ttksVehCar').className = v === 'car' ? 'cat-pill active' : 'cat-pill';
  renderTtksChecklist();
  updateTtksSummary();
}

function renderTtksChecklist() {
  var filterEl = document.getElementById('ttksFilter');
  var filter = filterEl ? filterEl.value.trim().toLowerCase() : '';
  var list = DATABASE.filter(function(o) { return o.vehicle === ttksSelectedVehicle || o.vehicle === 'all'; }).filter(function(o) {
    if (!filter) return true;
    return o.canonical.toLowerCase().includes(filter) || o.primaryRef.toLowerCase().includes(filter);
  });

  var el = document.getElementById('ttksChecklist');
  if (!el) return;
  el.innerHTML = list.map(function(off) {
    var isChecked = selectedOffenseIds.has(off.id);
    var fineText = off.isWarning ? 'Cảnh cáo' : (formatMoney(off.fineMin) + ' - ' + formatMoney(off.fineMax));
    var midpoint = (off.fineMin && off.fineMax) ? Math.round((off.fineMin + off.fineMax) / 2) : null;
    var midBadge = midpoint ? '<span class="fine-midpoint" style="font-size:11px;">TB: ' + formatMoney(midpoint) + '</span>' : '';

    var badges = '';
    if (off.points || off.detention || off.hasRemedy) {
      badges = '<div style="font-size:11px; font-weight:700; margin-top:2px;">' +
        (off.points ? '<span style="color:#C62828;">Trừ ' + off.points + 'đ GPLX</span> ' : '') +
        (off.detention ? '<span style="color:#D84315;">• Tạm giữ xe (Đ.48)</span> ' : '') +
        (off.hasRemedy ? '<span style="color:#00695C;">• Có khắc phục hậu quả</span>' : '') +
      '</div>';
    }

    return '<div class="checklist-item ' + (isChecked ? 'selected' : '') + '" onclick="toggleTtksOffense(\'' + off.id + '\')">' +
      '<input type="checkbox" class="checklist-checkbox" ' + (isChecked ? 'checked' : '') + ' onclick="event.stopPropagation(); toggleTtksOffense(\'' + off.id + '\')" />' +
      '<div style="flex:1;">' +
        '<div style="font-size:13.5px; font-weight:' + (isChecked ? 'bold' : '600') + '; color:#212121;">' + off.canonical + '</div>' +
        '<div style="display:flex; justify-content:space-between; align-items:center; margin-top:3px; font-size:11.5px;">' +
          '<span style="font-weight:700; color:#455A64;">' + off.primaryRef + '</span>' +
          '<span style="font-weight:800; color:' + (off.isWarning ? 'var(--warning)' : 'var(--danger)') + ';">' + fineText + ' ' + midBadge + '</span>' +
        '</div>' +
        badges +
      '</div>' +
    '</div>';
  }).join('');
}

function toggleTtksOffense(id) {
  if (selectedOffenseIds.has(id)) {
    selectedOffenseIds.delete(id);
  } else {
    selectedOffenseIds.add(id);
  }
  renderTtksChecklist();
  updateTtksSummary();
}

function clearAllSelected() {
  selectedOffenseIds.clear();
  renderTtksChecklist();
  updateTtksSummary();
}

function filterTtksList() {
  renderTtksChecklist();
}

function updateTtksSummary() {
  var selected = DATABASE.filter(function(o) { return selectedOffenseIds.has(o.id); });
  document.getElementById('ttksSelectedCount').innerText = 'Đã chọn ' + selected.length + ' hành vi';

  // Update Selected Tray View
  var tray = document.getElementById('selectedTray');
  var trayCount = document.getElementById('trayCount');
  var trayItems = document.getElementById('selectedListItems');

  if (selected.length > 0) {
    tray.style.display = 'block';
    trayCount.innerText = selected.length;
    trayItems.innerHTML = selected.map(function(o, idx) {
      var fine = o.isWarning ? 'Cảnh cáo' : (formatMoney(o.fineMin) + ' - ' + formatMoney(o.fineMax));
      var mid = (o.fineMin && o.fineMax) ? formatMoney(Math.round((o.fineMin + o.fineMax) / 2)) : '';
      return '<div class="selected-tag-item">' +
        '<div style="flex:1; padding-right:8px;">' +
          '<div style="font-weight:700; color:#212121;">' + (idx + 1) + '. ' + o.canonical + '</div>' +
          '<div style="font-size:11.5px; color:#546E7A; margin-top:1px;">' +
            '<b>' + o.primaryRef + '</b> | Phạt: <b style="color:#C62828;">' + fine + '</b> ' + (mid ? '(TB: ' + mid + ')' : '') +
            (o.points ? ' | <b style="color:#C62828;">-' + o.points + 'đ</b>' : '') +
            (o.detention ? ' | <b style="color:#D84315;">Tạm giữ</b>' : '') +
            (o.hasRemedy ? ' | <b style="color:#00695C;">Khắc phục</b>' : '') +
          '</div>' +
        '</div>' +
        '<button class="btn-remove-off" onclick="toggleTtksOffense(\'' + o.id + '\')">XÓA</button>' +
      '</div>';
    }).join('');
  } else {
    tray.style.display = 'none';
  }

  if (selected.length === 0) {
    document.getElementById('ttksFineSummary').innerText = '0 đồng';
    document.getElementById('ttksMidpointSummary').innerText = '';
    document.getElementById('ttksPointsSummary').innerText = 'Điểm trừ: 0đ';
    document.getElementById('ttksDetentionSummary').innerText = '';
    return;
  }

  var totalMin = selected.reduce(function(acc, cur) { return acc + (cur.fineMin || 0); }, 0);
  var totalMax = selected.reduce(function(acc, cur) { return acc + (cur.fineMax || 0); }, 0);
  var totalMid = Math.round((totalMin + totalMax) / 2);
  var maxPoints = Math.max.apply(null, [0].concat(selected.map(function(o) { return o.points || 0; })));
  var hasDetention = selected.some(function(o) { return o.detention; }) || document.getElementById('chkUnpresented').checked;

  document.getElementById('ttksFineSummary').innerText = formatMoney(totalMin) + ' - ' + formatMoney(totalMax) + ' đồng';
  document.getElementById('ttksMidpointSummary').innerText = 'Mức trung bình: ' + formatMoney(totalMid) + ' đồng';
  document.getElementById('ttksPointsSummary').innerText = maxPoints > 0 ? ('Trừ: ' + maxPoints + ' điểm (Đ.50.1.b)') : 'Không trừ điểm';
  document.getElementById('ttksDetentionSummary').innerText = hasDetention ? 'Tạm giữ phương tiện (Đ.48)' : '';
}

function openMinutesModal() {
  var selected = DATABASE.filter(function(o) { return selectedOffenseIds.has(o.id); });
  if (selected.length === 0) return;

  var plate = document.getElementById('ttksPlate').value.trim().toUpperCase() || 'CHƯA RÕ';
  var name = document.getElementById('ttksName').value.trim() || 'CHƯA RÕ';
  var unpresented = document.getElementById('chkUnpresented').checked;

  var totalMin = selected.reduce(function(acc, cur) { return acc + (cur.fineMin || 0); }, 0);
  var totalMax = selected.reduce(function(acc, cur) { return acc + (cur.fineMax || 0); }, 0);
  var totalMid = Math.round((totalMin + totalMax) / 2);
  var maxPoints = Math.max.apply(null, [0].concat(selected.map(function(o) { return o.points || 0; })));

  var now = new Date();
  var timeStr = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0') + ' ngày ' + now.getDate() + '/' + (now.getMonth()+1) + '/' + now.getFullYear();

  var text = '=== TÓM TẮT BIÊN BẢN VI PHẠM HÀNH CHÍNH (TTKS) ===\n';
  text += 'Thời gian: ' + timeStr + '\n';
  text += 'Đối tượng vi phạm: ' + name + ' | Phương tiện: ' + plate + ' (' + (ttksSelectedVehicle === 'car' ? 'Ô tô' : 'Mô tô/Xe máy') + ')\n';
  text += '--------------------------------------------------\n';
  text += 'I. CÁC HÀNH VI VI PHẠM XÁC ĐỊNH (' + selected.length + '):\n';
  selected.forEach(function(o, i) {
    var mid = (o.fineMin && o.fineMax) ? Math.round((o.fineMin + o.fineMax) / 2) : null;
    text += (i+1) + '. ' + o.canonical + '\n';
    text += '   - Căn cứ pháp lý: ' + o.primaryRef + ' Nghị định số 168/2024/NĐ-CP (được sửa đổi, bổ sung tại Nghị định số 238/2026/NĐ-CP ngày 26/6/2026 của Chính phủ)\n';
    text += '   - Khung phạt: ' + (o.isWarning ? 'Phạt cảnh cáo' : (formatMoney(o.fineMin) + ' - ' + formatMoney(o.fineMax) + ' đồng (Mức TB: ' + formatMoney(mid) + ')')) + '\n';
    if (o.points) text += '   - Mức trừ điểm theo quy định lỗi: ' + o.points + ' điểm\n';
  });

  text += '\nII. QUYẾT ĐỊNH XỬ PHẠT TỔNG HỢP:\n';
  text += '1. Khung phạt tiền: ' + formatMoney(totalMin) + ' - ' + formatMoney(totalMax) + ' đồng\n';
  text += '   -> Mức phạt trung bình áp dụng: ' + formatMoney(totalMid) + ' đồng (Khoản 4 Điều 23 Luật XLVPHC)\n';
  if (maxPoints > 0) {
    text += '2. Trừ điểm GPLX: ' + maxPoints + ' điểm (Áp dụng Điểm b Khoản 1 Điều 50: Chỉ trừ điểm đối với hành vi bị trừ nhiều nhất)\n';
  } else {
    text += '2. Trừ điểm GPLX: Không áp dụng\n';
  }

  var detentions = selected.filter(function(o) { return o.detention; });
  if (detentions.length > 0 || unpresented) {
    text += '\nIII. BIỆN PHÁP NGĂN CHẶN / TẠM GIỮ (ĐIỀU 48):\n';
    text += '• Tạm giữ phương tiện theo Khoản 1 Điều 48 để ngăn chặn ngay hành vi vi phạm.\n';
  }

  var allRemedies = [];
  selected.forEach(function(o) {
    if (o.remedies && o.remedies.length > 0) {
      o.remedies.forEach(function(r) {
        if (!allRemedies.includes(r)) allRemedies.push(r);
      });
    }
  });

  if (allRemedies.length > 0) {
    text += '\nIV. BIỆN PHÁP KHẮC PHỤC HẬU QUẢ BẮT BUỘC THỰC HIỆN:\n';
    allRemedies.forEach(function(r) {
      text += '• ' + r + '\n';
    });
  }

  if (unpresented) {
    text += '\nV. QUY TRÌNH KHÔNG XUẤT TRÌNH GIẤY TỜ TẠI HIỆN TRƯỜNG (KHOẢN 3 ĐIỀU 48):\n';
    text += '• Lập biên bản người lái về hành vi không có giấy tờ và lập biên bản chủ xe theo Điều 32, tạm giữ phương tiện.\n';
    text += '• Hẹn ngày giải quyết: Nếu xuất trình được giấy tờ trong thời hạn hẹn thì không xử phạt lỗi không có giấy tờ và không phạt chủ xe (Điểm c Khoản 3 Điều 48).\n';
  }

  text += '==================================================\n';

  document.getElementById('minutesText').innerText = text;
  document.getElementById('minutesModal').style.display = 'flex';
}

function closeMinutesModal() {
  document.getElementById('minutesModal').style.display = 'none';
}

function copyMinutes() {
  var text = document.getElementById('minutesText').innerText;
  navigator.clipboard.writeText(text).then(function() {
    alert('Đã sao chép nội dung biên bản vào bộ nhớ tạm!');
  });
}

function openDetailModal(id) {
  var off = DATABASE.find(function(o) { return o.id === id; });
  if (!off) return;

  var midpoint = (off.fineMin && off.fineMax) ? Math.round((off.fineMin + off.fineMax) / 2) : null;
  var el = document.getElementById('detailContent');
  var midHtml = midpoint ? '<div class="fine-midpoint" style="display:inline-block; margin-top:4px; font-size:14px;">Mức phạt trung bình: ' + formatMoney(midpoint) + ' đồng</div>' : '';
  var pointsHtml = off.points ? '<div style="font-weight:700; font-size:12.5px; color:var(--danger); margin-bottom:3px;">2. Trừ điểm GPLX:</div><div style="font-size:13px; margin-bottom:12px;">Trừ <b>' + off.points + ' điểm</b> vào hệ thống dữ liệu GPLX (Điều 50 & 51).</div>' : '';
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
    '<div style="font-weight:700; font-size:12.5px; color:#455A64; margin-bottom:3px;">6. Căn cứ pháp lý:</div>' +
    '<div style="font-size:12.5px; color:#263238; background:#ECEFF1; padding:8px 10px; border-radius:6px; line-height:1.45;"><b>' + off.primaryRef + '</b> - Nghị định số 168/2024/NĐ-CP ngày 26/12/2024 của Chính phủ quy định xử phạt vi phạm hành chính về trật tự, an toàn giao thông trong lĩnh vực giao thông đường bộ; trừ điểm, phục hồi điểm giấy phép lái xe (được sửa đổi, bổ sung tại Nghị định số 238/2026/NĐ-CP ngày 26/6/2026 của Chính phủ).</div>' +
    '<button class="btn-primary" style="margin-top:16px;" onclick="closeDetailModal()">ĐÓNG</button>';
  document.getElementById('detailModal').style.display = 'flex';
}

function closeDetailModal() {
  document.getElementById('detailModal').style.display = 'none';
}

function calculateSpeed() {
  var v = document.getElementById('speedVeh').value;
  var m = parseFloat(document.getElementById('speedMeasured').value) || 0;
  var l = parseFloat(document.getElementById('speedLimit').value) || 0;
  var excess = m - l;
  var el = document.getElementById('speedResult');

  if (excess < 5) {
    el.style.background = '#E8F5E9';
    el.innerHTML = '<span style="color:#2E7D32; font-weight:bold;">Vượt dưới 5 km/h không bị xử phạt vi phạm hành chính.</span>';
    return;
  }

  el.style.background = '#FFEBEE';
  if (v === 'car') {
    if (excess >= 5 && excess < 10) el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm a Khoản 3 Điều 6: Phạt <b>800k - 1 triệu</b> (Mức TB: <b>900 nghìn</b>)';
    else if (excess >= 10 && excess <= 20) el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm đ Khoản 5 Điều 6: Phạt <b>4 - 6 triệu</b> (Mức TB: <b>5 triệu</b>), <b>trừ 02 điểm GPLX</b>';
    else if (excess > 20 && excess <= 35) el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm a Khoản 6 Điều 6: Phạt <b>6 - 8 triệu</b> (Mức TB: <b>7 triệu</b>), <b>trừ 04 điểm GPLX</b>';
    else el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm a Khoản 7 Điều 6: Phạt <b>12 - 14 triệu</b> (Mức TB: <b>13 triệu</b>), <b>trừ 06 điểm GPLX</b>';
  } else {
    if (excess >= 5 && excess < 10) el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm b Khoản 2 Điều 7: Phạt <b>400k - 600k</b> (Mức TB: <b>500 nghìn</b>)';
    else if (excess >= 10 && excess <= 20) el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm a Khoản 4 Điều 7: Phạt <b>800k - 1 triệu</b> (Mức TB: <b>900 nghìn</b>)';
    else el.innerHTML = '<b>Vượt ' + excess.toFixed(1) + ' km/h</b> -> Điểm a Khoản 8 Điều 7: Phạt <b>6 - 8 triệu</b> (Mức TB: <b>7 triệu</b>), <b>trừ 04 điểm GPLX</b>';
  }
}

function calculateAlcohol() {
  var v = document.getElementById('alcVeh').value;
  var b = parseFloat(document.getElementById('alcBreath').value) || 0;
  var el = document.getElementById('alcResult');

  if (v === 'motorcycle') {
    if (b <= 0.25) el.innerHTML = '<b>Mức 1 (≤ 0,25 mg/L)</b> -> Điểm a Khoản 6 Điều 7: Phạt <b>2 - 3 triệu</b> (TB: <b>2.5 triệu</b>), trừ <b>04 điểm GPLX</b>, <b>tạm giữ xe</b> (Đ.48)';
    else if (b <= 0.40) el.innerHTML = '<b>Mức 2 (>0,25 đến 0,40 mg/L)</b> -> Điểm b Khoản 8 Điều 7: Phạt <b>6 - 8 triệu</b> (TB: <b>7 triệu</b>), trừ <b>10 điểm GPLX</b>, <b>tạm giữ xe</b> (Đ.48)';
    else el.innerHTML = '<b>Mức 3 (>0,40 mg/L)</b> -> Điểm d Khoản 9 & Điểm c Khoản 12 Điều 7: Phạt <b>8 - 10 triệu</b> (TB: <b>9 triệu</b>), <b>tước GPLX 22 - 24 tháng</b>, <b>tạm giữ xe</b> (Đ.48)';
  } else {
    if (b <= 0.25) el.innerHTML = '<b>Mức 1 (≤ 0,25 mg/L)</b> -> Điểm c Khoản 6 Điều 6: Phạt <b>6 - 8 triệu</b> (TB: <b>7 triệu</b>), trừ <b>04 điểm GPLX</b>, <b>tạm giữ xe</b> (Đ.48)';
    else if (b <= 0.40) el.innerHTML = '<b>Mức 2 (>0,25 đến 0,40 mg/L)</b> -> Điểm a Khoản 9 Điều 6: Phạt <b>18 - 20 triệu</b> (TB: <b>19 triệu</b>), trừ <b>10 điểm GPLX</b>, <b>tạm giữ xe</b> (Đ.48)';
    else el.innerHTML = '<b>Mức 3 (>0,40 mg/L)</b> -> Điểm a Khoản 11 & Điểm c Khoản 15 Điều 6: Phạt <b>30 - 40 triệu</b> (TB: <b>35 triệu</b>), <b>tước GPLX 22 - 24 tháng</b>, <b>tạm giữ xe</b> (Đ.48)';
  }
}

function calculateLicense() {
  var v = document.getElementById('licVeh').value;
  var el = document.getElementById('licResult');
  if (v === 'motorcycle') el.innerHTML = '<b>Xe máy ≤ 125cc (110cc)</b> -> Điểm a Khoản 5 Điều 18: Phạt <b>2 - 4 triệu</b> (Mức TB: <b>3 triệu</b>), <b>tạm giữ phương tiện</b> (Khoản 1 Điểm i Điều 48)';
  else if (v === 'motorcycle_150') el.innerHTML = '<b>Xe máy > 125cc (150cc...)</b> -> Điểm b Khoản 7 Điều 18: Phạt <b>6 - 8 triệu</b> (Mức TB: <b>7 triệu</b>), <b>tạm giữ phương tiện</b> (Khoản 1 Điểm i Điều 48)';
  else el.innerHTML = '<b>Xe Ô tô</b> -> Điểm b Khoản 9 Điều 18: Phạt <b>18 - 20 triệu</b> (Mức TB: <b>19 triệu</b>), <b>tạm giữ phương tiện</b> (Khoản 1 Điểm i Điều 48)';
}

function calculateOwner() {
  var v = document.getElementById('ownerVeh').value;
  var el = document.getElementById('ownerResult');
  if (v === 'motorcycle') el.innerHTML = '<b>Giao xe Mô tô, xe gắn máy</b> -> Khoản 10 Điều 32: Cá nhân phạt <b>8 - 10 triệu</b> (TB: <b>9 triệu</b>), Tổ chức phạt <b>16 - 20 triệu</b> (TB: <b>18 triệu</b>); <b>tạm giữ phương tiện</b> (Khoản 1 Điểm l Điều 48)';
  else el.innerHTML = '<b>Giao xe Ô tô</b> -> Điểm i Khoản 14 Điều 32: Cá nhân phạt <b>28 - 30 triệu</b> (TB: <b>29 triệu</b>), Tổ chức phạt <b>56 - 60 triệu</b> (TB: <b>58 triệu</b>); <b>tạm giữ phương tiện</b> (Khoản 1 Điểm l Điều 48)';
}

function switchTab(tab) {
  document.querySelectorAll('.nav-item').forEach(function(el) { el.classList.remove('active'); });
  document.getElementById('viewHome').style.display = 'none';
  document.getElementById('viewTTKS').style.display = 'none';
  document.getElementById('viewTools').style.display = 'none';
  document.getElementById('viewArticles').style.display = 'none';

  if (tab === 'home') {
    document.getElementById('bnavHome').classList.add('active');
    document.getElementById('viewHome').style.display = 'block';
  } else if (tab === 'ttks') {
    document.getElementById('bnavTTKS').classList.add('active');
    document.getElementById('viewTTKS').style.display = 'block';
    renderTtksChecklist();
  } else if (tab === 'tools') {
    document.getElementById('bnavTools').classList.add('active');
    document.getElementById('viewTools').style.display = 'block';
    calculateSpeed();
    calculateAlcohol();
    calculateLicense();
    calculateOwner();
  } else if (tab === 'articles') {
    document.getElementById('bnavArticles').classList.add('active');
    document.getElementById('viewArticles').style.display = 'block';
  }
  window.scrollTo(0, 0);
}

// Initial Load
DATABASE = JSON.parse(DATABASE_JSON_STR);
renderList(DATABASE);
