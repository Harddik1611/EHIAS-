# 🏥 EHIAS – Enterprise Hospital Information Automation System

## 📌 Project Overview
EHIAS is a **MySQL-based hospital database system** designed to migrate a legacy **Excel-based hospital record system** into a **structured, secure, and automated relational database**.  
The project focuses on enforcing **data integrity, business rules, access control, and reporting automation** directly at the database level.

--------
## 🎯 Problem Statement
The hospital previously managed patients, doctors, appointments, billing, and lab records using Excel files, which led to:
- No guaranteed unique identifiers
- Disconnected and unenforced relationships
- Invalid and inconsistent data entries
- Manual and error-prone operations
- No access control or automated reporting

All critical rules are enforced **at the database level** using **constraints, triggers, and stored procedures**.

----------
## ✅ Solution Summary
This project replaces Excel with a **normalized relational database (3NF)** using MySQL and solves the above issues through:
- Primary & foreign keys
- CHECK constraints
- Triggers for validation
- Stored procedures for automation and security

-------------

## 🧱 Database Creation
The system models core hospital operations using the following entities:
- Departments  
- Doctors  
- Patients  
- Appointments  
- Prescriptions  
- Lab Reports  
- Bills 

## EHIAS Database ER Diagram
![ER Diagram](Ehias_er_dig.png)


### **Key Design Choices**
- `AUTO_INCREMENT` primary keys for uniqueness
- Foreign keys to enforce referential integrity
- Domain constraints to prevent invalid data

=*=*50
```sql
CREATE DATABASE EHIAS;
USE EHIAS;
```
## Purpose:
- Creates a dedicated database to isolate hospital data and ensure maintainability.
=*=*50

## 🏢 Departments Table
```
CREATE TABLE Departments (
    Departmentid INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);
```
### Why this design?
- AUTO_INCREMENT ensures unique department identifiers.
- Departments act as a parent entity for doctors and revenue reporting.

---------
## 👨‍⚕️ Doctors Table
```
CREATE TABLE Doctors (
    Doctorid INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50),
    Specialization VARCHAR(100),
    Role VARCHAR(50),
    Departmentid INT,
    FOREIGN KEY (Departmentid) REFERENCES Departments(Departmentid)
);
```
### Key Points:
- Each doctor belongs to a department.
- Role is later used for access control in stored procedures.
- Foreign key enforces valid department mapping.

---------
## 🧑‍🦱 Patients Table
```
CREATE TABLE Patients (
    Patientid INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50),
    DateofBirth DATE,
    Gender VARCHAR(1),
    Phone VARCHAR(15),
    CHECK (Gender IN ('m','f','o'))
);
```
### Business Rules Enforced:
- Gender values restricted to valid options only ("M" or "F" or others as "o")
- Prevents ambiguous entries like 'X' or 'Malee'.

----------
## 📅 Appointments Table
```
CREATE TABLE Appointments (
    Appointmentid INT AUTO_INCREMENT PRIMARY KEY,
    Patientid INT,
    Doctorid INT,
    Appointmenttime DATETIME,
    Status VARCHAR(50),
    FOREIGN KEY (Patientid) REFERENCES Patients(Patientid),
    FOREIGN KEY (Doctorid) REFERENCES Doctors(Doctorid),
    CHECK (Status IN ('Scheduled','Completed','Cancelled'))
);
```

### Why this matters:
- Links patients and doctors using foreign keys.
- Appointment status strictly controlled.
- Foundation for billing, prescriptions, and lab reports.
--------

## 💊 Prescriptions Table
```
CREATE TABLE Prescriptions (
    Prescriptionid INT AUTO_INCREMENT PRIMARY KEY,
    Appointmentid INT,
    Medication VARCHAR(100),
    Dosage VARCHAR(100),
    FOREIGN KEY (Appointmentid) REFERENCES Appointments(Appointmentid)
);
```
### Purpose:
- Prescriptions tied directly to appointments.
- Prevents orphan medical records.
---------

## 🧾 Bills Table
```
CREATE TABLE Bills (
    Billid INT AUTO_INCREMENT PRIMARY KEY,
    Appointmentid INT,
    Amount DECIMAL(10,2),
    Paid TINYINT(1),
    Billdate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Appointmentid) REFERENCES Appointments(Appointmentid)
);
```
### Why this design?
- Enables financial tracking per appointment.
- Supports revenue aggregation by department.

------------

## 🧪 Lab Reports Table
```
CREATE TABLE LabReports (
    Reportid INT AUTO_INCREMENT PRIMARY KEY,
    Appointmentid INT,
    Reportdata TEXT,
    Createdat DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Appointmentid) REFERENCES Appointments(Appointmentid)
);
```
### Purpose:
- Stores diagnostic results.
- Maintains strict linkage to appointments.

-----------

### 📦 Data Migration Strategy
- Legacy Excel data was imported into a staging table called hospital_data.
```
INSERT INTO Patients (Patientid, Name, DateofBirth, Gender, Phone)
SELECT 
    `Patients.PatientID`,
    `Patients.Name`,
    STR_TO_DATE(`Patients.DateofBirth`, '%d-%m-%Y'),
    `Patients.Gender`,
    `Patients.Phone`
FROM hospital_data
WHERE `Patients.PatientID` <> '';
```
### What this achieves:
- Standardizes inconsistent date formats.
- Filters invalid rows.
- Migrates clean data only.

----

## ⚙️ Trigger: Appointment Validation
```
CREATE TRIGGER Check_New_Appointment
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF NEW.Appointmenttime < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment cannot be in the past';
    END IF;

    IF EXISTS (
        SELECT 1 FROM Appointments
        WHERE Doctorid = NEW.Doctorid
        AND Appointmenttime = NEW.Appointmenttime
        AND Status = 'Scheduled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor already has an appointment at this time';
    END IF;
END;
```
### Business Rules Enforced Automatically:
### Appointment Validation Trigger
A `BEFORE INSERT` trigger on appointments ensures:
- Appointments cannot be scheduled in the past
- Doctors cannot be double-booked for the same time slot

**Result:**  
Prevents invalid scheduling and enforces real-world hospital rules automatically.

---------

## 🔐 Stored Procedure: Role-Based Doctor Access
```
CREATE PROCEDURE VIEW_DOCTOR_DATA (
    IN INPUT_USERNAME VARCHAR(100),
    IN INPUT_PASSWORD VARCHAR(100)
)
BEGIN
    DECLARE DOC_ROLE VARCHAR(50);
    DECLARE DOC_DEPT INT;
    DECLARE DOC_ID INT;

    SELECT Doctor_id INTO DOC_ID
    FROM Doctor_Credentials
    WHERE User_Name = INPUT_USERNAME
    AND Password = INPUT_PASSWORD;

    SELECT Role, Departmentid
    INTO DOC_ROLE, DOC_DEPT
    FROM Doctors
    WHERE Doctorid = DOC_ID;

    IF DOC_ROLE = 'senior' THEN
        SELECT *
        FROM Patients P
        JOIN Appointments A ON P.Patientid = A.Patientid
        JOIN Doctors D ON A.Doctorid = D.Doctorid
        WHERE D.Departmentid = DOC_DEPT;
    ELSE
        SELECT *
        FROM Patients P
        JOIN Appointments A ON P.Patientid = A.Patientid
        WHERE A.Doctorid = DOC_ID;
    END IF;
END;
```
### Access Logic:
- Senior doctors → Department-wide patient data
- Junior doctors → Own appointments only

### Why stored procedure?
### Role-Based Doctor Data Access
- Authenticates doctors using credentials
- **Senior doctors** can view all patient data within their department
- **Junior doctors** can access only their own appointments

This ensures **secure and controlled access to sensitive patient information**.

---------

## 📊 Stored Procedure: Monthly Revenue Report
```
CREATE PROCEDURE SP_MONTHLY_REVENUE (
    IN P_YEAR INT,
    IN P_MONTH INT
)
BEGIN
    SELECT 
        D.Name AS Department,
        SUM(B.Amount) AS Total_Revenue
    FROM Bills B
    JOIN Appointments A ON B.Appointmentid = A.Appointmentid
    JOIN Doctors DR ON A.Doctorid = DR.Doctorid
    JOIN Departments D ON DR.Departmentid = D.Departmentid
    WHERE MONTH(B.Billdate) = P_MONTH
    AND YEAR(B.Billdate) = P_YEAR
    GROUP BY D.Name;
END;
```
### Monthly Department Revenue Report
- Generates department-wise revenue
- Accepts year and month as input parameters
- Aggregates billing data automatically

Used for **management reporting and financial analysis**.

-------

## 🚀 Key Outcomes
- Migrated Excel-based hospital data into a **production-ready MySQL database**
- Enforced business rules using triggers and constraints.
- Eliminated invalid and inconsistent records.
- Automated appointment validation and reporting.
- Implemented database-level security and access control.
- Improved data accuracy, scalability, and reliability.

## EHIAS PESTEL Analysis
![EHIAS PESTEL ANALYSIS](Pestel_Analysis.png)

------

## 🛠️ Technologies Used
- MySQL
- SQL (DDL, DML)
- Triggers
- Stored Procedures
- Relational Database Design (3NF)

------

## 📄 Author
Harddik Singh
SQL • Data Analytics • Hospital Database Design

-------



