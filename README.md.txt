# 🏥 Hospital Management System (MySQL Project)

## 📌 Project Overview

This project is a **Hospital Management System** designed using MySQL to manage patients, doctors, appointments, medical records, and billing efficiently.
It demonstrates strong database design, data integrity, and real-world problem-solving using advanced SQL features.

---

## 🚀 Key Features

* 👨‍⚕️ Manage Doctors and Patients
* 📅 Appointment Scheduling System
* ❌ Prevent Double Booking using composite UNIQUE constraint
* 📊 Analytical Queries (busiest doctor, appointment counts)
* 👁️ Dashboard View for simplified reporting
* ⚙️ Stored Procedure for dynamic queries
* 🔁 Trigger to automate appointment status
* ⚡ Indexing for faster query performance

---

## 🗂️ Database Design

### Tables:

* **Patients** → Stores patient details
* **Doctors** → Stores doctor information
* **Appointments** → Manages booking system
* **Medical_Records** → Stores diagnosis & treatment
* **Bills** → Handles billing information

---

## 🔐 Constraints & Data Integrity

* **PRIMARY KEY** → Unique identification
* **FOREIGN KEY** → Maintains relationships
* **UNIQUE Constraint** → Prevents double booking:

  ```sql
  UNIQUE (doctor_id, appointment_date, appointment_time)
  ```
* **CHECK Constraint** → Ensures valid fees (> 0)
* **ENUM** → Restricts appointment status values

---

## ⚙️ Advanced SQL Features

### 🔹 View (Dashboard)

Simplifies complex joins:

```sql
CREATE VIEW hospital_dashboard AS
SELECT a.appointment_id, a.doctor_id, p.name AS patient_name,
       d.name AS doctor_name, a.appointment_date,
       a.appointment_time, a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;
```

---

### 🔹 Stored Procedure

Fetch appointments for a specific doctor:

```sql
CALL GetDoctorAppointments(1);
```

---

### 🔹 Trigger

Automatically sets appointment status:

```sql
SET NEW.status = 'Booked';
```

---

### 🔹 Indexing

Improves performance for large datasets:

* `patient_id`
* `doctor_id`
* `appointment_date`

---

## 📊 Sample Queries

### ✔ Get all appointments

```sql
SELECT * FROM hospital_dashboard;
```

### ✔ Find busiest doctor

```sql
SELECT d.name, COUNT(*) AS total
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id
ORDER BY total DESC
LIMIT 1;
```

---

## 🧪 How to Run the Project

1. Open **MySQL Workbench**
2. Copy the SQL script into a new query tab
3. Execute full script:

   ```
   Ctrl + Shift + Enter
   ```
4. Test stored procedure:

   ```sql
   CALL GetDoctorAppointments(1);
   ```
5. Insert test appointment (trigger will auto-set status):

   ```sql
   INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time)
   VALUES (1, 1, CURDATE(), '11:00:00');
   ```

---

## ❗ Key Learning Outcomes

* Database Design & Normalization
* SQL Joins & Relationships
* Constraints & Data Integrity
* Performance Optimization using Indexes
* Real-world problem solving (double booking prevention)

---

## 🔮 Future Enhancements

* Add transaction handling
* Implement doctor availability check
* Build frontend using React or Flask
* Add authentication system

---

## 👩‍💻 Author

**Ishwari Mankari**

---

## ⭐ If you like this project

Give it a ⭐ on GitHub and feel free to contribute!
