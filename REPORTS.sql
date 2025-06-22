-- ███████████████████████████████████████████████████████████████████████████
-- THE REPORTING PROCEDURES
-- ███████████████████████████████████████████████████████████████████████████
DELIMITER //

-- 1. Prescriptions of a patient in a given period

CREATE PROCEDURE report_patient_prescriptions_period(
  IN in_patient_id VARCHAR(12),
  IN in_start_date DATE,
  IN in_end_date   DATE
)
BEGIN
  SELECT
    p.date            AS prescription_date,
    d.name            AS doctor_name,
    pc.trade_name,
    pc.ph_comp_name,
    pc.quantity
  FROM Prescription p
  JOIN Prescription_Content pc
    ON p.doc_id      = pc.doc_id
   AND p.patient_id  = pc.patient_id
  JOIN Doctor d
    ON p.doc_id      = d.aadhar_id
  WHERE p.patient_id = in_patient_id
    AND p.date       BETWEEN in_start_date AND in_end_date
  ORDER BY p.date;
END;//
DELIMITER //


-- 2. Details of a prescription for a given patient & date


CREATE PROCEDURE print_prescription_details_by_date(
  IN in_patient_id VARCHAR(12),
  IN in_presc_date DATE
)
BEGIN
  SELECT
    p.date            AS prescription_date,
    d.name            AS doctor_name,
    pc.trade_name,
    pc.ph_comp_name,
    dr.formula,
    pc.quantity
  FROM Prescription p
  JOIN Prescription_Content pc
    ON p.doc_id      = pc.doc_id
   AND p.patient_id  = pc.patient_id
  JOIN Doctor d
    ON p.doc_id      = d.aadhar_id
  JOIN Drug dr
    ON pc.trade_name   = dr.trade_name
   AND pc.ph_comp_name = dr.ph_comp_name
  WHERE p.patient_id = in_patient_id
    AND p.date       = in_presc_date;
END;//
DELIMITER //


-- 3. Drugs produced by a pharmaceutical company


CREATE PROCEDURE list_drugs_by_company(
  IN in_company VARCHAR(100)
)
BEGIN
  SELECT
    trade_name,
    formula
  FROM Drug
  WHERE ph_comp_name = in_company;
END;//
DELIMITER //


-- 4. Stock position of a pharmacy


CREATE PROCEDURE print_pharmacy_stock_position(
  IN in_pharmacy_name VARCHAR(100)
)
BEGIN
  SELECT
    s.trade_name,
    s.ph_comp_name,
    d.formula,
    s.price,
    s.quantity
  FROM Sells s
  JOIN Drug d
    ON s.trade_name   = d.trade_name
   AND s.ph_comp_name = d.ph_comp_name
  WHERE s.ph_name = in_pharmacy_name;
END;//
DELIMITER //


-- 5. Contact details of a pharmacy ↔ pharma company


CREATE PROCEDURE print_pharmacy_company_contact(
  IN in_pharmacy VARCHAR(100),
  IN in_company  VARCHAR(100)
)
BEGIN
  SELECT
    ph.name    AS pharmacy_name,
    ph.address AS pharmacy_address,
    ph.phone   AS pharmacy_phone,
    pc.name    AS company_name,
    pc.phone   AS company_phone
  FROM Pharmacy ph
  JOIN Pharma_Company pc
    ON pc.name = in_company
  WHERE ph.name = in_pharmacy;
END;//
DELIMITER //



-- 6. List of patients for a given doctor


CREATE PROCEDURE print_patients_of_doctor(
  IN in_doctor_id VARCHAR(12)
)
BEGIN
  SELECT
    p.aadhar_id,
    p.name,
    p.address,
    p.age
  FROM cures c
  JOIN patient p ON c.P_aadhar = p.aadhar_id
  WHERE c.D_aadhar = in_doctor_id;
END;//
DELIMITER //


-- Update the stocks

CREATE PROCEDURE update_stocks(
    IN p_trade     VARCHAR(100),
    IN p_comp      VARCHAR(100),
    IN p_pharmacy  VARCHAR(100),
    IN p_price     DECIMAL(10,2),
    IN p_quantity  INT
)
BEGIN
    /* add new line or tweak price / quantity */
    INSERT INTO Sells (trade_name, ph_comp_name, ph_name, price, quantity)
    VALUES (p_trade, p_comp, p_pharmacy, p_price, p_quantity)
    ON DUPLICATE KEY UPDATE
        price    = VALUES(price),
        quantity = VALUES(quantity);
END;
//
DROP TRIGGER IF EXISTS trg_sells_min10_before_delete;
DELIMITER //



-- Trigger when the number of drugs sold by the Pharmacy is less than 10 


CREATE TRIGGER trg_sells_min10_before_delete
BEFORE DELETE ON Sells
FOR EACH ROW
BEGIN
    DECLARE drug_cnt INT;

    /* rows that still exist before this DELETE fires */
    SELECT COUNT(*) INTO drug_cnt
    FROM Sells
    WHERE ph_name = OLD.ph_name;

    /* if only 10 remain, deleting one would leave 9 → block it */
    IF drug_cnt <= 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: A pharmacy must stock at least 10 different drugs.';
    END IF;
END;
//

DELIMITER //


-- Printing Contract between Pharmacy and Pharma Company

CREATE PROCEDURE print_contract(
  IN pharmaname VARCHAR(100),
  IN pharmacompany VARCHAR(100)
)
BEGIN
  SELECT * 
  FROM Contract
  WHERE ph_name = pharmaname AND ph_comp_name = pharmacompany;
END //

