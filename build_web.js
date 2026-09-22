const fs = require('fs');
const path = require('path');

const fullDb = fs.readFileSync(path.join(__dirname, 'full_legal_database.json'), 'utf8');

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
          👮‍♂️ TRỢ LÝ TTKS & LẬP BIÊN BẢN VPHC
        </div>
        <div style="font-size: 12px; color: var(--text-muted);">
          Tích chọn các lỗi thực tế -> Hệ thống tự tính tổng tiền phạt, <b>mức phạt trung bình</b>, tự áp dụng <b>chỉ trừ điểm lỗi cao nhất (Đ.50.1.b)</b>, tước GPLX (Đ.5.2) và tạo mẫu BBVPHC chuẩn.
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
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('./service-worker.js').catch(function() {});
    }

    var DATABASE = `;

const htmlFooter = `;

    function removeDiacritics(str) {
      if (!str) return '';
      return str.normalize('NFD').replace(/[\\u0300-\\u036f]/g, '').replace(/[đĐ]/g, 'd');
    }

    function normalize(str) {
      if (!str) return '';
      var text = str.trim().toLowerCase();
      text = text.replace(/[,;!?()\"\\x27\\[\\]{}]/g, ' ');
      text = text.replace(/(?<![a-zA-Z0-9])\\.|\\.(?![a-zA-Z0-9])/g, ' ');
      return text.replace(/\\s+/g, ' ').trim();
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
      var pills = ['catAll', 'catMoto', 'catCar', 'catDriver', 'catTransport', 'catOwner', 'catVehicle'];
      pills.forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.classList.remove('active');
      });

      var activeMap = {
        'all': 'catAll',
        'motorcycle': 'catMoto',
        'car': 'catCar',
        'DRIVER': 'catDriver',
        'TRANSPORT': 'catTransport',
        'OWNER': 'catOwner',
        'VEHICLE': 'catVehicle'
      };
      var activeEl = document.getElementById(activeMap[cat] || 'catAll');
      if (activeEl) activeEl.classList.add('active');

      if (cat === 'all') {
        document.getElementById('resultsHeader').innerText = 'Toàn bộ ' + DATABASE.length + ' hành vi vi phạm (NĐ 168/2024 & NĐ 238/2026):';
        renderList(DATABASE);
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
          pointsBadge + detBadge + editBadge +
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
      var p1 = /diem\\s+([a-zd])\\s+khoan\\s+([0-9]+[a-z]?)\\s+dieu\\s+([0-9]+)/i;
      var m1 = unaccented.match(p1);
      var pDot = /^([a-zd])\\.([0-9]+[a-z]?)\\.([0-9]+)$/i;
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
        var slash = unaccented.match(/([0-9]{2,3})\\s*\\/\\s*([0-9]{2,3})/);
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
        var alc = unaccented.match(/0\\.[0-9]+/);
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

          hudContent = '<div class="case-hud">' +
            '<div class="hud-title">⚖️ ĐÁNH GIÁ TỔNG HỢP VỤ VIỆC</div>' +
            '<div style="display:flex; align-items:baseline; gap:8px; flex-wrap:wrap;">' +
              '<div style="font-weight:bold; color:var(--danger); font-size:14.5px;">Mức phạt tiền: ' + formatMoney(fineSumMin) + ' - ' + formatMoney(fineSumMax) + ' đồng</div>' +
              '<div class="fine-midpoint">Mức TB: ' + formatMoney(midSum) + '</div>' +
            '</div>' +
            (maxPoints > 0 ? '<div style="font-weight:700; color:#D32F2F; font-size:12.5px; margin-top:3px;">Trừ điểm GPLX: <b>' + maxPoints + ' điểm</b> (Áp dụng Điều 50.1.b: Chỉ trừ điểm lỗi cao nhất)</div>' : '') +
            (hasDetention ? '<div style="font-weight:700; color:#D84315; font-size:12.5px; margin-top:3px;">Biện pháp: Tạm giữ phương tiện theo Điều 48</div>' : '') +
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
        if (off.points || off.detention) {
          badges = '<div style="font-size:11px; font-weight:700; margin-top:2px;">' +
            (off.points ? '<span style="color:#C62828;">Trừ ' + off.points + 'đ GPLX</span> ' : '') +
            (off.detention ? '<span style="color:#D84315;">• Tạm giữ xe (Đ.48)</span>' : '') +
          '</div>';
        }

        return '<div class="checklist-item ' + (isChecked ? 'selected' : '') + '" onclick="toggleTtksOffense(\\'' + off.id + '\\')">' +
          '<input type="checkbox" class="checklist-checkbox" ' + (isChecked ? 'checked' : '') + ' onclick="event.stopPropagation(); toggleTtksOffense(\\'' + off.id + '\\')" />' +
          '<div style="flex:1;">' +
            '<div style="font-size:13.5px; font-weight:' + (isChecked ? 'bold' : '600') + '; color:#212121;\">' + off.canonical + '</div>' +
            '<div style="display:flex; justify-content:space-between; align-items:center; margin-top:3px; font-size:11.5px;\">' +
              '<span style="font-weight:700; color:#455A64;">' + off.primaryRef + '</span>' +
              '<span style="font-weight:800; color:' + (off.isWarning ? 'var(--warning)' : 'var(--danger)') + ';\">' + fineText + ' ' + midBadge + '</span>' +
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
              '</div>' +
            '</div>' +
            '<button class="btn-remove-off" onclick="toggleTtksOffense(\\'' + o.id + '\\')">XÓA</button>' +
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

      var text = '=== TÓM TẮT BIÊN BẢN VI PHẠM HÀNH CHÍNH (TTKS) ===\\n';
      text += 'Thời gian: ' + timeStr + '\\n';
      text += 'Đối tượng vi phạm: ' + name + ' | Phương tiện: ' + plate + ' (' + (ttksSelectedVehicle === 'car' ? 'Ô tô' : 'Mô tô/Xe máy') + ')\\n';
      text += '--------------------------------------------------\\n';
      text += 'I. CÁC HÀNH VI VI PHẠM XÁC ĐỊNH (' + selected.length + '):\\n';
      selected.forEach(function(o, i) {
        var mid = (o.fineMin && o.fineMax) ? Math.round((o.fineMin + o.fineMax) / 2) : null;
        text += (i+1) + '. ' + o.canonical + '\\n';
        text += '   - Căn cứ pháp lý: ' + o.primaryRef + ' Nghị định số 168/2024/NĐ-CP (được sửa đổi, bổ sung tại Nghị định số 238/2026/NĐ-CP ngày 26/6/2026 của Chính phủ)\\n';
        text += '   - Khung phạt: ' + (o.isWarning ? 'Phạt cảnh cáo' : (formatMoney(o.fineMin) + ' - ' + formatMoney(o.fineMax) + ' đồng (Mức TB: ' + formatMoney(mid) + ')')) + '\\n';
        if (o.points) text += '   - Mức trừ điểm theo quy định lỗi: ' + o.points + ' điểm\\n';
      });

      text += '\\nII. QUYẾT ĐỊNH XỬ PHẠT TỔNG HỢP:\\n';
      text += '1. Khung phạt tiền: ' + formatMoney(totalMin) + ' - ' + formatMoney(totalMax) + ' đồng\\n';
      text += '   -> Mức phạt trung bình áp dụng: ' + formatMoney(totalMid) + ' đồng (Khoản 4 Điều 23 Luật XLVPHC)\\n';
      if (maxPoints > 0) {
        text += '2. Trừ điểm GPLX: ' + maxPoints + ' điểm (Áp dụng Điểm b Khoản 1 Điều 50: Chỉ trừ điểm đối với hành vi bị trừ nhiều nhất)\\n';
      } else {
        text += '2. Trừ điểm GPLX: Không áp dụng\\n';
      }

      var detentions = selected.filter(function(o) { return o.detention; });
      if (detentions.length > 0 || unpresented) {
        text += '\\nIII. BIỆN PHÁP NGĂN CHẶN / TẠM GIỮ (ĐIỀU 48):\\n';
        text += '• Tạm giữ phương tiện theo Khoản 1 Điều 48 để ngăn chặn ngay hành vi vi phạm.\\n';
      }

      if (unpresented) {
        text += '\\nIV. QUY TRÌNH KHÔNG XUẤT TRÌNH GIẤY TỜ TẠI HIỆN TRƯỜNG (KHOẢN 3 ĐIỀU 48):\\n';
        text += '• Lập biên bản người lái về hành vi không có giấy tờ và lập biên bản chủ xe theo Điều 32, tạm giữ phương tiện.\\n';
        text += '• Hẹn ngày giải quyết: Nếu xuất trình được giấy tờ trong thời hạn hẹn thì không xử phạt lỗi không có giấy tờ và không ph��t chủ xe (Điểm c Khoản 3 Điều 48).\\n';
      }

      text += '==================================================\\n';

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
      var excHtml = (off.exceptions && Array.isArray(off.exceptions)) ? '<div style="font-weight:700; font-size:12.5px; color:var(--success); margin-bottom:3px;">4. Trường hợp ngoại lệ:</div><div style="font-size:13px; margin-bottom:12px;">' + off.exceptions.map(function(e) { return '• ' + e; }).join('<br>') + '</div>' : '';

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
        pointsHtml + detHtml + excHtml +
        '<div style="font-weight:700; font-size:12.5px; color:#455A64; margin-bottom:3px;">5. Căn cứ pháp lý:</div>' +
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

    renderList(DATABASE);
  </script>
</body>
</html>`;

const finalHtml = htmlHeader + fullDb + htmlFooter;

fs.writeFileSync(path.join(__dirname, 'index.html'), finalHtml, 'utf8');
fs.writeFileSync(path.join(__dirname, 'web/public/index.html'), finalHtml, 'utf8');
console.log('Successfully written index.html with full official Decree title!');
