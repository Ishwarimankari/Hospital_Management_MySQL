-- =========================================
-- DATABASE SETUP
-- =========================================

-- Delete database if already exists (clean start)
DROP DATABASE hospital_db;

-- Create new database
CREATE DATABASE hospital_db;

-- Select database
USE hospital_db;


-- =========================================
-- TABLE: PATIENTS
-- =========================================

-- Stores patient details
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,  -- unique patient ID
    name VARCHAR(50) NOT NULL,                  -- patient name
    age INT,                                    -- age of patient
    gender VARCHAR(10),                         -- gender
    phone VARCHAR(15) UNIQUE                    -- unique phone number
);


-- =========================================
-- TABLE: DOCTORS
-- =========================================

-- Stores doctor details
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,   -- unique doctor ID
    name VARCHAR(50) NOT NULL,                  -- doctor name
    specialization VARCHAR(50),                 -- field of expertise
    fees INT CHECK (fees > 0)                   -- consultation fees (must be > 0)
);


-- =========================================
-- TABLE: APPOINTMENTS
-- =========================================

-- Drop table if exists to avoid duplication error
DROP TABLE IF EXISTS Appointments;

-- Stores appointment bookings
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,  -- unique appointment ID
    patient_id INT NOT NULL,                        -- reference to patient
    doctor_id INT NOT NULL,                         -- reference to doctor
    appointment_date DATE,                          -- appointment date
    appointment_time TIME,                          -- appointment time
    status ENUM('Booked', 'Cancelled', 'Completed'), -- appointment status

    -- Foreign key constraints
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),

    -- Prevent double booking for same doctor at same time
    UNIQUE (doctor_id, appointment_date, appointment_time)
);


-- =========================================
-- TABLE: MEDICAL RECORDS
-- =========================================

DROP TABLE IF EXISTS Medical_Records;

-- Stores diagnosis and treatment details
CREATE TABLE Medical_Records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,   -- unique record ID
    patient_id INT NOT NULL,                    -- reference to patient
    diagnosis VARCHAR(100),                     -- diagnosis details
    treatment VARCHAR(100),                     -- treatment details
    record_date DATE,                           -- record date

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);


-- =========================================
-- TABLE: BILLS
-- =========================================

DROP TABLE IF EXISTS Bills;

-- Stores billing details
CREATE TABLE Bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,     -- unique bill ID
    patient_id INT NOT NULL,                    -- reference to patient
    doctor_id INT NOT NULL,                     -- reference to doctor
    amount INT,                                 -- bill amount
    bill_date DATE,                             -- billing date

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);


-- Show all tables in database
SHOW TABLES;


-- =========================================
-- INSERT DATA: DOCTORS
-- =========================================

-- Insert sample doctors
INSERT INTO Doctors (name, specialization, fees) VALUES
('Dr. Sharma', 'Cardiologist', 500),
('Dr. Mehta', 'Dermatologist', 400),
('Dr. Rao', 'Neurologist', 700),
('Dr. Singh', 'Orthopedic', 600),
('Dr. Khan', 'Pediatrician', 450);


-- =========================================
-- INSERT DATA: PATIENTS
-- =========================================

-- Insert fixed patient records
INSERT INTO Patients (name, age, gender, phone) VALUES
('Amit', 25, 'Male', '9000000001'),
('Sneha', 30, 'Female', '9000000002'),
('Rahul', 28, 'Male', '9000000003'),
('Priya', 26, 'Female', '9000000004'),
('Karan', 35, 'Male', '9000000005');


-- =========================================
-- GENERATE RANDOM PATIENT DATA
-- =========================================

-- Automatically generate ~100 random patients
INSERT INTO Patients (name, age, gender, phone)
SELECT 
    CONCAT('Patient_', FLOOR(RAND()*1000)),        -- random name
    FLOOR(18 + RAND()*50),                         -- age between 18–68
    IF(RAND() > 0.5, 'Male', 'Female'),            -- random gender
    CONCAT('9', FLOOR(100000000 + RAND()*899999999)) -- random phone number
FROM information_schema.tables
LIMIT 100;

-- =========================================
-- VERIFY DATA
-- =========================================

-- Count total patients
SELECT COUNT(*) FROM Patients;

INSERT IGNORE INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, status)
SELECT 
    FLOOR(1 + RAND()*105),
    FLOOR(1 + RAND()*5),
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND()*10) DAY),
    MAKETIME(FLOOR(9 + RAND()*8), 0, 0),
    'Booked'
FROM information_schema.tables
LIMIT 150;

-- Check data exists in all tables
SELECT COUNT(*) as patients FROM Patients;
SELECT COUNT(*) as dr FROM Doctors;
SELECT COUNT(*) as appointments FROM Appointments;

-- Show all appointment details (MAIN QUERY)
-- Proper chronological order
SELECT 
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date, a.appointment_time;

-- Show today's or future appointments
SELECT 
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
WHERE a.appointment_date >= CURDATE();

-- Count appointments per doctor
SELECT 
    d.name AS doctor_name,
    COUNT(*) AS total_appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name;

-- Sort doctors by workload
SELECT 
    d.name,
    COUNT(*) AS total
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY total DESC;

-- Find busiest doctor
SELECT 
    d.name,
    COUNT(*) AS total
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id
ORDER BY total DESC
LIMIT 3;

-- Proper chronological order
SELECT 
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date, a.appointment_time;

-- Create a virtual table (VIEW)
DROP VIEW IF EXISTS hospital_dashboard;

CREATE VIEW hospital_dashboard AS
SELECT 
    a.appointment_id,
    a.doctor_id,   -- 🔥 important
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

SELECT * FROM hospital_dashboard;
-- Show only upcoming appointments from VIEW
SELECT * 
FROM hospital_dashboard
WHERE appointment_date >= CURDATE();

-- Procedure to get appointments by doctor
DELIMITER $$

CREATE PROCEDURE GetDoctorAppointments(IN doc_id INT)
BEGIN
    SELECT * 
    FROM hospital_dashboard
    WHERE doctor_id = doc_id;
END $$

DELIMITER ;

CALL GetDoctorAppointments(1);

-- Improve search speed
CREATE INDEX idx_patient ON Appointments(patient_id);
CREATE INDEX idx_doctor ON Appointments(doctor_id);

-- =========================================
-- BASIC RETRIEVAL
-- =========================================

-- 1. Show all patients
SELECT * FROM Patients;

-- 2. Show only name and gender
SELECT name, gender FROM Patients;

-- 3. Filter female patients
SELECT * FROM Patients
WHERE gender = 'Female';


-- =========================================
-- APPOINTMENTS QUERIES
-- =========================================

-- 4. Appointments of a specific patient
SELECT * FROM Appointments
WHERE patient_id = 1;

-- 5. Appointments of a specific doctor
SELECT * FROM Appointments
WHERE doctor_id = 1
order by appointment_id;

-- 6. Latest appointments first
SELECT * FROM Appointments
ORDER BY appointment_date DESC, appointment_time DESC;


-- =========================================
-- AGGREGATION
-- =========================================

-- 7. Count total patients
SELECT COUNT(*) FROM Patients;

-- 8. Count patients by gender
SELECT gender, COUNT(*) 
FROM Patients
GROUP BY gender;


-- =========================================
-- JOIN (MOST IMPORTANT)
-- =========================================

-- 9. Full appointment details
SELECT 
    p.name AS patient,
    d.name AS doctor,
    a.appointment_date,
    a.appointment_time
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;


-- =========================================
-- ANALYTICS
-- =========================================

-- 10. Appointments per doctor
SELECT 
    d.name,
    COUNT(*) AS total_appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name;

-- 11. Top 3 busiest doctors
SELECT 
    d.name,
    COUNT(*) AS total
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id
ORDER BY total DESC
LIMIT 1;


-- =========================================
-- VIEW (DASHBOARD)
-- =========================================

-- 12. Use dashboard view
SELECT * FROM hospital_dashboard;

-- 13. Upcoming appointments from view
SELECT * 
FROM hospital_dashboard
WHERE appointment_date >= CURDATE();

SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Appointments;

-- Trigger: auto set status when inserting appointment
DROP TRIGGER IF EXISTS before_appointment_insert;

DELIMITER $$

CREATE TRIGGER before_appointment_insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    SET NEW.status = 'Booked';
END $$

DELIMITER ;

-- Insert test row
INSERT INTO Appointments 
(patient_id, doctor_id, appointment_date, appointment_time)
VALUES (1, 1, CURDATE(), '10:00:00');

SELECT * FROM Appointments
ORDER BY appointment_id DESC;

-- Index for date filtering
CREATE INDEX idx_date 
ON Appointments(appointment_date);

SHOW INDEX FROM Appointments;

-- Additional indexes for performance improvement

CREATE INDEX idx_med_patient 
ON Medical_Records(patient_id);

CREATE INDEX idx_bill_patient 
ON Bills(patient_id);

INSERT INTO Appointments 
(patient_id, doctor_id, appointment_date, appointment_time)
VALUES (1, 1, CURDATE(), '11:00:00');

SELECT * FROM Appointments
ORDER BY appointment_id DESC;
