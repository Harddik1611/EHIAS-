-- Create Database
CREATE DATABASE EHIAS;
USE EHIAS;

-- Creating Department TABLE
create table Departments
(
	Departmentid int auto_increment primary key,
    Name varchar(50) not null
);

-- Creating Doctors Table
create table Doctors
(
	Doctorid int auto_increment primary key,
    Name varchar(50),
    Specialization varchar(100),
    Role varchar(50),
    Departmentid int,
    Foreign key (Departmentid) references departments(Departmentid)
);

-- Create Patients Table
create table Patients
(
	Patientid int auto_increment primary key,
    Name varchar(50),
    DateofBirth date,
    Gender varchar(1),
    Phone varchar(15),
    Check (Gender in('m','f','o'))
);
    
-- Create Appointment 
Create table Appointments
(
	Appointmentid int auto_increment primary key,
    Patientid int,
    Doctorid int,
    Appointmenttime datetime,
    Status varchar(50),
    Foreign key(Patientid) references Patients(Patientid),
    Foreign key(Doctorid) references Doctors(Doctorid),
    check (status in ("Scheduled","Completed","Cancelled"))
);

-- Prescription Table
create table Prescriptions
(
	Prescriptionid int auto_increment primary key,
    Appointmentid int ,
    Medication varchar(100),
    Dosage varchar(100),
    Foreign key(Appointmentid) references Appointments(Appointmentid)
);

-- Create Table Bills
create table Bills
(
	Billid int auto_increment primary key,
    Appointmentid int,
    Amount Decimal(10,2),
    Paid tinyint(1),
    Billdate datetime DEFAULT current_timestamp,
    foreign key(Appointmentid) references Appointments(Appointmentid)
);

-- Lab Report Tables
Create table LabReports
(
	Reportid int auto_increment primary key,
    Appointmentid Int,
    Reportdata text,
    Creadtedat Datetime Default Current_timestamp,
	foreign key (Appointmentid) References Appointments(Appointmentid)
)


-- Insertion Of Data into Departments Table
-- Concating all the columns for departments table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Departments.%';

-- Inserting all the data into the departments table column
INSERT into departments(Departmentid,Name)
Select `Departments.DepartmentID`,`Departments.Name` from hospital_data
WHERE  `Departments.DepartmentID` <> '';

-- Fetching all the data within the Departments table
Select * from departments;
    

-- Insertion Of Data into Doctors Table
-- Concating all the columns for departments table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Doctors.%';

-- Inserting all the data into the departments table column
INSERT into Doctors(Doctorid,Name,Specialization,Role,Departmentid)
Select `Doctors.DoctorID`,`Doctors.Name`,`Doctors.Specialization`,`Doctors.Role`,`Doctors.DepartmentID` from hospital_data
WHERE  `Doctors.DepartmentID` <> '';

-- Fetching all the data within the Departments table
Select * from doctors;
    
-- Insertion Of Data into Patients Table
-- Concating all the columns for patients table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Patients.%';

-- Inserting all the data into the departments table column
INSERT into Patients(Patientid,Name,DateofBirth,Gender,Phone)
Select `Patients.PatientID`,`Patients.Name`,
	 STR_TO_DATE(`Patients.DateofBirth`, '%d-%m-%Y'),`Patients.Gender`,`Patients.Phone` from hospital_data
WHERE  `Patients.PatientID` <> '';

-- Fetching all the data within the Patients table
Select * from Patients;

-- Insertion Of Data into Appointments Table
-- Concating all the columns for departments table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Appointments.%';

-- Inserting all the data into the appointments table column
INSERT into appointments(Appointmentid,Patientid,Doctorid,Appointmenttime,Status)
Select `Appointments.AppointmentID`,`Appointments.PatientID`,`Appointments.DoctorID`,
str_to_date(`Appointments.AppointmentTime`,'%d-%m-%Y %H:%i') ,`Appointments.Status` from hospital_data
WHERE `Appointments.AppointmentID` <> '';

-- Fetching all the data within the Appoinments table
Select * from appointments;

-- Insertion Of Data into Prescriptions Table
-- Concating all the columns for Prescriptions table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Prescriptions.%';

-- Inserting all the data into the departments table column
INSERT into Prescriptions(Prescriptionid,Appointmentid,Medication,Dosage)
Select `Prescriptions.PrescriptionID`,`Prescriptions.AppointmentID`,`Prescriptions.Medication`,`Prescriptions.Dosage` from hospital_data
WHERE  `Prescriptions.PrescriptionID` <> '';

-- Fetching all the data within the Prescriptions table
Select * from Prescriptions


-- Insertion Of Data into Bills Table
-- Concating all the columns for Bills table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Bills.%';

-- Inserting all the data into the bills table column
INSERT into Bills(Billid,Appointmentid,Amount,Paid,Billdate)
Select `Bills.BillID`,`Bills.AppointmentID`,`Bills.Amount`,`Bills.Paid`,`Bills.BillDate` from hospital_data
WHERE  `Bills.BillID` <> '';

-- Fetching all the data within the bills table
Select * from bills;


-- Insertion Of Data into Lab Reports Table
-- Concating all the columns for Prescriptions table within Hospital Data into single rows.
SELECT group_concat(concat('`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ehias'
AND TABLE_NAME='hospital_data'
AND COLUMN_NAME LIKE 'Labreports.%';

-- Inserting all the data into the labreports table column
INSERT into Labreports(Reportid,Appointmentid,Reportdata,Creadtedat)
Select `LabReports.ReportID`,`LabReports.AppointmentID`,`LabReports.ReportData`,`LabReports.CreatedAt` from hospital_data
WHERE  `LabReports.ReportID` <> '';

-- Fetching all the data within the Labreports table
Select * from labreports;

-- Created a Trigger to stop entry of back date data within the Appoinments Table and to stop multiple appoinment to doctor simultaneously

DROP TRIGGER Check_New_Appointment

Delimiter $$
CREATE TRIGGER Check_New_Appointment
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
	IF NEW.Appointmenttime < NOW() THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT="Error Code: Appoinment cannot be in the past";
	END IF;
	
    IF EXISTS
    (
		SELECT * FROM appointments
        WHERE Doctorid=NEW.Doctorid
        AND Appointmenttime=NEW.Appointmenttime
        AND STATUS IN ("SCHEDULED")
	) THEN
    SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT="Error Code: Doctor already has appoinment at this time";
	END IF;
END $$
DELIMITER $$;

-- Evaluating the working of the Trigger Check_New_Appointment
INSERT INTO appointments(Appointmentid,Patientid,Doctorid,Appointmenttime,Status)
VALUES(10000,1,1,'2026-02-27 10:00:00','SCHEDULED');

INSERT INTO appointments(Appointmentid,Patientid,Doctorid,Appointmenttime,Status)
VALUES(10002,1,1,'2026-02-27 10:00:00','SCHEDULED')


-- Create Store procedure in order to provide access of Sensitive Patients Informations to the Senior Doctor within the hospitals

DELIMITER $$
CREATE PROCEDURE VIEW_DOCTOR_DATA(IN INPUT_USERNAME VARCHAR(100) , IN INPUT_PASSWORD VARCHAR(100))
BEGIN
	DECLARE DOC_ROLE VARCHAR(100);
    DECLARE DOC_DEPT INT;
    DECLARE DOC_ID INT;
    
    -- CHECK CREDENTIALS OF THE DOCTOR
    SELECT DOCTOR_ID INTO DOC_ID
    FROM DOCTOR_CREDENTIALS
    WHERE USER_NAME=INPUT_USERNAME AND PASSWORD=INPUT_PASSWORD;
    
    -- GET ROLE AND DEPARTMENT  FROM DOCTORS TABLE
    SELECT ROLE , DEPARTMENTID
    INTO DOC_ROLE,DOC_DEPT
    FROM DOCTORS WHERE DOCTORID=DOC_Id;
    
    -- SHOW APPROPRIATE PATIENTS DATA FOR SENIOR DOCTORS ONLY
    IF DOC_ROLE= 'senior' THEN
		SELECT D.Doctorid,P.Patientid,P.name,P.Gender,
		A.Appointmenttime,PR.Medication,LR.ReportData
		FROM patients AS P INNER JOIN
		appointments AS A ON A.PATIENTID=P.PATIENTID
        JOIN DOCTORS D ON D.Doctorid=A.Doctorid
		LEFT JOIN prescriptions AS PR ON A.APPOINTMENTID=PR.APPOINTMENTID
		LEFT JOIN LABREPORTS AS LR ON A.APPOINTMENTID=LR.APPOINTMENTID
        WHERE D.Departmentid=DOC_DEPT;
	ELSE 
		SELECT D.Doctorid,P.Patientid,P.name,P.Gender,
		A.Appointmenttime,PR.Medication,LR.ReportData
		FROM patients AS P INNER JOIN
		appointments AS A ON A.PATIENTID=P.PATIENTID
        JOIN DOCTORS D ON D.Doctorid=A.Doctorid
		LEFT JOIN prescriptions AS PR ON A.APPOINTMENTID=PR.APPOINTMENTID
		LEFT JOIN LABREPORTS AS LR ON A.APPOINTMENTID=LR.APPOINTMENTID
        WHERE A.DOCTORID=DOC_ID;
	END IF;
END $$
DELIMITER $$;

-- Calling the Stored Procedure in order to fetch data for Doctor with ID 1 along with password
call VIEW_DOCTOR_DATA('doctor4','ic0pFSn0');

select * from doctors where doctorid=4
select * from ehias.doctor_credentials;


-- Creating a Stored Procedure to genreate a Monthly Report of each Department. 

Delimiter //
CREATE PROCEDURE SP_MONTHLY_REVENUE(IN P_YEAR INT,IN P_MONTH INT)
BEGIN
SELECT D1.NAME AS DEPARTMENT,
SUM(B.AMOUNT) AS TOTAL_REVENUE
FROM BILLS AS B
INNER JOIN APPOINTMENTS AS A ON A.APPOINTMENTID=B.APPOINTMENTID
INNER JOIN DOCTORS AS D ON A.DOCTORID=D.DOCTORID
INNER JOIN DEPARTMENTS AS D1 ON D1.DEPARTMENTID=D.DOCTORID
WHERE MONTH(B.BILLDATE)=P_MONTH AND YEAR(B.BILLDATE)=P_YEAR
GROUP BY D1.NAME;
END//
DELIMITER;


select * from patients

CALL SP_MONTHLY_REVENUE(2025,5)

