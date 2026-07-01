-- ====================================================================
-- GazaPharma-Link: Complete Database Schema (Updated for SCRUM-21)
-- ====================================================================

-- 1. إنشاء جدول الصيدليات
DROP TABLE IF EXISTS pharmacies;
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

-- 2. إنشاء جدول الأدوية العامة
DROP TABLE IF EXISTS medicines;
CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commercial_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. جدول المخزون (تم تعديله بالكامل ليتوافق مع واجهة روان InventoryManagement)
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id INT NOT NULL,
    medicine_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'متوفر',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- العلاقات والربط
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE,
    
    -- منع تكرار نفس الدواء لنفس الصيدلية
    UNIQUE KEY uq_pharmacy_medicine (pharmacy_id, medicine_id)
);

-- 4. إنشاء جدول الطلبات المفتوحة للأدوية المفقودة
DROP TABLE IF EXISTS open_requests;
CREATE TABLE open_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    required_medicine VARCHAR(255) NOT NULL,
    details TEXT,
    status VARCHAR(50) DEFAULT 'مفتوح',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. إنشاء جدول ردود الصيدليات على الطلبات المفقودة
DROP TABLE IF EXISTS request_replies;
CREATE TABLE request_replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    pharmacy_id INT NOT NULL,
    notes TEXT,
    replied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES open_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE
);

-- ====================================================================
-- إدخال البيانات التجريبية المتوافقة مع النظام الجديد
-- ====================================================================

-- إدخال الصيدليات
INSERT INTO pharmacies (name, address, latitude, longitude, phone, working_hours) VALUES
('صيدلية الشفاء المركزية', 'غزة - شارع عز الدين القسام، بجوار مجمع الشفاء', 34.446300, 31.524700, '2822600-08', '24 ساعة'),
('صيدلية الرمال الحديثة', 'غزة - حي الرمال، شارع عمر المختار', 34.449200, 31.519400, '2865500-08', '8:00 AM - 12:00 AM'),
('صيدلية جباليا المركزية', 'شمال غزة - معسكر جباليا، منطقة الترنس', 34.494400, 31.552100, '9988771-059', '8:00 AM - 11:00 PM'),
('صيدلية العودة', 'شمال غزة - مشروع بيت لاهيا', 34.486000, 31.565000, '2451122-08', '8:00 AM - 10:30 PM'),
('صيدلية الأمل الحديثة', 'خانيونس - وسط البلد، مقابل القلعة الأثرية', 34.301500, 31.345800, '2063300-08', '24 ساعة'),
('صيدلية رفح المركزية', 'رفح - وسط البلد، شارع البحر العام', 34.254100, 31.284200, '2134455-08', '8:00 AM - 11:00 PM');

-- إدخال الأدوية
INSERT INTO medicines (commercial_name, scientific_name, category, description) VALUES
('Acamol', 'Paracetamol', 'مسكنات', 'Analgesic & Antipyretic (60 Tablets)'),
('Panadol Advance', 'Paracetamol', 'مسكنات', 'Fast Pain Relief (24 Tablets)'),
('Paramol', 'Paracetamol', 'مسكنات', 'Local Generic Pain Reliever'),
('Glucophage', 'Metformin Hydrochloride', 'أدوية السكري', 'Type 2 Diabetes Management'),
('Metformin Megalabs', 'Metformin Hydrochloride', 'أدوية السكري', 'Blood Sugar Control'),
('Amoxicare', 'Amoxicillin', 'مضادات حيوية', 'Broad-Spectrum Antibiotic'),
('Augmentin', 'Amoxicillin + Clavulanic Acid', 'مضادات حيوية', 'Strong Antibacterial Tablet'),
('Exforge', 'Amlodipine + Valsartan', 'أدوية الضغط', 'Hypertension Control'),
('Concor', 'Bisoprolol Fumarate', 'أدوية الضغط', 'Beta-Blocker for Heart & Blood Pressure'),
('Ventolin Inhaler', 'Salbutamol', 'أجهزة تنفسية', 'CFC-Free Inhaler (200 Puffs)');

-- ربط وتوزيع المخزون بناءً على حقول السعر والكمية والحالة الجديدة
INSERT INTO inventory (pharmacy_id, medicine_id, price, quantity, status) VALUES
(1, 1, 12.50, 0, 'غير متوفر'),
(1, 2, 16.00, 150, 'متوفر'),
(1, 4, 18.50, 40, 'متوفر'),
(1, 7, 45.00, 2, 'مخزون منخفض'),
(1, 10, 35.00, 80, 'متوفر'),
(2, 1, 12.00, 90, 'متوفر'),
(2, 4, 18.00, 0, 'غير متوفر'),
(2, 5, 22.00, 30, 'متوفر'),
(2, 9, 28.00, 15, 'متوفر'),
(3, 1, 13.00, 200, 'متوفر'),
(3, 6, 24.00, 0, 'غير متوفر'),
(3, 7, 48.00, 0, 'غير متوفر'),
(3, 10, 38.00, 4, 'مخزون منخفض'),
(4, 2, 16.50, 50, 'متوفر'),
(4, 4, 19.00, 12, 'متوفر'),
(4, 6, 25.00, 8, 'مخزون منخفض'),
(5, 1, 12.50, 110, 'متوفر'),
(5, 4, 18.50, 95, 'متوفر'),
(5, 8, 85.00, 0, 'غير متوفر'),
(5, 9, 27.50, 40, 'متوفر'),
(6, 2, 16.00, 75, 'متوفر'),
(6, 7, 46.00, 20, 'متوفر'),
(6, 8, 82.00, 18, 'متوفر'),
(6, 10, 35.00, 0, 'غير متوفر');

-- إدخال طلبات الأدوية المفقودة ورّدود الصيدليات
INSERT INTO open_requests (required_medicine, details, status) VALUES
('Clexane 4000', 'مطلوب حقن كليكسان لامرأة حامل بشكل عاجل، مفقود من الصيدليات القريبة', 'تم الرد'),
('Euthyrox 50mg', 'دواء الغدة الدرقية يوتيروكس 50 ميكروغرام، غير متوفر في الشمال منذ أسابيع', 'مفتوح'),
('Insulin Lantus', 'مطلوب قلم أنسولين لانتوس لشيخ مسن في خانيونس', 'مفتوح');
INSERT INTO request_replies (request_id, pharmacy_id, notes) VALUES
(1, 6, 'متوفر لدينا في صيدلية رفح المركزية كمية محدودة (3 علب فقط)، يرجى الحضور لحجزها');


-- =======================================================
-- 3. إنشاء جدول المخزون (Inventory) وعقد العلاقات
-- =======================================================
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id INT NOT NULL,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- عقد العلاقات (Foreign Keys)
    CONSTRAINT fk_inventory_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
);


-- =======================================================
-- 4. برمجة منطق تمييز البيانات القديمة (Staleness Logic)   
-- =======================================================

-- أولاً: عرض الأدوية المنتهية الصلاحية أو القريبة من الانتهاء (أقل من 30 يوماً)
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
FROM inventory i
JOIN pharmacies p ON i.pharmacy_id = p.id
JOIN medicines m ON i.medicine_id = m.id;

-- ثانياً: عرض سجلات المخزون التي لم تُحدّث كمياتها منذ أكثر من 30 يوماً (بيانات قديمة تحتاج مراجعة)
CREATE OR REPLACE VIEW view_outdated_inventory_records AS
SELECT 
    i.id AS inventory_id,
    p.name AS pharmacy_name,
    m.commercial_name AS medicine_name,
    i.quantity,
    i.last_updated_at,
    DATEDIFF(CURDATE(), i.last_updated_at) AS days_since_last_update
FROM inventory i
JOIN pharmacies p ON i.pharmacy_id = p.id
JOIN medicines m ON i.medicine_id = m.id
WHERE DATEDIFF(CURDATE(), i.last_updated_at) > 30;
