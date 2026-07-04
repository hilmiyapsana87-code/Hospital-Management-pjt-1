-- ======================
-- Age Group Segmentation
-- ======================

-- Create new Age column in patients table

SELECT 
DATEDIFF(YEAR,date_of_birth,registration_date) AS Age,
first_name + ' ' + last_name AS patient_name
FROM patients;

-- Alter and Update table with permanent update Age and patient_name

ALTER TABLE patients
ADD Age INT, patient_name VARCHAR(50);

UPDATE patients
SET Age = DATEDIFF(YEAR,date_of_birth,registration_date),
patient_name = first_name + ' ' + last_name;

-- Drop old columns

ALTER TABLE patients
DROP COLUMN first_name, last_name;

-- Categorize patients based on age group with case when statement

SELECT
CASE 
     WHEN Age < 18 THEN 'Pediatrics'
     WHEN Age BETWEEN 18 AND 35 THEN 'Adult'
     WHEN Age BETWEEN 36 AND 55 THEN 'Middle Age'
     WHEN Age BETWEEN 56 AND 70 THEN 'Senior Citizen'
     ELSE 'Old Age'
END AS Age_Category,
COUNT(*) AS TotalPatients
FROM patients
GROUP BY CASE 
     WHEN Age < 18 THEN 'Pediatrics'
     WHEN Age BETWEEN 18 AND 35 THEN 'Adult'
     WHEN Age BETWEEN 36 AND 55 THEN 'Middle Age'
     WHEN Age BETWEEN 56 AND 70 THEN 'Senior Citizen'
     ELSE 'Old Age'
END 
ORDER BY TotalPatients DESC;


-- ===================
-- Gender distribution
-- ===================

SELECT gender,
COUNT(*) TotalPatients,
ROUND(AVG(Age),1) AvgAge,
MIN(Age) MinAge,
MAX(Age) MaxAge,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(),1) percentage
FROM patients
GROUP BY gender;


-- =========================
-- Patients reason for visit
-- =========================

SELECT TOP 5 a.reason_for_visit, 
COUNT(p.patient_id) TotalPatients,
ROUND(AVG(Age),1) AvgAge
FROM patients p
LEFT JOIN appointments a
ON a.patient_id = p.patient_id
GROUP BY a.reason_for_visit
ORDER BY COUNT(p.patient_id) DESC;


-- ==============================
-- Treatment Type & Cost Analysis
-- ==============================

SELECT 
treatment_type,
COUNT(*) TotalTreatment,
ROUND(AVG(cost),0) AvgCost
FROM treatments
GROUP BY treatment_type
ORDER BY TotalTreatment DESC;


-- ========================
-- Total Patients By Doctor
-- ========================

SELECT 
d.doctor_name, d.specialization, d.years_experience,
SUM(COUNT(a.status)) OVER(PARTITION BY d.doctor_name 
                           ORDER BY d.years_experience DESC) TotalPatients
FROM doctors d
LEFT JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.specialization, d.years_experience,d.doctor_name
ORDER BY TotalPatients DESC;

-- ================================
-- Rank top 3 doctor by departments
-- ================================

WITH cte_rank AS(
SELECT d.doctor_id, d.specialization, d.years_experience,
COUNT(a.appointment_id) CountPatients,
RANK() OVER(PARTITION BY d.specialization 
            ORDER BY COUNT(a.appointment_id) DESC) rn
FROM doctors d
LEFT JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.specialization, d.years_experience)

SELECT *
FROM cte_rank
WHERE rn <= 3;


-- ============================================
-- Categorize appointment status of each doctor
-- ============================================

WITH cte_docs AS(
SELECT d.doctor_id, d.specialization, d.years_experience,
COUNT(a.appointment_id) CountPatients,
SUM(CASE WHEN a.status = 'Completed' then 1 else 0 END) Completion,
SUM(CASE WHEN a.status = 'Cancelled' then 1 else 0 END) Cancellation,
SUM(CASE WHEN a.status = 'No-show' then 1 else 0 END) NoShow,
SUM(CASE WHEN a.status = 'Scheduled' then 1 else 0 END) Scheduled
FROM doctors d
LEFT JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.specialization, d.years_experience),

cte_rate AS(
SELECT *,
ROUND(Completion*100/CountPatients,1) Completion_rate,
ROUND(Cancellation*100/CountPatients,1) Cancellation_rate,
ROUND(NoShow*100/CountPatients,1) NoShow_rate,
ROUND(Scheduled*100/CountPatients,1) Scheduled_rate
FROM cte_docs)

SELECT *
FROM cte_rate
ORDER BY CountPatients DESC;

-- ===============================
-- Total Revenue by payment status
-- ===============================

SELECT payment_status, SUM(amount) TotalAmount, 
SUM(CASE WHEN payment_status = 'Paid' then amount
         ELSE 0
    END)*100/NULLIF(SUM(amount),0) Rate_of_paid_status
FROM billing
GROUP BY payment_status
ORDER BY TotalAmount DESC;


-- =====================================
-- Rank payment status by payment method
-- =====================================

SELECT payment_method, payment_status, 
SUM(amount) TotalAmount,
RANK() OVER(PARTITION BY payment_method ORDER BY SUM(amount) DESC) rn
FROM billing
GROUP BY payment_status, payment_method;


-- ===============================
-- Total Revenue by payment method
-- ===============================

SELECT payment_method,
SUM(amount) TotalAmount
FROM billing
GROUP BY payment_method
ORDER BY TotalAmount DESC;


-- ===========================================
-- Total amount and patients analysis by month
-- ===========================================

SELECT FORMAT(bill_date, 'yyyy-MM') Month, 
ROUND(SUM(amount),0) TotalAmount,
COUNT(patient_id) TotalPatients
FROM billing
GROUP BY FORMAT(bill_date, 'yyyy-MM')
ORDER BY TotalAmount DESC;

-- ==========================================
-- Payment status details by patients details
-- ==========================================

SELECT p.patient_id, p.patient_name, p.Age, p.contact_number, p.address, 
b.payment_method, b.payment_status, b.amount,
ROUND(SUM(CASE WHEN b.payment_status = 'Failed' then b.amount else 0 END) 
               OVER(PARTITION BY p.patient_id),0) AS SumFailedPayment,
ROUND(SUM(CASE WHEN b.payment_status = 'Pending' then b.amount else 0 END) 
                OVER(PARTITION BY p.patient_id),0) AS SumPendingPayment,
ROUND(SUM(CASE WHEN b.payment_status = 'Paid' then b.amount else 0 END) 
               OVER(PARTITION BY p.patient_id),0) AS SumPaidPayment
FROM patients p
JOIN billing b
ON p.patient_id = b.patient_id
ORDER BY SumPendingPayment DESC;


-- ================================
-- Top pending payments by patients
-- ================================

SELECT p.patient_id, p.contact_number, COUNT(b.bill_id) CountBill,
ROUND(SUM(CASE WHEN b.payment_status = 'Pending' 
               then b.amount else 0 END),0) AS SumPendingPayment
FROM patients p
JOIN billing b
ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.contact_number
ORDER BY SumPendingPayment DESC;


-- =================================
-- Top total appointments by weekday
-- =================================

SELECT DATENAME(WEEKDAY,appointment_date) Day,
COUNT(*) TotalAppointments
FROM appointments
GROUP BY DATENAME(WEEKDAY,appointment_date)
ORDER BY TotalAppointments DESC;


-- =========================
-- Monthly Timeline Analysis
-- =========================

SELECT
FORMAT(appointment_date, 'yyyy-MM') Month,
COUNT(*) TotalAppointments,
SUM(CASE WHEN reason_for_visit = 'Therapy' then 1 else 0 END) therapy_visit,
SUM(CASE WHEN reason_for_visit = 'Consultation' then 1 else 0 END) consultation_visit,
SUM(CASE WHEN reason_for_visit = 'Emergency' then 1 else 0 END) emergency_visit,
SUM(CASE WHEN reason_for_visit = 'Checkup' then 1 else 0 END) checkup_visit,
SUM(CASE WHEN reason_for_visit = 'Follow-up' then 1 else 0 END) followup_visit,
SUM(CASE WHEN status = 'Completed' then 1 else 0 END) completed_status,
SUM(CASE WHEN status = 'Cancelled' then 1 else 0 END) cancelled_status,
SUM(CASE WHEN status = 'No-show' then 1 else 0 END) noshow_status,
SUM(CASE WHEN status = 'Scheduled' then 1 else 0 END) scheduled_status,
SUM(CASE WHEN status = 'Completed' then 1 else 0 END)*100/COUNT(*) Completed_rate
FROM appointments
GROUP BY FORMAT(appointment_date, 'yyyy-MM')
ORDER BY TotalAppointments DESC;


-- =======================================
-- Patient visit reason by doctor analysis
-- =======================================

SELECT d.doctor_id,
COUNT(*) TotalAppointments,
SUM(CASE WHEN reason_for_visit = 'Therapy' then 1 else 0 END) therapy_visit,
SUM(CASE WHEN reason_for_visit = 'Consultation' then 1 else 0 END) consultation_visit,
SUM(CASE WHEN reason_for_visit = 'Emergency' then 1 else 0 END) emergency_visit,
SUM(CASE WHEN reason_for_visit = 'Checkup' then 1 else 0 END) checkup_visit,
SUM(CASE WHEN reason_for_visit = 'Follow-up' then 1 else 0 END) followup_visit
FROM appointments a
JOIN doctors d
ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id
ORDER BY TotalAppointments DESC;


-- ===================================
-- Retention Rate Analysis by patients
-- ===================================

WITH cte_retention AS(
SELECT patient_id, 
COUNT(*) No_of_visit
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 1)

SELECT a.patient_id,
SUM(c.No_of_visit)*100/COUNT(a.patient_id) RetentionRate
FROM appointments a
LEFT JOIN cte_retention c
ON c.patient_id = a.patient_id
GROUP BY a.patient_id
ORDER BY RetentionRate DESC;


-- ===============================
-- Revenue generated per treatment
-- ===============================

SELECT treatment_type,
COUNT(*) TotalTreatments,
SUM(cost) TotalCost
FROM treatments
GROUP BY treatment_type
ORDER BY SUM(cost) desc;


-- ===============
-- Join key tables 
-- ===============

CREATE VIEW view_key_table AS
SELECT p.patient_id, p.contact_number, p.Age, p.registration_date,
d.doctor_id, d.phone_number, d.hospital_branch, d.specialization, 
d.years_experience, a.appointment_id, a.appointment_date, a.appointment_time, 
a.reason_for_visit,a.status, b.bill_id, b.amount, b.payment_status, 
b.payment_method, b.bill_date
FROM patients p
LEFT JOIN appointments a
ON p.patient_id = a.patient_id
LEFT JOIN doctors d
ON d.doctor_id = a.doctor_id
LEFT JOIN billing b
ON b.patient_id = a.patient_id;

SELECT *
FROM view_key_table
WHERE specialization = 'Oncology'
AND hospital_branch = 'Westside Clinic'
AND payment_status = 'Pending';


-- ============================
-- Revenue report by department
-- ============================

ALTER PROCEDURE sp_DeptRevenueReport @specialization VARCHAR(50) = 'Dermatology'
AS
BEGIN
SELECT d.doctor_id, d.doctor_name, d.specialization, 
COUNT(a.appointment_id) TotalAppointments,
SUM(b.amount) TotalAmount, b.payment_status
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
JOIN billing b
ON a.patient_id = b.patient_id
GROUP BY d.doctor_id, d.doctor_name, b.payment_status, d.specialization
HAVING b.payment_status = 'Paid'
ORDER BY TotalAmount DESC
END;

EXEC sp_DeptRevenueReport @specialization = 'Oncology';