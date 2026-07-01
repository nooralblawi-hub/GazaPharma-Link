-- ====================================================================
-- GazaPharma-Link: Complete Database Schema (Updated for SCRUM-21)
-- ====================================================================

-- =======================================================
-- 1. إنشاء جدول الصيدليات (Pharmacies)
-- =======================================================
CREATE TABLE pharmacies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    phone VARCHAR(50),
    working_hours VARCHAR(100) DEFAULT '8:00 AM - 11:00 PM',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =======================================================
-- 2. إنشاء جدول الأدوية (Medicines)
-- =======================================================
CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commercial_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =======================================================
-- 3. إنشاء جدول المخزون الموحد (Pharmacy Inventory)
-- =======================================================
CREATE TABLE pharmacy_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id INT NOT NULL,
    medicine_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT DEFAULT 0,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'متوفر',
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- وعقد العلاقات والقيود (Constraints)
    CONSTRAINT fk_inventory_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inventory_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_pharmacy_medicine_batch UNIQUE KEY (pharmacy_id, medicine_id, batch_number)
);

-- فهارس تحسين الأداء والبحث (Optimization Indexes)
CREATE INDEX idx_inventory_pharmacy ON pharmacy_inventory(pharmacy_id);
CREATE INDEX idx_inventory_medicine ON pharmacy_inventory(medicine_id);
CREATE INDEX idx_inventory_status ON pharmacy_inventory(status);

-- =======================================================
-- 4. إنشاء جدول الطلبات المفتوحة للأدوية المفقودة (Open Requests)
-- =======================================================
CREATE TABLE open_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    required_medicine VARCHAR(255) NOT NULL,
    details TEXT,
    status VARCHAR(50) DEFAULT 'مفتوح',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =======================================================
-- 5. إنشاء جدول ردود الصيدليات (Request Replies)
-- =======================================================
CREATE TABLE request_replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    pharmacy_id INT NOT NULL,
    notes TEXT,
    replied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_reply_request FOREIGN KEY (request_id) REFERENCES open_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_reply_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE
);

-- =======================================================
-- 6. برمجة منطق تمييز البيانات القديمة (Staleness Logic Views)
-- =======================================================

-- أولاً: واجهة عرض الأدوية المنتهية أو الحرجة (أقل من 30 يوماً على انتهائها)
CREATE OR REPLACE VIEW view_expired_or_stale_medicine AS
SELECT 
    i.id AS inventory_id,
    p.name AS pharmacy_name,
    m.commercial_name AS medicine_name,
    i.quantity,
    i.batch_number,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_until_expiry,
    CASE 
        WHEN i.expiry_date <= CURDATE() THEN 'EXPIRED'
        WHEN DATEDIFF(i.expiry_date, CURDATE()) <= 30 THEN 'CRITICAL_STALE'
        ELSE 'OK'
    END AS staleness_status
FROM pharmacy_inventory i
JOIN pharmacies p ON i.pharmacy_id = p.id
JOIN medicines m ON i.medicine_id = m.id;

-- ثانياً: واجهة عرض سجلات المخزون الراكدة (التي لم تُحدّث منذ أكثر من 30 يوماً)
CREATE OR REPLACE VIEW view_outdated_inventory_records AS
SELECT 
    i.id AS inventory_id,
    p.name AS pharmacy_name,
    m.commercial_name AS medicine_name,
    i.quantity,
    i.last_updated_at,
    DATEDIFF(CURDATE(), i.last_updated_at) AS days_since_last_update
FROM pharmacy_inventory i
JOIN pharmacies p ON i.pharmacy_id = p.id
JOIN medicines m ON i.medicine_id = m.id
WHERE DATEDIFF(CURDATE(), i.last_updated_at) > 30;


-- =======================================================
-- 7. إدخال البيانات التجريبية (6 صيدليات تغطي القطاع)
-- =======================================================
INSERT INTO pharmacies (name, address, latitude, longitude, phone, working_hours) VALUES
('صيدلية الشفاء المركزية', 'غزة - شارع عز الدين القسام، بجوار مجمع الشفاء', 31.524700, 34.446300, '08-2822600', '24 ساعة'),
('صيدلية الرمال الحديثة', 'غزة - حي الرمال، شارع عمر المختار، صيدلية الرمال الحديثة', 31.519400, 34.449200, '08-2865500', '8:00 AM - 12:00 PM'),
('صيدلية جباليا المركزية', 'شمال غزة - معسكر جباليا، منطقة الترانس', 31.552100, 34.494400, '059-9988771', '8:00 AM - 10:30 PM'),
('صيدلية العودة', 'شمال غزة - بيت لاهيا، مشروع بيت لاهيا', 31.565000, 34.486000, '08-2451122', '7:30 AM - 10:30 PM'),
('صيدلية الأمل الحديثة', 'خانيونس - وسط البلد، مقابل القلعة الأثرية', 31.345800, 34.301500, '08-2063300', '24 ساعة'),
('صيدلية رفح المركزية', 'رفح - وسط البلد، شارع البحر العام', 31.284200, 34.254100, '08-2134455', '8:00 AM - 11:00 PM');

-- =======================================================
-- 8. إدخال الأدوية (10 أدوية متنوعة)
-- =======================================================
INSERT INTO medicines (commercial_name, scientific_name, category, description) VALUES
('Acamol', 'Paracetamol', 'مسكنات', '500mg - Analgesic & Antipyretic (60 Tablets)'),
('Panadol Advance', 'Paracetamol', 'مسكنات', '500mg - Fast Pain Relief (24 Tablets)'),
('Paramol', 'Paracetamol', 'مسكنات', '500mg - Local Generic Pain Reliever'),
('Glucophage', 'Metformin Hydrochloride', 'أدوية السكري', '850mg - Type 2 Diabetes Management'),
('Metformin Megalabs', 'Metformin Hydrochloride', 'أدوية السكري', '1000mg - Blood Sugar Control'),
('Amoxicare', 'Amoxicillin', 'مضادات حيوية', '500mg - Broad-spectrum Antibiotic'),
('Augmentin', 'Amoxicillin + Clavulanic Acid', 'مضادات حيوية', '1g - Strong Antibacterial Tablet'),
('Exforge', 'Amlodipine + Valsartan', 'أدوية الضغط', '5mg/160mg - Hypertension Control'),
('Concor', 'Bisoprolol Fumarate', 'أدوية الضغط', '5mg - Beta-Blocker for Heart & Blood Pressure'),
('Ventolin Inhaler', 'Salbutamol', 'أجهزة تنفسية', '100mcg CFC-Free Inhaler (200 Puffs)');

-- =======================================================
-- 9. ربط وتوزيع المخزون على الصيدليات (مع إضافة التواريخ ورقم التشغيلة)
-- =======================================================
INSERT INTO pharmacy_inventory (pharmacy_id, medicine_id, price, quantity, batch_number, expiry_date, status) VALUES
-- صيدلية الشفاء المركزية (1)
(1, 1, 12.50, 0, 'B-ACA01', '2026-05-01', 'غير متوفر'), 
(1, 2, 16.00, 150, 'B-PAN02', '2026-07-20', 'متوفر'), 
(1, 4, 18.50, 40, 'B-GLU04', '2027-01-15', 'متوفر'), 
(1, 7, 45.00, 2, 'B-AUG07', '2026-07-10', 'مخزون منخفض'), 
(1, 10, 35.00, 80, 'B-VEN10', '2027-05-11', 'متوفر'),

-- صيدلية الرمال الحديثة (2)
(2, 1, 12.00, 90, 'B-ACA02', '2027-02-01', 'متوفر'), 
(2, 4, 18.00, 0, 'B-GLU05', '2026-04-12', 'غير متوفر'), 
(2, 5, 22.00, 30, 'B-MET05', '2027-08-19', 'متوفر'), 
(2, 9, 28.00, 15, 'B-CON09', '2026-07-14', 'متوفر'),

-- صيدلية جباليا المركزية (3)
(3, 1, 13.00, 200, 'B-ACA03', '2027-03-01', 'متوفر'), 
(3, 6, 24.00, 0, 'B-AMO06', '2026-03-25', 'غير متوفر'), 
(3, 7, 48.00, 0, 'B-AUG08', '2026-06-01', 'غير متوفر'), 
(3, 10, 38.00, 4, 'B-VEN11', '2026-07-15', 'مخزون منخفض'),

-- صيدلية العودة (4)
(4, 2, 16.50, 50, 'B-PAN03', '2027-01-01', 'متوفر'), 
(4, 4, 19.00, 12, 'B-GLU06', '2027-04-01', 'متوفر'), 
(4, 6, 25.00, 8, 'B-AMO07', '2026-07-08', 'مخزون منخفض'),

-- صيدلية الأمل الحديثة (5)
(5, 1, 12.50, 110, 'B-ACA04', '2027-09-12', 'متوفر'), 
(5, 4, 18.50, 95, 'B-GLU07', '2027-11-20', 'متوفر'), 
(5, 8, 85.00, 0, 'B-EXF08', '2026-05-30', 'غير متوفر'), 
(5, 9, 27.50, 40, 'B-CON10', '2027-01-05', 'متوفر'),

-- صيدلية رفح المركزية (6)
(6, 2, 16.00, 75, 'B-PAN04', '2027-06-15', 'متوفر'), 
(6, 7, 46.00, 20, 'B-AUG09', '2026-12-25', 'متوفر'), 
(6, 8, 82.00, 18, 'B-EXF09', '2027-02-10', 'متوفر'), 
(6, 10, 35.00, 0, 'B-VEN12', '2026-05-15', 'غير متوفر');

-- =======================================================
-- 10. إدخال طلبات الأدوية المفقودة وردود الصيدليات
-- =======================================================
INSERT INTO open_requests (required_medicine, details, status) VALUES
('Clexane 4000', 'مطلوب حقن كليكسان لامرأة حامل بشكل عاجل، مفقود من الصيدليات القريبة', 'تم الرد'),
('Euthyrox 50mg', 'دواء الغدة الدرقية يثيروكس 50 ميكروغرام، غير متوفر في الشمال منذ أسابيع', 'مفتوح'),
('Insulin Lantus', 'مطلوب قلم أنسولين لانتوس لشيخ مسن في خانيونس', 'مفتوح');

INSERT INTO request_replies (request_id, pharmacy_id, notes) VALUES
(1, 6, 'متوفر لدينا في صيدلية رفح المركزية كمية محدودة (3 علب فقط)، يرجى الحضور لحجزها.');
