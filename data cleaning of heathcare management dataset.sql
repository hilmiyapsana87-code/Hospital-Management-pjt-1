--==============
-- CLEANING DATA
--==============

-- Count of rows in all tables

SELECT COUNT(*) AS TotalPatients
FROM patients;

SELECT COUNT(*) AS TotalDoctors
FROM doctors;

SELECT COUNT(*) AS TotalAppointments
FROM appointments;

SELECT COUNT(*) AS TotalBills
FROM billing;

SELECT COUNT(*) AS TotalTreatments
FROM treatments;


-- Find unique rows with distinct

SELECT COUNT(DISTINCT patient_id) AS TotalPatients
FROM patients;

SELECT DISTINCT status
FROM appointments;


-- Check Duplicates in all tables
---------------------------------

-- Check whether a patient data entered twice

SELECT patient_name, date_of_birth, COUNT(*) AS Total
FROM patients
GROUP BY patient_name, date_of_birth
HAVING COUNT(*) > 1;

-- Check whether a doctor data entered twice

SELECT doctor_name, COUNT(*) AS Total
FROM doctors
GROUP BY doctor_name
HAVING COUNT(*) > 1;

-- Check whether a appointment data entered twice

SELECT appointment_id, COUNT(*) AS Total
FROM appointments
GROUP BY appointment_id
HAVING COUNT(*) > 1;


-- Check Impossible Dates
-------------------------

-- Check whether date is out of range

SELECT *
FROM patients
WHERE date_of_birth > GETDATE();

SELECT *
FROM patients
WHERE date_of_birth < '1900-01-01';

-- Check whether price is negative

SELECT amount
FROM billing
WHERE amount <= 0;

SELECT cost
FROM treatments
WHERE cost <= 0;


-- Validate Relationship between tables
---------------------------------------

-- Relationship between patients and appointments table

SELECT a.*
FROM appointments a
LEFT JOIN patients p
ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

-- Relationship between doctors and appointments table

SELECT a.*
FROM appointments a
LEFT JOIN doctors d
ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL;

-- Relationship between billing and treatments table

SELECT b.*
FROM billing b
LEFT JOIN treatments t
ON b.treatment_id = t.treatment_id
WHERE t.treatment_id IS NULL;

-- Relationship between patients and billing table

SELECT *
FROM billing b
JOIN patients p
ON b.patient_id = p.patient_id;


--=============
-- CONVERSIONS
--=============

-- Alter Billing Table
-----------------------

-- Add new column

ALTER TABLE billing
ADD patient_id_new INT;

-- Conversion float into integer data type

UPDATE billing
SET patient_id_new = CAST(patient_id AS INT);

-- Round amount to 1 decimal point

UPDATE billing
SET amount = ROUND(amount,1);

-- Drop old column

ALTER TABLE billing
DROP COLUMN patient_id;

-- Rename new column

EXEC sp_rename 'billing.patient_id_new','patient_id','COLUMN';

-- Alter Treatments table
-------------------------

-- Round amount to 1 decimal point

UPDATE treatments
SET cost = ROUND(cost,1);
