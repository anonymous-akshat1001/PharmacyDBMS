
-- DUMMY DATA

CALL add_patientwithdoctor('P100','Akshat','74 Golf Club Road',21,
                            'D100','Dr. Agrawal', 12);
CALL add_patientwithdoctor('P200','Pranshu'  ,'45 Howrah Av',50,
                            'D200','Dr. Maheswari' ,20);

-- Doctor D300 will link to both patients (rule: every doctor must have ≥1 pt)
CALL add_doctor('D300','Dr. Jain','ENT',8,'P100');
CALL adddoctorpatient('P200','D300');

CALL update_doctor('D300','Dr. Rishav Jain',9);

CALL add_pharma_company('Cipla Ltd','9836446112');
CALL add_pharma_company('Sun Pharma','8318968984');

-- 14 drugs  =  enough to seed two pharmacies with ≥10 each
CALL add_drug('Drug01','Cipla Ltd','F101'); 
CALL add_drug('Drug02','Cipla Ltd','F102');
CALL add_drug('Drug03','Cipla Ltd','F103'); 
CALL add_drug('Drug04','Cipla Ltd','F104');
CALL add_drug('Drug05','Cipla Ltd','F105'); 
CALL add_drug('Drug06','Cipla Ltd','F106');
CALL add_drug('Drug07','Cipla Ltd','F107'); 
CALL add_drug('Drug08','Cipla Ltd','F108');
CALL add_drug('Drug09','Cipla Ltd','F109'); 
CALL add_drug('Drug10','Cipla Ltd','F110');
CALL add_drug('Drug11','Sun Pharma','F111'); 
CALL add_drug('Drug12','Sun Pharma','F112');
CALL add_drug('Drug13','Sun Pharma','F113'); 
CALL add_drug('Drug14','Sun Pharma','F114');

CALL add_pharmacy('Nova Pharmacy - Hyderabad','Hitech City','9965701264');
CALL add_pharmacy('Nova Pharmacy - Kolkata','Tollygunge','9081905627');
































-- load 10 items into each pharmacy (min‑10 rule)
START TRANSACTION;
  CALL update_stocks('Drug01','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);  
  CALL update_stocks('Drug02','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);
  CALL update_stocks('Drug03','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);  
  CALL update_stocks('Drug04','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);
  CALL update_stocks('Drug05','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50); 
  CALL update_stocks('Drug06','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);
  CALL update_stocks('Drug07','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50); 
  CALL update_stocks('Drug08','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);
  CALL update_stocks('Drug09','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);  
  CALL update_stocks('Drug10','Cipla Ltd','Nova Pharmacy - Hyderabad',1000.0,50);
COMMIT;

START TRANSACTION;
  CALL update_stocks('Drug11','Sun Pharma','Nova Pharmacy - Kolkata',2000.0,60);  
  CALL update_stocks('Drug12','Sun Pharma','Nova Pharmacy - Kolkata',2000.0,60);
  CALL update_stocks('Drug13','Sun Pharma','Nova Pharmacy - Kolkata',2000.0,60);  
  CALL update_stocks('Drug14','Sun Pharma','Nova Pharmacy - Kolkata',2000.0,60);
  CALL update_stocks('Drug01','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);  
  CALL update_stocks('Drug02','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);
  CALL update_stocks('Drug03','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);  
  CALL update_stocks('Drug04','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);
  CALL update_stocks('Drug05','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);  
  CALL update_stocks('Drug06','Cipla Ltd','Nova Pharmacy - Kolkata',2000.0,60);
COMMIT;

-- prescriptions
CALL add_prescription('D100','P100','2025-04-01');
CALL add_prescription_content('D100','P100','Drug01','Cipla Ltd',10);
CALL add_prescription_content('D100','P100','Drug02','Cipla Ltd', 5);
CALL add_prescription('D300','P100','2025-05-01');
CALL add_prescription_content('D300','P100','Drug01','Cipla Ltd',10);
CALL add_prescription_content('D300','P100','Drug02','Cipla Ltd', 5);
































-- contract
CALL add_contract('Nova Pharmacy - Hyderabad','Cipla Ltd','2025-01-01','2026-01-01',
                  'bulk supply','Supervisor1');



-- CALLING THE PROCEDURES : 



-- All the prescribed drugs within the time period
CALL report_patient_prescriptions_period('P100','2025-04-01','2025-05-30');

-- Prescription for a patient on a given date
CALL print_prescription_details_by_date('P100','2025-04-01');

-- Lists all the drugs produced by the Company
CALL list_drugs_by_company('Cipla Ltd');

-- Gets the stock of drugs sold by Pharmacy
CALL print_pharmacy_stock_position('Nova Pharmacy - Hyderabad');

-- Gets the address and contact details
CALL print_pharmacy_company_contact('Nova Pharmacy - Hyderabad','Cipla Ltd');

-- Gets the contract
CALL print_contract('Nova Pharmacy - Hyderabad','Cipla Ltd');

-- Gets all the pateints for the input doctor
CALL print_patients_of_doctor('D300');



