-- ==========================
-- NOVA PHARMACY DATABASE
-- ==========================

DROP DATABASE IF EXISTS nova_pharmacy;
CREATE DATABASE nova_pharmacy;
USE nova_pharmacy;

-- 1) DROP & RECREATE ALL TABLES

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Doctor, Patient, Pharma_Company, Drug, Pharmacy, Sells, Cures, Contract, Prescription, Prescription_Content;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Doctor (
  aadhar_id       VARCHAR(12) PRIMARY KEY,
  name            VARCHAR(100) NOT NULL,
  speciality      VARCHAR(100),
  yoe      INT
);

CREATE TABLE Patient (
  aadhar_id            VARCHAR(12) PRIMARY KEY,
  name                 VARCHAR(100) NOT NULL,
  address              VARCHAR(255),
  age                  INT,
  primary_physician_id VARCHAR(12) NOT NULL,
  FOREIGN KEY (primary_physician_id)
    REFERENCES Doctor(aadhar_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE Pharma_Company (
  name   VARCHAR(100) PRIMARY KEY,
  phone  VARCHAR(10)
);

CREATE TABLE Drug (
  trade_name   VARCHAR(100),
  ph_comp_name VARCHAR(100),
  formula      TEXT,
  PRIMARY KEY (trade_name, ph_comp_name),
  FOREIGN KEY (ph_comp_name)
    REFERENCES Pharma_Company(name)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE Pharmacy (
  name    VARCHAR(100) PRIMARY KEY,
  address VARCHAR(255),
  phone   VARCHAR(20)
);

CREATE TABLE Sells (
  trade_name   VARCHAR(100),
  ph_comp_name VARCHAR(100),
  ph_name      VARCHAR(100),
  price        DECIMAL(10,2) check (price > 0),
  quantity 	 INT CHECK (quantity >= 0),
  PRIMARY KEY (trade_name, ph_comp_name, ph_name),
  FOREIGN KEY (trade_name, ph_comp_name)
    REFERENCES Drug(trade_name, ph_comp_name)
    ON UPDATE CASCADE
    ON DELETE cascade,
  FOREIGN KEY (ph_name)
    REFERENCES Pharmacy(name)
    ON UPDATE CASCADE
    ON DELETE cascade
);

create table Cures(
	P_aadhar varchar(12),
    D_aadhar varchar(12),
    PRIMARY KEY (p_aadhar,d_aadhar),
    FOREIGN KEY (p_aadhar) REFERENCES Patient (aadhar_id) on update CASCADE ON DELETE cascade,
    FOREIGN KEY (d_aadhar) REFERENCES Doctor (aadhar_id) on update CASCADE ON DELETE cascade
);

CREATE TABLE Contract (
  ph_name      VARCHAR(100),
  ph_comp_name VARCHAR(100),
  start_date   DATE,
  end_date     DATE,
  content      TEXT,
  supervisor   VARCHAR(100),
  PRIMARY KEY (ph_name, ph_comp_name, start_date,end_date),
  FOREIGN KEY (ph_name)
    REFERENCES Pharmacy(name)
    ON DELETE CASCADE,
  FOREIGN KEY (ph_comp_name)
    REFERENCES Pharma_Company(name)
    ON DELETE CASCADE
);

CREATE TABLE Prescription (
  doc_id      VARCHAR(12),
  patient_id  VARCHAR(12),
  date        DATE,
  primary key (doc_id,patient_id),
  FOREIGN KEY (doc_id)      REFERENCES Doctor(aadhar_id)   ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (patient_id)  REFERENCES Patient(aadhar_id)  ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Prescription_Content (
	doc_id      VARCHAR(12),
  patient_id  VARCHAR(12),
  trade_name      VARCHAR(100),
  ph_comp_name    VARCHAR(100),
  quantity        INT,
  PRIMARY KEY (doc_id,patient_id, trade_name, ph_comp_name),
  FOREIGN KEY (doc_id,patient_id)
    REFERENCES Prescription(doc_id,patient_id)
    ON DELETE CASCADE,
  FOREIGN KEY (trade_name, ph_comp_name)
    REFERENCES Drug(trade_name, ph_comp_name)
    ON DELETE RESTRICT
);



-- 2) CRUD STORED PROCEDURES for each entity
DELIMITER //


-- Doctors
CREATE PROCEDURE add_doctor(
  IN d_id VARCHAR(12), IN d_name VARCHAR(100),
  IN d_speciality VARCHAR(100), IN d_experience INT,
  IN p_id VARCHAR(12))
BEGIN
  INSERT INTO Doctor VALUES(d_id,d_name,d_speciality,d_experience);
  INSERT INTO Cures VALUES(p_id,d_id);
END;//
DELIMITER //


create procedure adddoctorpatient(
	in patientid varchar(12), in doctorid varchar(12))
begin
	insert into Cures values (patientid,doctorid);
end;//


CREATE PROCEDURE update_doctor(
  IN d_id VARCHAR(12), IN d_name VARCHAR(100),
   IN d_experience INT)
BEGIN
  UPDATE Doctor
    SET name=d_name, yoe=d_experience
    WHERE aadhar_id=d_id;
END;//

DELIMITER //


CREATE PROCEDURE delete_doctor(
IN d_aadhar VARCHAR(12) )
BEGIN
  DECLARE doc_specialty VARCHAR(100);
  DECLARE patient_count INT;

  -- Get specialty
  SELECT speciality INTO doc_specialty
  FROM doctor
  WHERE aadhar_id = d_aadhar;

  -- If doctor not found
  IF doc_specialty IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Doctor not found.';
  END IF;

  -- If doctor is a physician, check if they have patients
  IF LOWER(doc_specialty) = 'physician' THEN
    SELECT COUNT(*) INTO patient_count
    FROM Patient
    WHERE primary_physician_id = d_aadhar;

    IF patient_count > 1 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot delete physician with assigned patients.';
    END IF;
  END IF;

  -- Delete from cures
  DELETE FROM Cures WHERE D_aadhar = d_aadhar;

  -- Delete from doctor
  DELETE FROM doctor WHERE aadhar_id = d_aadhar;
END;
//



-- Patients

CREATE PROCEDURE add_patient(
  IN p_id VARCHAR(12), IN p_name VARCHAR(100),
  IN p_address VARCHAR(255), IN p_age INT,
  IN p_primary_phys VARCHAR(12))
BEGIN
  INSERT INTO Patient
    VALUES(p_id,p_name,p_address,p_age,p_primary_phys);
	insert into Cures values (p_id,p_primary_phys);
END;//


CREATE PROCEDURE add_patientwithdoctor(
  IN p_aadhar VARCHAR(12),
  IN p_name    VARCHAR(100),
  IN p_address VARCHAR(200),
  IN p_age     INT,
  IN d_paadhardoctor VARCHAR(12),
  IN d_name_doctor    VARCHAR(100),
  IN d_exp     INT
)
BEGIN
insert into doctor values (d_paadhardoctor,d_name_doctor,"PHYSICIAN",d_exp);
  INSERT INTO patient VALUES(p_aadhar,p_name,p_address,p_age,d_paadhardoctor);
    
    insert into cures values(p_aadhar,d_paadhardoctor);
END;//
DELIMITER //



CREATE PROCEDURE update_patient(
  IN p_id VARCHAR(12),
  IN p_name VARCHAR(100),
  IN p_address VARCHAR(255),
  IN p_age INT,
  IN p_primary_phys VARCHAR(12)
)
BEGIN
  DECLARE doc_specialty VARCHAR(100);

  -- Get the specialty of the doctor (if they exist)
  SELECT speciality INTO doc_specialty
  FROM doctor
  WHERE aadhar_id = p_primary_phys;

  -- If no doctor found, signal error
  IF doc_specialty IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Doctor does not exist.';
  ELSEIF LOWER(doc_specialty) != 'physician' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Primary doctor must be a physician.';
  ELSE
    -- Proceed with update
    UPDATE patient
      SET name = p_name,
          address = p_address,
          age = p_age,
          primary_physician_id = p_primary_phys
      WHERE aadhar_id = p_id;
  END IF;
END;
//


DELIMITER //

CREATE PROCEDURE delete_patient(
IN p_aadhar VARCHAR(12) )
BEGIN

  DECLARE done INT DEFAULT 0;
  DECLARE d_id VARCHAR(12);
  DECLARE doc_patient_count INT;

  -- Cursor to loop over doctors linked to the patient
  DECLARE doc_cursor CURSOR FOR
    SELECT D_aadhar FROM cures WHERE P_aadhar = p_aadhar;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN doc_cursor;
 
  read_loop: LOOP
    FETCH doc_cursor INTO d_id;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Count how many patients this doctor has
    SELECT COUNT(*) INTO doc_patient_count
    FROM cures
    WHERE D_aadhar = d_id;

    -- If doctor has only this patient, delete the doctor
    IF doc_patient_count = 1 THEN
      DELETE FROM doctor WHERE aadhar_id = d_id;
    END IF;
  END LOOP;

  CLOSE doc_cursor;

  -- Delete from cures
 DELETE FROM cures WHERE P_aadhar = p_aadhar;

  -- Delete patient
  DELETE FROM patient WHERE aadhar_id = p_aadhar;
END;
//


DELIMITER //

-- Pharma Companies


CREATE PROCEDURE add_pharma_company(
  IN p_name VARCHAR(100), IN p_phone VARCHAR(20))
BEGIN
  INSERT INTO Pharma_Company VALUES(p_name,p_phone);
END;//
DELIMITER //


CREATE PROCEDURE update_pharma_company(
  IN p_name VARCHAR(100), IN p_phone VARCHAR(20))
BEGIN
  UPDATE Pharma_Company
    SET phone=p_phone
    WHERE name=p_name;
END;//
DELIMITER //


CREATE PROCEDURE delete_pharma_company(
	IN p_name VARCHAR(100) )
BEGIN
    delete from sells where ph_comp_name=p_name;
    delete from drug where ph_comp_name = p_name; 
  DELETE FROM Pharma_Company WHERE name=p_name;
END;//
DELIMITER //



-- Drugs


CREATE PROCEDURE add_drug(
  IN p_trade VARCHAR(100), 
  IN p_comp VARCHAR(100), 
  IN p_formula TEXT
)
BEGIN
INSERT INTO Drug (trade_name, ph_comp_name, formula)
  VALUES (p_trade, p_comp, p_formula);
END //
DELIMITER //


CREATE PROCEDURE update_drug(
  IN p_trade VARCHAR(100), IN p_comp VARCHAR(100), IN p_formula TEXT)
BEGIN
  UPDATE Drug
    SET formula=p_formula
    WHERE trade_name=p_trade AND ph_comp_name=p_comp;
END;//
DELIMITER //


CREATE PROCEDURE delete_drug(
  IN p_trade VARCHAR(100), IN p_comp VARCHAR(100))
BEGIN
  DELETE FROM Drug
    WHERE trade_name=p_trade AND ph_comp_name=p_comp;
END;//
DELIMITER //



-- Pharmacies


CREATE PROCEDURE add_pharmacy(
  IN p_name VARCHAR(100), IN p_address VARCHAR(255), IN p_phone VARCHAR(20))
BEGIN
  INSERT INTO Pharmacy VALUES(p_name,p_address,p_phone);
END;//
DELIMITER //


CREATE PROCEDURE update_pharmacy(
  IN p_name VARCHAR(100), IN p_address VARCHAR(255), IN p_phone VARCHAR(20))
BEGIN
  UPDATE Pharmacy
    SET address=p_address, phone=p_phone
    WHERE name=p_name;
END;//
DELIMITER //


CREATE PROCEDURE delete_pharmacy(IN p_name VARCHAR(100))
BEGIN
	delete from sells where ph_name = p_name;
  DELETE FROM Pharmacy WHERE name=p_name;
END;//
DELIMITER //



-- Contracts



CREATE PROCEDURE add_contract(
  IN p_ph_name VARCHAR(100),
  IN p_comp VARCHAR(100), IN p_start DATE, IN p_end DATE,
  IN p_content TEXT, IN p_supervisor VARCHAR(100))
BEGIN
  INSERT INTO Contract
    VALUES(p_ph_name,p_comp,p_start,p_end,p_content,p_supervisor);
END;//
DELIMITER //


CREATE PROCEDURE update_contract(
  IN p_ph_name VARCHAR(100), IN p_comp VARCHAR(100),
  IN p_start DATE, IN p_end DATE, IN p_supervisor VARCHAR(100))
BEGIN
  UPDATE Contract
    SET  supervisor=p_supervisor
    WHERE ph_name=p_ph_name
      AND ph_comp_name=p_comp
      AND start_date=p_start
      and end_date = p_end;
END;//
DELIMITER //


CREATE PROCEDURE delete_contract(
  IN p_ph_name VARCHAR(100), IN p_comp VARCHAR(100), IN p_start DATE,IN p_end DATE)
BEGIN
  DELETE FROM Contract
    WHERE ph_name=p_ph_name
      AND ph_comp_name=p_comp
      AND start_date=p_start
      AND end_date = p_end;
END;//
DELIMITER //


-- Prescriptions (header + contents)


CREATE PROCEDURE add_prescription(
  IN p_doc VARCHAR(12),
  IN p_patient VARCHAR(12),
  IN p_date DATE
)
BEGIN
  DECLARE old_date DATE;

  -- Ensure the doctor-patient pair exists in the cures table
  IF EXISTS (
    SELECT 1 FROM cures
    WHERE D_aadhar = p_doc AND P_aadhar = p_patient
  ) THEN

    -- Fetch the previous prescription date (if any)
    SELECT date INTO old_date
    FROM Prescription
    WHERE doc_id = p_doc AND patient_id = p_patient;

    -- Insert/update only if no entry or new date is more recent
    IF old_date IS NULL OR p_date > old_date THEN
      DELETE FROM prescription_content
      WHERE doc_id = p_doc AND patient_id = p_patient;

      DELETE FROM Prescription
      WHERE doc_id = p_doc AND patient_id = p_patient;

      INSERT INTO Prescription(doc_id, patient_id, date)
      VALUES(p_doc, p_patient, p_date);
    END IF;

  ELSE
    -- Raise error if not found in cures
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Doctor-Patient pair not found in cures table.';
  END IF;
END //
DELIMITER //



CREATE PROCEDURE add_prescription_content(
  IN p_doc VARCHAR(12), IN p_patient VARCHAR(12),
  IN p_trade VARCHAR(100), IN p_comp VARCHAR(100), IN p_quantity INT)
BEGIN
  INSERT INTO Prescription_Content VALUES(p_doc,p_patient,p_trade,p_comp,p_quantity) ;
END;//

DELIMITER //


CREATE PROCEDURE delete_prescription(
  IN p_doc VARCHAR(12), IN p_patient VARCHAR(12))
BEGIN
    delete from prescription_content where doc_id = p_doc and patient_id=p_patient;
  DELETE FROM Prescription
    WHERE doc_id=p_doc
      AND patient_id=p_patient;
END;//
DELIMITER //


CREATE PROCEDURE update_prescription_date(
  IN p_doc VARCHAR(12), IN p_patient VARCHAR(12),
  IN p_old_date DATE, IN p_new_date DATE)
BEGIN
  UPDATE Prescription
    SET date=p_new_date
    WHERE doc_id=p_doc
      AND patient_id=p_patient
      AND date=p_old_date;
END;//



