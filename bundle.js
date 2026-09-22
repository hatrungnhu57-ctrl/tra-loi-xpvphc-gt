const fs = require('fs');
const path = require('path');

const fullDb = fs.readFileSync(path.join(__dirname, 'full_legal_database.json'), 'utf8');
const appJs = fs.readFileSync(path.join(__dirname, 'app.js'), 'utf8');

// Copy app.js to web/public
fs.writeFileSync(path.join(__dirname, 'web/public/app.js'), appJs, 'utf8');

// Let's create index.html with inline DB and script
const htmlHeader = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">

  <title>TRA LỖI GT PRO</title>
  <meta name="description" content="Tra cứu vi phạm giao thông và trợ lý TTKS lập biên bản nhanh theo NĐ 168 & NĐ 238">
  <link rel="manifest" href="manifest.json">
  <meta name="theme-color" content="#0D47A1">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="Tra Lỗi GT">
  <link rel="icon" type="image/svg+xml" href="icon.svg">
  <link rel="apple-touch-icon" href="icon.svg">

  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700;900&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #0D47A1;
      --primary-dark: #002171;
      --primary-light: #E3F2FD;
      --danger: #C62828;
      --warning: #E65100;
      --success: #2E7D32;
      --teal: #00695C;
      --purple: #6A1B9A;
      --bg: #F4F6FA;
      --card-bg: #FFFFFF;
      --text-main: #212121;
      --text-muted: #546E7A;
      --border: #E0E0E0;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Roboto', -apple-system, sans-serif; -webkit-tap-highlight-color: transparent; }
    body { background-color: var(--bg); color: var(--text-main); line-height: 1.5; padding-bottom: 90px; }

    /* Mobile Header */
    header {
      background: linear-gradient(135deg, var(--primary), var(--primary-dark));
      color: white;
      padding: env(safe-area-inset-top, 12px) 16px 14px;
      position: sticky;
      top: 0;
      z-index: 100;
      box-shadow: 0 3px 10px rgba(0,0,0,0.18);
    }
    .header-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }
    .header-title { font-size: 18px; font-weight: 900; letter-spacing: 0.3px; display: flex; align-items: center; gap: 6px; }
    .badge-offline { background: #00C853; color: white; font-size: 10px; font-weight: 800; padding: 2px 7px; border-radius: 10px; }

    /* Search Box */
    .search-box {
      background: white;
      border-radius: 12px;
      display: flex;
      align-items: center;
      padding: 4px 8px 4px 12px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.12);
    }
    .search-box input {
      border: none;
      outline: none;
      flex: 1;
      font-size: 15px;
      padding: 8px 4px;
      color: var(--text-main);
    }
    .btn-clear {
      background: none;
      border: none;
      color: #9E9E9E;
      font-size: 16px;
      padding: 6px;
      cursor: pointer;
      display: none;
    }
    .btn-mic {
      background: #F5F5F5;
      border: none;
      color: var(--primary);
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      cursor: pointer;
      margin-right: 4px;
    }
    .btn-search {
      background: var(--primary);
      border: none;
      color: white;
      padding: 8px 14px;
      border-radius: 8px;
      font-weight: 800;
      cursor: pointer;
      font-size: 13px;
    }

    /* Container */
    .container { max-width: 620px; margin: 0 auto; padding: 12px 14px; }

    /* Category Filter Pills */
    .cat-pills-row {
      display: flex;
      gap: 8px;
      overflow-x: auto;
      padding: 4px 0 10px;
      margin-bottom: 6px;
      scrollbar-width: none;
    }
    .cat-pills-row::-webkit-scrollbar { display: none; }
    .cat-pill {
      white-space: nowrap;
      padding: 7px 14px;
      background: white;
      border: 1px solid var(--border);
      border-radius: 20px;
      font-size: 12.5px;
      font-weight: 700;
      color: var(--text-muted);
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 5px;
      flex-shrink: 0;
    }
    .cat-pill.active {
      background: var(--primary);
      color: white;
      border-color: var(--primary);
      box-shadow: 0 2px 6px rgba(13, 71, 161, 0.3);
    }

    /* Quick Suggestion Chips */
    .chip-list { display: flex; flex-wrap: wrap; gap: 6px; margin: 8px 0 14px; }
    .chip {
      background: white;
      border: 1px solid #BBDEFB;
      color: var(--primary);
      padding: 5px 11px;
      border-radius: 16px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
    }

    /* Mobile Bottom Navigation Bar */
    .bottom-nav {
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: white;
      display: flex;
      justify-content: space-around;
      padding: 6px 0 env(safe-area-inset-bottom, 8px);
      box-shadow: 0 -3px 12px rgba(0,0,0,0.08);
      border-top: 1px solid #EEEEEE;
      z-index: 200;
    }
    .nav-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      color: #78909C;
      text-decoration: none;
      font-size: 11px;
      font-weight: 700;
      padding: 4px 12px;
      border-radius: 8px;
      cursor: pointer;
      transition: color 0.15s;
    }
    .nav-item .nav-icon { font-size: 20px; margin-bottom: 2px; }
    .nav-item.active { color: var(--primary); }

    /* Cards */
    .card {
      background: white;
      border-radius: 14px;
      padding: 14px;
      margin-bottom: 10px;
      border: 1px solid var(--border);
      box-shadow: 0 2px 5px rgba(0,0,0,0.02);
    }
    .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
    .vehicle-tag { background: #E3F2FD; color: #1565C0; padding: 2px 7px; border-radius: 5px; font-size: 11px; font-weight: 700; }
    .legal-ref { font-size: 11.5px; font-weight: 800; color: #455A64; }
    .offense-name { font-size: 14.5px; font-weight: 700; line-height: 1.35; margin-bottom: 6px; color: #212121; }

    .fine-row {
      display: flex;
      align-items: baseline;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 4px;
    }
    .fine-amount { font-size: 15.5px; font-weight: 900; color: var(--danger); }
    .fine-midpoint { font-size: 12.5px; font-weight: 800; color: #0277BD; background: #E1F5FE; padding: 2px 8px; border-radius: 6px; }
    .fine-warning { color: var(--warning); }

    .badges-row { display: flex; flex-wrap: wrap; gap: 5px; margin-top: 8px; }
    .badge {
      display: inline-flex;
      align-items: center;
      gap: 3px;
      padding: 3px 7px;
      border-radius: 5px;
      font-size: 11px;
      font-weight: 700;
    }
    .badge-points { background: #FFEBEE; color: #C62828; border: 1px solid #FFCDD2; }
    .badge-detention { background: #FBE9E7; color: #D84315; border: 1px solid #FFCCBC; }
    .badge-remedy { background: #E0F2F1; color: #00695C; border: 1px solid #80CBC4; }
    .badge-edit { background: #E0F7FA; color: #00838F; }

    /* Case HUD */
    .case-hud {
      background: #E8EAF6;
      border: 1.5px solid #C5CAE9;
      border-radius: 12px;
      padding: 14px;
      margin-bottom: 12px;
    }
    .hud-title { font-size: 13.5px; font-weight: 900; color: #1A237E; margin-bottom: 8px; }

    /* TTKS Checklist */
    .checklist-item {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 12px 10px;
      border-radius: 10px;
      background: white;
      border: 1px solid var(--border);
      margin-bottom: 7px;
      cursor: pointer;
    }
    .checklist-item.selected {
      background: #E3F2FD;
      border-color: #1976D2;
    }
    .checklist-checkbox { margin-top: 2px; width: 20px; height: 20px; cursor: pointer; flex-shrink: 0; }

    /* Selected Offenses Tray in TTKS */
    .selected-tray {
      background: #FFF3E0;
      border: 1.5px solid #FFE082;
      border-radius: 12px;
      padding: 12px;
      margin-bottom: 14px;
    }
    .selected-tag-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: white;
      padding: 8px 10px;
      border-radius: 8px;
      border: 1px solid #FFD54F;
      margin-top: 6px;
      font-size: 13px;
    }
    .btn-remove-off {
      background: #FFEBEE;
      color: #C62828;
      border: none;
      padding: 3px 8px;
      border-radius: 6px;
      font-weight: bold;
      cursor: pointer;
      font-size: 11px;
    }

    /* Modal */
    .modal-overlay {
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.6);
      display: none;
      align-items: flex-end;
      justify-content: center;
      z-index: 1000;
    }
    .modal-content {
      background: white;
      width: 100%;
      max-width: 600px;
      max-height: 85vh;
      border-radius: 20px 20px 0 0;
      overflow-y: auto;
      padding: 20px 16px env(safe-area-inset-bottom, 20px);
      box-shadow: 0 -8px 24px rgba(0,0,0,0.25);
    }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .btn-close { background: #EEEEEE; border: none; font-size: 16px; width: 32px; height: 32px; border-radius: 50%; cursor: pointer; font-weight: bold; }

    .btn-primary {
      width: 100%;
      background: var(--primary);
      color: white;
      border: none;
      padding: 13px;
      border-radius: 10px;
      font-size: 14.5px;
      font-weight: 800;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }
    .btn-yellow {
      background: #FFD54F;
      color: #212121;
      font-weight: 900;
    }

    .form-control {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid var(--border);
      border-radius: 8px;
      font-size: 14px;
      outline: none;
    }

    pre.minutes-box {
      background: #263238;
      color: #ECEFF1;
      padding: 12px;
      border-radius: 10px;
      font-size: 12px;
      line-height: 1.45;
      white-space: pre-wrap;
      max-height: 320px;
      overflow-y: auto;
      font-family: monospace;
    }
  </style>
</head>
<body>

  <!-- Mobile Header -->
  <header>
    <div class="container" style="padding: 0;">
      <div class="header-top">
        <div class="header-title">
          <span>⚖️ TRA LỖI GT PRO</span>
          <span class="badge-offline">OFFLINE</span>
        </div>
        <div style="font-size: 11.5px; color: #BBDEFB;">NĐ 168 & NĐ 238</div>
      </div>
      <div class="search-box">
        <input type="text" id="searchInput" placeholder="Tra cứu: mũ bảo hiểm, 150cc k gplx, 76/60..." />
        <button class="btn-clear" id="btnClear" onclick="clearSearch()">✕</button>
        <button class="btn-mic" id="btnMic" title="Nhận diện giọng nói" onclick="startVoiceRecognition()">🎙️</button>
        <button class="btn-search" onclick="performSearch()">TÌM</button>
      </div>
    </div>
  </header>

  <div class="container">

    <!-- VIEW 1: HOME & SEARCH -->
    <div id="viewHome">
      <!-- Category Filter Pills -->
      <div class="cat-pills-row">
        <button class="cat-pill active" id="catAll" onclick="filterCategory('all')">Tất cả (475 lỗi)</button>
        <button class="cat-pill" id="catMoto" onclick="filterCategory('motorcycle')">🏍️ Xe Máy</button>
        <button class="cat-pill" id="catCar" onclick="filterCategory('car')">🚗 Xe Ô tô</button>
        <button class="cat-pill" id="catDriver" onclick="filterCategory('DRIVER')">🪪 GPLX & Giấy tờ</button>
        <button class="cat-pill" id="catRemedy" onclick="filterCategory('REMEDY')">🔧 Khắc phục hậu quả (55)</button>
        <button class="cat-pill" id="catTransport" onclick="filterCategory('TRANSPORT')">🚚 Vận tải & Quá tải</button>
        <button class="cat-pill" id="catOwner" onclick="filterCategory('OWNER')">👤 Chủ xe (Đ.32)</button>
        <button class="cat-pill" id="catVehicle" onclick="filterCategory('VEHICLE')">🔧 Thiết bị xe</button>
      </div>

      <!-- Quick Chips -->
      <div class="chip-list">
        <div class="chip" onclick="quickSearch('mũ bảo hiểm')">mũ bảo hiểm</div>
        <div class="chip" onclick="quickSearch('xe máy 150 không bằng')">xe máy 150 không bằng</div>
        <div class="chip" onclick="quickSearch('150cc k gplx')">150cc k gplx</div>
        <div class="chip" onclick="quickSearch('oto 76/60')">oto 76/60</div>
        <div class="chip" onclick="quickSearch('cồn 0.32 moto')">cồn 0.32 moto</div>
        <div class="chip" onclick="quickSearch('kẹp 3')">kẹp 3</div>
        <div class="chip" onclick="quickSearch('giao xe cho người không bằng')">giao xe cho người không bằng</div>
        <div class="chip" onclick="quickSearch('điểm g khoản 2 điều 7')">điểm g khoản 2 điều 7</div>
        <div class="chip" onclick="quickSearch('không gương')">không gương</div>
        <div class="chip" onclick="quickSearch('quá tải')">quá tải (10% - 150%)</div>
      </div>

      <!-- Case HUD if search applied -->
      <div id="caseHudContainer" style="display: none;"></div>

      <div style="font-size: 14.5px; font-weight: 800; margin: 12px 0 8px;" id="resultsHeader">Toàn bộ 475 hành vi vi phạm (NĐ 168/2024 & NĐ 238/2026):</div>
      <div id="offenseList"></div>
    </div>

    <!-- VIEW 2: TTKS PATROL & MINUTES BUILDER -->
    <div id="viewTTKS" style="display: none;">
      <div class="card" style="background: #E3F2FD; border-color: #90CAF9;">
        <div style="font-weight: 800; font-size: 14.5px; color: var(--primary); margin-bottom: 4px;">
          👮‍♂️ TRỢ LÝ TTKS & LẬP BI��N BẢN VPHC
        </div>
        <div style="font-size: 12px; color: var(--text-muted);">
          Tích chọn các lỗi thực tế -> Hệ thống tự tính tổng tiền phạt, <b>mức phạt trung bình</b>, tự áp dụng <b>chỉ trừ điểm lỗi cao nhất (Đ.50.1.b)</b>, tước GPLX (Đ.5.2), <b>biện pháp khắc phục hậu quả</b> và tạo mẫu BBVPHC chuẩn.
        </div>
      </div>

      <!-- Selected Offenses Tray -->
      <div id="selectedTray" class="selected-tray" style="display: none;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-weight: 800; font-size: 13.5px; color: #E65100;">📋 CÁC LỖI ĐÃ TÍCH CHỌN (<span id="trayCount">0</span>):</span>
          <button style="background: none; border: none; color: #C62828; font-size: 12px; font-weight: bold; cursor: pointer;" onclick="clearAllSelected()">Xóa tất cả</button>
        </div>
        <div id="selectedListItems"></div>
      </div>

      <div class="card">
        <div style="display: flex; gap: 6px; margin-bottom: 10px;">
          <button class="cat-pill active" id="ttksVehMoto" style="flex:1; justify-content:center;" onclick="setTtksVehicle('motorcycle')">🏍️ Xe Máy</button>
          <button class="cat-pill" id="ttksVehCar" style="flex:1; justify-content:center;" onclick="setTtksVehicle('car')">🚗 Xe Ô tô</button>
        </div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px;">
          <input type="text" id="ttksPlate" class="form-control" placeholder="Biển số (29B1-123.45)" style="text-transform: uppercase;" />
          <input type="text" id="ttksName" class="form-control" placeholder="Họ tên người vi phạm" />
        </div>
        <input type="text" id="ttksFilter" class="form-control" placeholder="Lọc nhanh lỗi vi phạm..." oninput="filterTtksList()" />
      </div>

      <div style="font-size: 13.5px; font-weight: 700; margin: 10px 0 6px;">Danh mục hành vi vi phạm:</div>
      <div id="ttksChecklist"></div>

      <!-- Switch Điều 48.3 -->
      <div class="card" style="background: #FFFDE7; border-color: #FFF59D; margin-top: 10px;">
        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 12.5px; font-weight: 700; color: #F57F17;">
          <input type="checkbox" id="chkUnpresented" onchange="updateTtksSummary()" style="width: 18px; height: 18px;" />
          <span>Không xuất trình được giấy tờ tại hiện trường (Khoản 3 Điều 48)</span>
        </label>
      </div>

      <!-- Live Summary Bar -->
      <div class="card" style="background: #263238; color: white; border: none; margin-top: 14px; position: sticky; bottom: 84px; box-shadow: 0 6px 20px rgba(0,0,0,0.35); z-index: 50;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <div>
            <div style="font-size: 11.5px; color: #B0BEC5;" id="ttksSelectedCount">Đã chọn 0 hành vi</div>
            <div style="font-size: 16px; font-weight: 900; color: #FF5252;" id="ttksFineSummary">0 đồng</div>
            <div style="font-size: 12px; font-weight: 800; color: #40C4FF;" id="ttksMidpointSummary"></div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 12.5px; font-weight: 700; color: #FFD54F;" id="ttksPointsSummary">Điểm trừ: 0đ</div>
            <div style="font-size: 11.5px; font-weight: 700; color: #FF8A80;" id="ttksDetentionSummary"></div>
          </div>
        </div>
        <button class="btn-primary btn-yellow" style="margin-top: 6px; padding: 11px;" onclick="openMinutesModal()">
          📝 XUẤT BIÊN BẢN VI PHẠM (BBVPHC)
        </button>
      </div>
    </div>

    <!-- VIEW 3: TOOLS -->
    <div id="viewTools" style="display: none;">
      <!-- Speed Tool -->
      <div class="card">
        <div style="font-weight: 800; font-size: 14.5px; color: var(--danger); margin-bottom: 8px;">🚗 BỘ TÍNH TỐC ĐỘ (SPEED CALCULATOR)</div>
        <div style="display: flex; gap: 6px; margin-bottom: 8px;">
          <select id="speedVeh" class="form-control" style="flex:1" onchange="calculateSpeed()">
            <option value="car">Xe Ô tô</option>
            <option value="motorcycle">Xe Mô tô / Xe máy</option>
          </select>
          <input type="number" id="speedMeasured" class="form-control" placeholder="Tốc độ đo" value="76" style="flex:1" oninput="calculateSpeed()" />
          <input type="number" id="speedLimit" class="form-control" placeholder="Giới hạn" value="60" style="flex:1" oninput="calculateSpeed()" />
        </div>
        <div id="speedResult" style="padding: 10px; border-radius: 8px; background: #FFEBEE; font-size: 13px;"></div>
      </div>

      <!-- Alcohol Tool -->
      <div class="card">
        <div style="font-weight: 800; font-size: 14.5px; color: var(--warning); margin-bottom: 8px;">🍺 BỘ TÍNH NỒNG ĐỘ CỒN</div>
        <div style="display: flex; gap: 6px; margin-bottom: 8px;">
          <select id="alcVeh" class="form-control" style="flex:1" onchange="calculateAlcohol()">
            <option value="motorcycle">Xe Mô tô / Xe máy</option>
            <option value="car">Xe Ô tô</option>
          </select>
          <input type="number" step="0.01" id="alcBreath" class="form-control" placeholder="Khí thở mg/L" value="0.32" style="flex:1" oninput="calculateAlcohol()" />
        </div>
        <div id="alcResult" style="padding: 10px; border-radius: 8px; background: #FFF3E0; font-size: 13px;"></div>
      </div>

      <!-- License & Age Tool -->
      <div class="card">
        <div style="font-weight: 800; font-size: 14.5px; color: var(--primary); margin-bottom: 8px;">🪪 KIỂM TRA GPLX & ĐỘ TUỔI (ĐIỀU 18)</div>
        <div style="margin-bottom: 8px;">
          <select id="licVeh" class="form-control" onchange="calculateLicense()">
            <option value="motorcycle">Xe máy ≤ 125cc (110cc)</option>
            <option value="motorcycle_150">Xe máy > 125cc (150cc...)</option>
            <option value="car">Xe Ô tô</option>
          </select>
        </div>
        <div id="licResult" style="padding: 10px; border-radius: 8px; background: #E3F2FD; font-size: 13px;"></div>
      </div>

            <!-- Overload Tool -->
      <div class="card">
        <div style="font-weight: 800; font-size: 14.5px; color: #E65100; margin-bottom: 8px;">🚚 BỘ TÍNH MỨC PHẠT QUÁ TẢI TRỌNG (ĐIỀU 21 & 32)</div>
        <div style="margin-bottom: 8px;">
          <label style="font-size: 12px; font-weight: bold; color: #546E7A;">Nhập tỷ lệ % quá tải trọng của xe/trục:</label>
          <input type="number" id="overloadPct" class="form-control" placeholder="% quá tải (ví dụ: 25, 45, 75, 120, 160)" value="25" oninput="calculateOverload()" style="margin-top: 4px;" />
        </div>
        <div id="overloadResult" style="padding: 10px; border-radius: 8px; background: #FFF3E0; font-size: 13px; line-height: 1.5;"></div>
      </div>

      <!-- Owner Liability Tool -->
      <div class="card">
        <div style="font-weight: 800; font-size: 14.5px; color: var(--success); margin-bottom: 8px;">👤 TRÁCH NHIỆM CHỦ XE GIAO XE (ĐIỀU 32)</div>
        <div style="margin-bottom: 8px;">
          <select id="ownerVeh" class="form-control" onchange="calculateOwner()">
            <option value="motorcycle">Giao xe Mô tô, xe gắn máy</option>
            <option value="car">Giao xe Ô tô</option>
          </select>
        </div>
        <div id="ownerResult" style="padding: 10px; border-radius: 8px; background: #E8F5E9; font-size: 13px;"></div>
      </div>
    </div>

    <!-- VIEW 4: ARTICLES -->
    <div id="viewArticles" style="display: none;">
      <div class="card">
        <div style="font-weight: 800; font-size: 15px; margin-bottom: 6px; color: var(--primary);">NGUỒN PHÁP LÝ CHÍNH THỨC CỦA CHÍNH PHỦ</div>
        <div style="font-size: 13px; line-height: 1.5; color: #263238; margin-bottom: 12px; background: #E8EAF6; padding: 10px; border-radius: 8px; border-left: 3px solid var(--primary);">
          <b>Nghị định số 168/2024/NĐ-CP ngày 26/12/2024 của Chính phủ</b> quy định xử phạt vi phạm hành chính về trật tự, an toàn giao thông trong lĩnh vực giao thông đường bộ; trừ điểm, phục hồi điểm giấy phép lái xe (được sửa đổi, bổ sung tại <b>Nghị định số 238/2026/NĐ-CP ngày 26/6/2026 của Chính phủ</b>).
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 6: Vi phạm của xe ô tô</div>
          <div style="font-size: 12px; color: var(--text-muted);">Gồm 16 khoản: Phạt cảnh cáo (trẻ em dưới 10 tuổi), Tốc độ, Cồn, TNGT, Tước GPLX, Trừ điểm.</div>
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 7: Vi phạm của xe mô tô, xe máy</div>
          <div style="font-size: 12px; color: var(--text-muted);">Gồm 13 khoản: Chở 2 người (Đ.7.2.g), Mũ bảo hiểm (Đ.7.2.h), Kẹp 3 (Đ.7.3.b), Nồng độ cồn, Gây TNGT.</div>
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 18: Điều kiện người điều khiển (GPLX, tuổi)</div>
          <div style="font-size: 12px; color: var(--text-muted);">Phân định rõ xe máy ≤ 125cc (phạt 2-4tr) vs > 125cc (150cc phạt 6-8tr); Ô tô không GPLX phạt 18-20tr.</div>
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 32: Trách nhiệm Chủ phương tiện (Cá nhân & Tổ chức)</div>
          <div style="font-size: 12px; color: var(--text-muted);">Giao xe máy: Cá nhân 8-10tr, Tổ chức 16-20tr. Giao ô tô: Cá nhân 28-30tr, Tổ chức 56-60tr.</div>
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 48: Tạm giữ phương tiện và giấy tờ</div>
          <div style="font-size: 12px; color: var(--text-muted);">Khoản 1: Tạm giữ ngăn chặn ngay; Khoản 3: Quy trình xử lý không xuất trình giấy tờ tại thời điểm kiểm tra.</div>
        </div>

        <div style="border-left: 3px solid var(--primary); padding-left: 10px;">
          <div style="font-weight: 700; font-size: 13.5px; color: var(--primary);">Điều 50: Nguyên tắc trừ điểm GPLX (Điểm b Khoản 1)</div>
          <div style="font-size: 12px; color: var(--text-muted);">Nhiều hành vi cùng bị trừ điểm trong một lần xử phạt thì <b>CHỈ trừ điểm đối với hành vi bị trừ nhiều nhất</b>.</div>
        </div>
      </div>
    </div>

  </div>

  <!-- Mobile Bottom Navigation Bar -->
  <nav class="bottom-nav">
    <div class="nav-item active" id="bnavHome" onclick="switchTab('home')">
      <span class="nav-icon">🔍</span>
      <span>Tra Cứu</span>
    </div>
    <div class="nav-item" id="bnavTTKS" onclick="switchTab('ttks')">
      <span class="nav-icon">📋</span>
      <span>TTKS</span>
    </div>
    <div class="nav-item" id="bnavTools" onclick="switchTab('tools')">
      <span class="nav-icon">⚡</span>
      <span>Bảng Tính</span>
    </div>
    <div class="nav-item" id="bnavArticles" onclick="switchTab('articles')">
      <span class="nav-icon">📖</span>
      <span>Nghị Định</span>
    </div>
  </nav>

  <!-- MODAL: BIÊN BẢN VI PHẠM HÀNH CHÍNH -->
  <div class="modal-overlay" id="minutesModal">
    <div class="modal-content">
      <div class="modal-header">
        <div style="font-weight: 800; font-size: 15px; color: var(--primary);">📝 NỘI DUNG BIÊN BẢN VPHC</div>
        <button class="btn-close" onclick="closeMinutesModal()">✕</button>
      </div>
      <pre class="minutes-box" id="minutesText"></pre>
      <div style="display: flex; gap: 8px; margin-top: 14px;">
        <button class="btn-primary" style="margin-top: 0; background: var(--success); flex: 2;" onclick="copyMinutes()">
          📋 SAO CHÉP BIÊN BẢN
        </button>
        <button class="btn-primary" style="margin-top: 0; background: #78909C; flex: 1;" onclick="closeMinutesModal()">
          ĐÓNG
        </button>
      </div>
    </div>
  </div>

  <!-- MODAL: CHI TIẾT HÀNH VI -->
  <div class="modal-overlay" id="detailModal">
    <div class="modal-content" id="detailContent"></div>
  </div>

  <script>
    var DATABASE_JSON_STR = ${JSON.stringify(fullDb)};
  </script>
  <script src="app.js"></script>
</body>
</html>`;

fs.writeFileSync(path.join(__dirname, 'index.html'), htmlHeader, 'utf8');
fs.writeFileSync(path.join(__dirname, 'web/public/index.html'), htmlHeader, 'utf8');
console.log('Successfully bundled index.html and app.js');
