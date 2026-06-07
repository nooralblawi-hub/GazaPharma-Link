-- 1. إنشاء جدول الصيدليات
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

-- 2. إنشاء جدول الأدوية
CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commercial_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. إنشاء جدول المخزون (الربط والسعر والحالة)
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_id INT NOT NULL,
    medicine_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'متوفر',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
);

-- 4. إنشاء جدول الطلبات المفتوحة للأدوية المفقودة
CREATE TABLE open_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    required_medicine VARCHAR(255) NOT NULL,
    details TEXT,
    status VARCHAR(50) DEFAULT 'مفتوح',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. إنشاء جدول ردود الصيدليات على الطلبات المفقودة
CREATE TABLE request_replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    pharmacy_id INT NOT NULL,
    notes TEXT,
    replied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES open_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id) ON DELETE CASCADE
);

-- ==========================================
-- إدخال البيانات التجريبية الموسّعة
-- ==========================================

-- إدخال الصيدليات (6 صيدليات تغطي القطاع)
INSERT INTO pharmacies (name, address, latitude, longitude, phone, working_hours) VALUES
('صيدلية الشفاء المركزية', 'غزة - شارع عز الدين القسام، بجوار مجمع الشفاء', 31.524700, 34.446300, '08-2822600', '24 ساعة'),
('صيدلية الرمال الحديثة', 'غزة - حي الرمال، شارع عمر المختار', 31.519400, 34.449200, '08-2865500', '8:00 AM - 12:00 AM'),
('صيدلية جباليا المركزية', 'شمال غزة - معسكر جباليا، منطقة الترانس', 31.552100, 34.494400, '059-9988771', '8:00 AM - 11:00 PM'),
('صيدلية العودة', 'شمال غزة - بيت لاهيا، مشروع بيت لاهيا', 31.565000, 34.486000, '08-2451122', '7:30 AM - 10:30 PM'),
('صيدلية الأمل الحديثة', 'خانيونس - وسط البلد، مقابل القلعة الأثرية', 31.345800, 34.301500, '08-2063300', '24 ساعة'),
('صيدلية رفح المركزية', 'رفح - وسط البلد، شارع البحر العام', 31.284200, 34.254100, '08-2134455', '8:00 AM - 11:00 PM');

-- إدخال الأدوية (10 أدوية متنوعة تدعم البدائل)
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

-- ربط وتوزيع المخزون على الصيدليات
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

-- إدخال طلبات الأدوية المفقودة وردود الصيدليات
INSERT INTO open_requests (required_medicine, details, status) VALUES
('Clexane 4000', 'مطلوب حُقن كليكسان لامرأة حامل بشكل عاجل، مفقود من الصيدليات القريبة', 'تم الرد'),
('Euthyrox 50mg', 'دواء الغدة الدرقية يوثايروكس 50 ميكروغرام، غير متوفر في الشمال منذ أسابيع', 'مفتوح'),
('Insulin Lantus', 'مطلوب قلم أنسولين لانتوس لشيخ مسن في خانيونس', 'مفتوح');

INSERT INTO request_replies (request_id, pharmacy_id, notes) VALUES
(1, 6, 'متوفر لدينا في صيدلية رفح المركزية كمية محدودة (3 علب فقط)، يرجى الحضور لحجزها.');