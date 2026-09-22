import re
import json

with open('/Users/hatrungnhu/Downloads/full_decree_text.txt', 'r', encoding='utf-8') as f:
    raw = f.read()

# 1. Clean PAGE headers and page numbers
clean = re.sub(r'=== PAGE \d+ ===\s*(?:\d+)?', '', raw)
clean = re.sub(r'\n\s*\d{1,2}\s*\n', '\n', clean)

# 2. Clean footnote blocks at bottom of pages
clean = re.sub(r'\n\s*\d{1,2}\s+(?:Điểm này|Khoản này|Điều này|Đoạn này|Cụm từ|Từ|Các cụm từ)[^\n]+(?:\n\s*(?:Nghị định|của Chính phủ|quy định tại|bổ sung|phủ)[^\n]+)*', '\n', clean, flags=re.IGNORECASE)

# 3. Clean superscript digits attached to words
def clean_superscripts(text):
    text = re.sub(r'\)(\d{1,2})\b', ')', text)
    text = re.sub(r'(?<=[a-zA-ZÀ-ỹ])(?<!cm)(?<!m)(?<!km)(?<!kW)(\d{1,2})(?=[,;:\s\.\)\]\-]|$)', '', text)
    text = re.sub(r',\s*\d{1,2}\s+', ', ', text)
    text = re.sub(r'^[a-zđ]\.\d+\]\s*', '', text, flags=re.MULTILINE)
    return text

clean = clean_superscripts(clean)

# Also clean any leaked footnote phrases
def clean_leaked_phrases(s):
    if not s: return s
    res = s
    res = re.sub(r';?\s*(?:để người nằm, ngồi, đu bám bên ngoài xe khi xe đang chạy”\s*)?theo quy định tại khoản \d+ Điều \d+ Nghị định số 238[^\n;]*', '', res, flags=re.IGNORECASE)
    res = re.sub(r';?\s*theo quy định tại (?:khoản|điểm|Điều) \d+[^\n;]*Nghị định số 238[^\n;]*', '', res, flags=re.IGNORECASE)
    res = re.sub(r';?\s*được (?:sửa đổi|bổ sung|thay thế|bãi bỏ) theo quy định tại[^\n;]*', '', res, flags=re.IGNORECASE)
    res = re.sub(r';?\s*Cụm từ [“\"].*?[”\"]\s*được (?:thay thế|bổ sung|bỏ)[^\n;]*', '', res, flags=re.IGNORECASE)
    res = re.sub(r'của Chính phủ\s+của Chính phủ', 'của Chính phủ', res, flags=re.IGNORECASE)
    res = re.sub(r'\[\s*PT\s*\]', '', res, flags=re.IGNORECASE)
    # Remove dangling bracket notes e.g. [Gây TNGT 20tr-22tr –
    res = re.sub(r'\[.*?\]', '', res)
    res = re.sub(r'\[[^\n\]]*$', '', res)
    res = re.sub(r'---\s*PAGE\s*\d+\s*---\s*(?:\d+)?', '', res, flags=re.IGNORECASE)
    res = re.sub(r'\b\d+\s+Chương\b', '', res, flags=re.IGNORECASE)
    res = re.sub(r'[;,\-–]\s*$', '', res)
    return re.sub(r'\s+', ' ', res).strip()

def parse_vnd(s):
    if not s: return None
    clean_s = re.sub(r'[\.\,]', '', s)
    try:
        return int(clean_s)
    except:
        return None

def extract_fines(header):
    is_warning = bool(re.search(r'cảnh cáo', header, re.IGNORECASE))
    fine_min = fine_max = fine_min_org = fine_max_org = None

    org_match = re.search(r'từ\s+([0-9\.\,]+)\s+đồng\s+đến\s+([0-9\.\,]+)\s+đồng\s+đối với cá nhân(?:[^\,]*),\s+từ\s+([0-9\.\,]+)\s+đồng\s+đến\s+([0-9\.\,]+)\s+đồng\s+đối với tổ chức', header, re.IGNORECASE)
    if org_match:
        fine_min = parse_vnd(org_match.group(1))
        fine_max = parse_vnd(org_match.group(2))
        fine_min_org = parse_vnd(org_match.group(3))
        fine_max_org = parse_vnd(org_match.group(4))
        return is_warning, fine_min, fine_max, fine_min_org, fine_max_org

    simple_match = re.search(r'từ\s+([0-9\.\,]+)\s+đồng\s+đến\s+([0-9\.\,]+)\s+đồng', header, re.IGNORECASE)
    if simple_match:
        fine_min = parse_vnd(simple_match.group(1))
        fine_max = parse_vnd(simple_match.group(2))

    return is_warning, fine_min, fine_max, fine_min_org, fine_max_org

def extract_clause_scope(text, article_no):
    if article_no == 18:
        if re.search(r'người từ đủ 14 tuổi đến dưới 16 tuổi', text, re.IGNORECASE):
            return 'Người từ đủ 14 tuổi đến dưới 16 tuổi'
        if re.search(r'người từ đủ 16 tuổi đến dưới 18 tuổi điều khiển xe mô tô', text, re.IGNORECASE):
            return 'Người từ đủ 16 đến dưới 18 tuổi lái xe mô tô'
        if re.search(r'người từ đủ 16 tuổi đến dưới 18 tuổi điều khiển xe ô tô', text, re.IGNORECASE):
            return 'Người từ đủ 16 đến dưới 18 tuổi lái xe ô tô'
        if re.search(r'xe mô tô hai bánh có dung tích xi-lanh đến 125 cm3|đến 125 cm3', text, re.IGNORECASE):
            return 'Xe mô tô dung tích đến 125 cm³ (≤125cc, ≤11kW)'
        if re.search(r'dung tích xi-lanh trên 125 cm3|trên 125 cm3 trở lên', text, re.IGNORECASE):
            return 'Xe mô tô dung tích trên 125 cm³ (>125cc, >11kW, xe 3 bánh)'
        if re.search(r'người điều khiển xe ô tô', text, re.IGNORECASE):
            return 'Xe Ô tô'

    if article_no == 32:
        if re.search(r'chủ xe mô tô, xe gắn máy', text, re.IGNORECASE):
            return 'Chủ xe Mô tô, xe gắn máy'
        if re.search(r'chủ xe ô tô', text, re.IGNORECASE):
            return 'Chủ xe Ô tô'

    return ''

# Complete mapping for articles 6 to 40
article_config = {
  6: { 'vehicle': 'car', 'label': 'Xe Ô tô', 'cat': 'RULES' },
  7: { 'vehicle': 'motorcycle', 'label': 'Xe Mô tô / Xe máy', 'cat': 'RULES' },
  8: { 'vehicle': 'special_machinery', 'label': 'Xe máy chuyên dùng', 'cat': 'RULES' },
  9: { 'vehicle': 'bicycle', 'label': 'Xe đạp / Xe thô sơ', 'cat': 'RULES' },
  10: { 'vehicle': 'pedestrian', 'label': 'Người đi bộ', 'cat': 'RULES' },
  11: { 'vehicle': 'animal', 'label': 'Vật nuôi', 'cat': 'RULES' },
  12: { 'vehicle': 'all', 'label': 'Quy tắc khác / Vỉa hè', 'cat': 'RULES' },
  13: { 'vehicle': 'car', 'label': 'Thiết bị an toàn ô tô', 'cat': 'VEHICLE' },
  14: { 'vehicle': 'motorcycle', 'label': 'Thiết bị xe máy (Gương, còi, pô...)', 'cat': 'VEHICLE' },
  15: { 'vehicle': 'bicycle', 'label': 'Thiết bị xe thô sơ', 'cat': 'VEHICLE' },
  16: { 'vehicle': 'special_machinery', 'label': 'Thiết bị xe chuyên dùng', 'cat': 'VEHICLE' },
  17: { 'vehicle': 'car', 'label': 'Bảo vệ môi trường (Rơi vãi vật liệu, bùn đất)', 'cat': 'VEHICLE' },
  18: { 'vehicle': 'all', 'label': 'Điều kiện người lái (GPLX, giấy tờ, tuổi)', 'cat': 'DRIVER' },
  19: { 'vehicle': 'special_machinery', 'label': 'Điều kiện người lái xe chuyên dùng', 'cat': 'DRIVER' },
  20: { 'vehicle': 'car', 'label': 'Vận tải hành khách', 'cat': 'TRANSPORT' },
  21: { 'vehicle': 'car', 'label': 'Vận tải hàng hóa (Quá tải, quá khổ)', 'cat': 'TRANSPORT' },
  22: { 'vehicle': 'car', 'label': 'Hàng siêu trường, siêu trọng, nguy hiểm', 'cat': 'TRANSPORT' },
  23: { 'vehicle': 'car', 'label': 'Xe chở trẻ em mầm non, học sinh', 'cat': 'TRANSPORT' },
  24: { 'vehicle': 'car', 'label': 'Xe 4 bánh có gắn động cơ', 'cat': 'TRANSPORT' },
  25: { 'vehicle': 'car', 'label': 'Xe cứu hộ, xe vệ sinh môi trường, cứu thương', 'cat': 'TRANSPORT' },
  26: { 'vehicle': 'car', 'label': 'Đơn vị kinh doanh vận tải ô tô', 'cat': 'TRANSPORT' },
  27: { 'vehicle': 'car', 'label': 'Đơn vị có xe vận tải nội bộ', 'cat': 'TRANSPORT' },
  28: { 'vehicle': 'car', 'label': 'Xe 4 bánh kinh doanh vận tải', 'cat': 'TRANSPORT' },
  29: { 'vehicle': 'car', 'label': 'Xe cứu hộ giao thông đường bộ', 'cat': 'TRANSPORT' },
  30: { 'vehicle': 'car', 'label': 'Xe c���u thương', 'cat': 'TRANSPORT' },
  31: { 'vehicle': 'all', 'label': 'Sản xuất biển số, lắp ráp xe trái phép', 'cat': 'OTHER' },
  32: { 'vehicle': 'all', 'label': 'Chủ phương tiện (Cá nhân & Tổ chức)', 'cat': 'OWNER' },
  33: { 'vehicle': 'all', 'label': 'Hành khách đi xe vi phạm', 'cat': 'OTHER' },
  34: { 'vehicle': 'car', 'label': 'Quá tải trọng công trình, bánh xích', 'cat': 'TRANSPORT' },
  35: { 'vehicle': 'all', 'label': 'Đua xe trái phép, cổ vũ đua xe', 'cat': 'OTHER' },
  36: { 'vehicle': 'motorcycle', 'label': 'Xe máy chở hàng rơi vãi, cồng kềnh', 'cat': 'TRANSPORT' },
  37: { 'vehicle': 'all', 'label': 'Phương tiện cơ giới nước ngoài', 'cat': 'OTHER' },
  38: { 'vehicle': 'all', 'label': 'Phương tiện giao thông thông minh', 'cat': 'OTHER' },
  39: { 'vehicle': 'all', 'label': 'Đào tạo, sát hạch lái xe', 'cat': 'OTHER' },
  40: { 'vehicle': 'all', 'label': 'Hoạt động đăng kiểm xe cơ giới', 'cat': 'OTHER' }
}

article_regex = re.compile(r'Điều\s+(\d+)\.\s+([^\n\r]+)([\s\S]*?)(?=Điều\s+\d+\.|\Z)')
offenses = []

for art_match in article_regex.finditer(clean):
    art_no = int(art_match.group(1))
    title = art_match.group(2).strip()
    body = art_match.group(3).strip()

    if art_no not in article_config:
        continue

    cfg = article_config[art_no]

    clause_regex = re.compile(r'(?:^|\n)([0-9]+[a-z]?)\.\s+([\s\S]*?)(?=(?:\n[0-9]+[a-z]?\.|\Z))')
    for cl_match in clause_regex.finditer(body):
        cl_no = cl_match.group(1)
        cl_body = cl_match.group(2).strip()

        if re.search(r'Hình thức xử phạt bổ sung|bị trừ điểm giấy phép lái xe như sau|Ngoài việc bị áp dụng', cl_body[:100], re.IGNORECASE) and not re.search(r'thực hiện một trong các hành vi', cl_body):
            continue

        is_warning, fine_min, fine_max, fine_min_org, fine_max_org = extract_fines(cl_body[:300])
        scope = extract_clause_scope(cl_body[:300], art_no)

        point_regex = re.compile(r'(?:^|\n)([a-zđ])\)\s+([\s\S]*?)(?=(?:\n[a-zđ]\)|\Z))')
        has_points = False

        for pt_match in point_regex.finditer(cl_body):
            has_points = True
            pt_no = pt_match.group(1)
            pt_text = pt_match.group(2).strip()

            pts_match = re.search(r'\[(\d+)\s*điểm', pt_text, re.IGNORECASE)
            points = int(pts_match.group(1)) if pts_match else None
            has_detention = bool(re.search(r'\[PT\]|tạm giữ', pt_text, re.IGNORECASE))
            susp_match = re.search(r'\[Tước\s+([0-9\-]+)', pt_text, re.IGNORECASE)
            suspension = susp_match.group(1) if susp_match else None

            clean_desc = clean_leaked_phrases(pt_text)

            canonical_title = f"[{scope}] {clean_desc}" if scope else clean_desc

            specific_vehicle = cfg['vehicle']
            specific_label = cfg['label']
            if art_no == 18:
                if '≤125cc' in scope or '>125cc' in scope or 'mô tô' in scope:
                    specific_vehicle = 'motorcycle'
                    specific_label = scope
                elif 'Ô tô' in scope:
                    specific_vehicle = 'car'
                    specific_label = 'Xe Ô tô'
            elif art_no == 32:
                if 'mô tô' in scope:
                    specific_vehicle = 'motorcycle'
                    specific_label = 'Chủ xe Mô tô / Xe máy'
                elif 'ô tô' in scope:
                    specific_vehicle = 'car'
                    specific_label = 'Chủ xe Ô tô'

            off_code = f"{specific_vehicle.upper()}-{art_no:03d}-{cl_no}-{pt_no.upper()}"
            primary_ref = f"Điểm {pt_no} Khoản {cl_no} Điều {art_no}"

            offenses.append({
                'id': f"off_{art_no}_{cl_no}_{pt_no}",
                'code': off_code,
                'canonical': canonical_title,
                'fullDescription': clean_desc,
                'scope': scope,
                'primaryRef': primary_ref,
                'articleNo': art_no,
                'clauseNo': cl_no,
                'pointNo': pt_no,
                'doc': 'Nghị định số 168/2024/NĐ-CP (sửa đổi, bổ sung bởi NĐ 238/2026/NĐ-CP)',
                'vehicle': specific_vehicle,
                'vehicleLabel': specific_label,
                'category': cfg['cat'],
                'fineMin': fine_min,
                'fineMax': fine_max,
                'fineMinOrg': fine_min_org,
                'fineMaxOrg': fine_max_org,
                'isWarning': is_warning,
                'points': points,
                'detention': has_detention,
                'suspension': suspension,
                'searchText': f"{canonical_title} {clean_desc} {primary_ref} điều {art_no} khoản {cl_no} điểm {pt_no} {scope}".lower()
            })

        if not has_points and (fine_min or is_warning):
            clean_desc = clean_leaked_phrases(cl_body)

            canonical_title = f"[{scope}] {clean_desc}" if scope else clean_desc
            pts_match = re.search(r'\[(\d+)\s*điểm', cl_body, re.IGNORECASE)
            points = int(pts_match.group(1)) if pts_match else None
            has_detention = bool(re.search(r'\[PT\]|tạm giữ', cl_body, re.IGNORECASE))

            specific_vehicle = cfg['vehicle']
            specific_label = cfg['label']
            if art_no == 18:
                if 'mô tô' in scope:
                    specific_vehicle = 'motorcycle'
                    specific_label = scope
                elif 'ô tô' in scope:
                    specific_vehicle = 'car'
                    specific_label = 'Xe Ô tô'

            off_code = f"{specific_vehicle.upper()}-{art_no:03d}-{cl_no}"
            primary_ref = f"Khoản {cl_no} Điều {art_no}"

            offenses.append({
                'id': f"off_{art_no}_{cl_no}",
                'code': off_code,
                'canonical': canonical_title,
                'fullDescription': clean_desc,
                'scope': scope,
                'primaryRef': primary_ref,
                'articleNo': art_no,
                'clauseNo': cl_no,
                'pointNo': None,
                'doc': 'Nghị định số 168/2024/NĐ-CP (sửa đổi, bổ sung bởi NĐ 238/2026/NĐ-CP)',
                'vehicle': specific_vehicle,
                'vehicleLabel': specific_label,
                'category': cfg['cat'],
                'fineMin': fine_min,
                'fineMax': fine_max,
                'fineMinOrg': fine_min_org,
                'fineMaxOrg': fine_max_org,
                'isWarning': is_warning,
                'points': points,
                'detention': has_detention,
                'suspension': None,
                'searchText': f"{canonical_title} {clean_desc} {primary_ref} điều {art_no} khoản {cl_no} {scope}".lower()
            })

# Map remedial measures, suspensions, and aliases
for o in offenses:
    o['remedies'] = []
    art = o['articleNo']
    cl = str(o['clauseNo'])
    pt = str(o['pointNo']).lower() if o['pointNo'] else ''

    # Điều 6 (Ô tô)
    if art == 6:
        if cl == '12':
            o['suspension'] = '10 - 12 tháng'
            o['suspensionBasis'] = 'Điểm b Khoản 15 Điều 6'
            o['detention'] = True
        if cl == '11' and pt in ['a', 'b', 'c', 'd']:
            o['suspension'] = '22 - 24 tháng'
            o['suspensionBasis'] = 'Điểm c Khoản 15 Điều 6'
            o['detention'] = True
        if cl in ['13', '14']:
            o['suspension'] = '22 - 24 tháng'
            o['suspensionBasis'] = 'Điểm c Khoản 15 Điều 6'
            o['detention'] = True

    # Điều 7 (Mô tô)
    if art == 7:
        if cl == '9' and pt in ['a', 'b', 'h', 'i', 'k']:
            o['suspension'] = '10 - 12 tháng'
            o['suspensionBasis'] = 'Điểm b Khoản 12 Điều 7'
            o['detention'] = True
        if cl == '9' and pt in ['d', 'đ', 'e', 'g']:
            o['suspension'] = '22 - 24 tháng'
            o['suspensionBasis'] = 'Điểm c Khoản 12 Điều 7'
            o['detention'] = True
        if cl == '11':
            o['suspension'] = '22 - 24 tháng'
            o['suspensionBasis'] = 'Điểm c Khoản 12 Điều 7'
            o['detention'] = True

    # Điều 12
    if art == 12:
        if cl == '3': o['remedies'].append('Buộc phá dỡ các vật che khuất biển báo hiệu đường bộ, đèn tín hiệu giao thông (Điểm a Khoản 16 Điều 12)')
        if cl == '12': o['remedies'].append('Buộc khôi phục lại tình trạng ban đầu đã bị thay đổi do vi phạm hành chính gây ra (Điểm b Khoản 16 Điều 12)')
        if cl == '14':
            o['suspension'] = '22 - 24 tháng'
            o['suspensionBasis'] = 'Khoản 15 Điều 12'

    # Điều 13
    if art == 13:
        if cl in ['1', '2'] or (cl == '3' and pt in ['b', 'c']) or (cl == '4' and pt == 'b') or (cl == '5' and pt in ['b', 'd']) or (cl == '8' and pt == 'b'):
            o['remedies'].append('Buộc lắp đầy đủ thiết bị hoặc thay thế thiết bị đủ tiêu chuẩn an toàn kỹ thuật (Điểm a Khoản 11 Điều 13)')
        if cl == '3' and pt in ['a', 'd']:
            o['remedies'].append('Buộc lắp đầy đủ thiết bị hoặc tháo bỏ những thiết bị lắp thêm không đúng quy định (Điểm b Khoản 11 Điều 13)')
        if cl == '4' and pt == 'c':
            o['remedies'].append('Buộc khôi phục lại tình trạng ban đầu đã bị thay đổi do vi phạm hành chính gây ra (Điểm c Khoản 11 Điều 13)')
        if cl == '6' and pt == 'a':
            o['remedies'].append('Buộc nộp lại chứng nhận đăng ký xe, tem kiểm định bị tẩy xóa (Điểm d Khoản 11 Điều 13)')

    # Điều 14
    if art == 14:
        if cl == '1' or (cl == '2' and pt in ['d', 'đ']):
            o['remedies'].append('Buộc thay thế thiết bị đủ tiêu chuẩn an toàn kỹ thuật (gương, còi, đèn, giảm thanh...) hoặc khôi phục tính năng kỹ thuật của thiết bị theo quy định (Điểm a Khoản 6 Điều 14)')
        if cl == '2' and pt == 'b':
            o['remedies'].append('Buộc nộp lại chứng nhận đăng ký xe bị tẩy xóa (Điểm b Khoản 6 Điều 14)')

    # Điều 16
    if art == 16:
        if cl == '1' and pt in ['b', 'c', 'd']:
            o['remedies'].append('Buộc lắp đầy đủ thiết bị hoặc thay thế thiết bị đủ tiêu chuẩn, quy chuẩn an toàn kỹ thuật (Điểm a Khoản 5 Điều 16)')
        if cl == '2' and pt == 'đ':
            o['remedies'].append('Buộc nộp lại chứng nhận đăng ký xe, tem kiểm định bị tẩy xóa (Điểm b Khoản 5 Điều 16)')

    # Điều 17 (Bảo vệ môi trường, Rơi vãi vật liệu)
    if art == 17:
        if cl in ['1', '2', '3']:
            o['remedies'].append('Buộc thu dọn rác, chất phế thải, vật liệu, đất đá rơi vãi và khôi phục lại tình trạng ban đầu đã bị thay đổi (Khoản 4 Điều 17)')

    # Điều 18
    if art == 18:
        if (cl == '5' and pt == 'a') or (cl == '7' and pt == 'b') or (cl == '9' and pt == 'b'):
            if 'tẩy xóa' in o['canonical']:
                o['remedies'].append('Buộc nộp lại giấy phép lái xe bị tẩy xóa (Khoản 10 Điều 18)')

    # Điều 26
    if art == 26:
        if cl == '4' and pt == 'a': o['remedies'].append('Buộc cấp thẻ nhận dạng lái xe cho lái xe theo quy định (Điểm a Khoản 13 Điều 26)')
        if (cl == '4' and pt in ['b', 'c', 'd']) or (cl == '8' and pt == 'a'): o['remedies'].append('Buộc tổ chức tập huấn, hướng dẫn nghiệp vụ, quy trình hoặc tổ chức khám sức khỏe định kỳ cho lái xe và nhân viên phục vụ (Điểm b Khoản 13 Điều 26)')
        if (cl == '4' and pt in ['đ', 'e']) or (cl == '7' and pt in ['c', 'g', 'k']): o['remedies'].append('Buộc lắp đặt thiết bị giám sát hành trình, camera ghi nhận hình ảnh người lái xe, camera khoang chở khách, dây đai an toàn, ghế ngồi trẻ em theo đúng quy định (Điểm c Khoản 13 Điều 26)')
        if (cl == '7' and pt in ['a', 'h', 'l']) or cl == '11': o['remedies'].append('Buộc cung cấp, cập nhật, truyền dẫn, lưu trữ, quản lý dữ liệu từ thiết bị GSHT, camera người lái xe, camera khoang chở khách theo quy định (Điểm d Khoản 13 Điều 26)')
        if cl == '6' and pt in ['c', 'd']: o['remedies'].append('Buộc thực hiện đúng quy định về màu sơn, biển báo dấu hiệu nhận biết của xe (Điểm đ Khoản 13 Điều 26)')

    # Điều 31
    if art == 31:
        o['remedies'].append('Buộc nộp lại số lợi bất hợp pháp có được do thực hiện vi phạm hành chính (Khoản 4 Điều 31)')

    # Điều 32
    if art == 32:
        if (cl == '1' and pt == 'a') or (cl == '7' and pt == 'i'): o['remedies'].append('Buộc khôi phục lại nhãn hiệu, màu sơn ghi trong chứng nhận đăng ký xe theo quy định (Điểm a Khoản 19 Điều 32)')
        if cl == '2' and pt == 'a': o['remedies'].append('Buộc thay thế thiết bị đủ tiêu chuẩn an toàn kỹ thuật (lắp đúng loại kính an toàn) (Điểm b Khoản 19 Điều 32)')
        if cl == '4' or (cl == '9' and pt == 'e'): o['remedies'].append('Buộc thực hiện đúng quy định về biển số xe, kẻ hoặc dán chữ số biển số, thông tin trên thành xe, cửa xe (Điểm c Khoản 19 Điều 32)')
        if (cl == '11' and pt == 'd') or (cl == '14' and pt == 'h') or (cl == '16' and pt == 'c'): o['remedies'].append('Buộc khôi phục lại hình dáng, kích thước, tình trạng an toàn kỹ thuật ban đầu của xe và đăng kiểm lại trước khi đưa phương tiện tham gia giao thông (Điểm d Khoản 19 Điều 32)')
        if (cl == '7' and pt == 'e') or (cl == '11' and pt == 'b') or (cl == '13' and pt == 'a') or cl == '15' or (cl == '16' and pt == 'b'): o['remedies'].append('Buộc thực hiện điều chỉnh thùng xe đúng quy định, đăng kiểm lại và điều chỉnh lại khối lượng hàng hóa cho phép chuyên chở trước khi tham gia giao thông (Điểm đ Khoản 19 Điều 32)')
        if (cl == '3' and pt == 'b') or (cl == '7' and pt in ['b', 'c', 'h']) or (cl == '8' and pt in ['d', 'đ']) or (cl == '12' and pt == 'a'): o['remedies'].append('Buộc làm thủ tục đổi, thu hồi, cấp mới chứng nhận đăng ký xe, biển số xe, chứng nhận kiểm định theo quy định (Điểm g Khoản 19 Điều 32)')
        if (cl == '3' and pt == 'c') or (cl == '7' and pt == 'k'): o['remedies'].append('Buộc tháo dỡ thiết bị âm thanh, ánh sáng lắp đặt trên xe gây mất trật tự, an toàn giao thông đường bộ (Điểm h Khoản 19 Điều 32)')
        if (cl == '8' and pt == 'e') or (cl == '9' and pt == 'đ'): o['remedies'].append('Buộc nộp lại chứng nhận đăng ký xe, tem kiểm định bị tẩy xóa (Điểm i Khoản 19 Điều 32)')
        if cl == '7' and pt == 'l': o['remedies'].append('Buộc điều chỉnh lại chỉ số trên đồng hồ báo quãng đường (công-tơ-mét) của xe ô tô bị làm sai lệch (Điểm k Khoản 19 Điều 32)')
        if (cl == '7' and pt == 'o') or cl == '9a': o['remedies'].append('Buộc lắp đặt dụng cụ, thiết bị chuyên dùng cứu hộ, thiết bị giám sát hành trình, camera người lái xe theo đúng quy định (Điểm l Khoản 19 Điều 32)')

    # Điều 34
    if art == 34:
        o['remedies'].append('Buộc khôi phục lại tình trạng ban đầu đã bị thay đổi do vi phạm hành chính gây ra (Khoản 6 Điều 34)')

    # Điều 36
    if art == 36:
        if cl == '1' and pt == 'c': o['remedies'].append('Buộc thu dọn vật liệu, phế thải rơi vãi xuống đường (Khoản 2 Điều 36)')

    # Điều 37
    if art == 37:
        o['remedies'].append('Buộc tái xuất phương tiện khỏi Việt Nam (Khoản 5 Điều 37)')

    o['hasRemedy'] = len(o['remedies']) > 0

    # Aliases
    o['aliases'] = []
    if art == 17 and cl == '2' and pt == 'a':
        o['aliases'].extend(['rơi vãi', 'roi vai', 'chở hàng rơi vãi', 'rơi vãi vật liệu', 'không che bạt', 'khong che bat', 'để rơi vãi', 'chở vật liệu rơi vãi'])
    if art == 17 and cl == '2' and pt == 'b':
        o['aliases'].extend(['lôi kéo bùn đất', 'loi keo bun dat', 'bùn đất ra đường', 'làm bẩn đường'])
    if art == 17 and cl == '3':
        o['aliases'].extend(['đổ rác ra đường', 'đổ phế thải ra đường', 'do rac', 'do phe thai'])
    if art == 36 and cl == '1' and pt == 'c':
        o['aliases'].extend(['xe máy chở hàng rơi vãi', 'mô tô chở hàng rơi vãi', 'rơi vãi', 'roi vai'])
    if art == 20 and cl == '3' and pt == 'đ':
        o['aliases'].extend(['để rơi hành lý', 'rơi hàng hóa', 'rơi vãi'])
    if art == 7 and cl == '2' and pt == 'h':
        o['aliases'].extend(['không đội mũ', 'không đội mũ bảo hiểm', 'mũ bảo hiểm', 'mu bao hiem', 'không nón', 'không nón bảo hiểm', 'nón bảo hiểm', 'ko mu', 'ko non', 'k mu', 'k non', 'mbh', 'cài quai', 'không cài quai', 'cai quai'])
    if art == 7 and cl == '2' and pt == 'i':
        o['aliases'].extend(['chở người không đội mũ', 'chở người không nón', 'người ngồi sau không đội mũ', 'người ngồi sau không nón', 'cho nguoi khong doi mu'])
        o['exceptions'] = ['Chở người bệnh đi cấp cứu', 'Trẻ em dưới 06 tuổi', 'Áp giải người có hành vi vi phạm pháp luật']
    if art == 7 and cl == '2' and pt == 'g':
        o['aliases'].extend(['chở 2', 'cho 2', 'chở 2 người', 'cho 2 nguoi', 'điểm g khoản 2 điều 7', 'diem g khoan 2 dieu 7', 'g.2.7'])
        o['exceptions'] = ['Chở người bệnh đi cấp cứu', 'Trẻ em dưới 12 tuổi', 'Người già yếu hoặc người khuyết tật', 'Áp giải người có hành vi vi phạm pháp luật']
    if art == 7 and cl == '3' and pt == 'b':
        o['aliases'].extend(['kẹp 3', 'kep 3', 'chở 3', 'cho 3', 'chở 3 người', 'kẹp ba', 'điểm b khoản 3 điều 7'])
    if art == 7 and cl == '8' and pt == 'b':
        o['aliases'].extend(['cồn 0.32 moto', 'cồn 0.32', 'thổi cồn xe máy', 'nồng độ cồn 0.3', 'cồn xe máy', 'con xe may', 'nồng độ cồn'])
    if art == 6 and cl == '5' and pt == 'đ':
        o['aliases'].extend(['oto 76/60', 'oto 76 60', 'quá tốc độ ô tô 10 20', 'quá tốc độ'])
    if art == 14 and cl == '1' and pt == 'a':
        o['aliases'].extend(['không gương', 'khong guong', 'không gương chiếu hậu', 'gương bên trái', 'gương xe máy', 'k gương', 'ko guong'])
    if art == 18 and cl == '7' and pt == 'b':
        o['aliases'].extend(['xe máy 150 không bằng', '150cc k gplx', '150cc không bằng', 'sh150 không bằng'])
    if art == 18 and cl == '5' and pt == 'a':
        o['aliases'].extend(['110cc không bằng', 'không bằng xe 110', '125cc không bằng', 'không bằng 125cc'])
    if art == 32 and cl == '10':
        o['aliases'].extend(['giao xe cho người không bằng', 'giao xe cho nguoi khong bang', 'chủ xe giao xe'])

    # Overload
    if art == 21 and cl == '2' and pt == 'a': o['aliases'].extend(['quá tải', 'qua tai', 'quá tải 10 30', 'quá tải 10% đến 30%', 'quá tải 20%'])
    if art == 21 and cl == '5' and pt == 'a': o['aliases'].extend(['quá tải', 'qua tai', 'quá tải 30 50', 'quá tải 30% đến 50%', 'quá tải 40%'])
    if art == 21 and cl == '6' and pt == 'a': o['aliases'].extend(['quá tải', 'qua tai', 'quá tải 50 100', 'quá tải 50% đến 100%', 'quá tải 70%'])
    if art == 21 and cl == '7': o['aliases'].extend(['quá tải', 'qua tai', 'quá tải 100 150', 'quá tải 100% đến 150%', 'quá tải 120%'])
    if art == 21 and cl == '8' and pt == 'a': o['aliases'].extend(['quá tải', 'qua tai', 'quá tải trên 150', 'quá tải trên 150%', 'quá tải 200%'])

with open('/Users/hatrungnhu/Downloads/tra_loi_gt_pro/full_legal_database.json', 'w', encoding='utf-8') as f:
    json.dump(offenses, f, ensure_ascii=False, indent=2)

print(f"Successfully generated {len(offenses)} clean offenses from all articles!")
