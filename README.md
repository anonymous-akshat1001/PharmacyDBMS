# PharmacyDBMS
Design and implement a Relational database for a chain of pharmacies that sells drugs produced by different Pharmaceutical Companies


# Additional Information and Constraints : 

We assume a scenario where “NOVA” is a chain of pharmacies that sells drugs produced by different Pharmaceutical Companies. We are to design and implement a Relational database for Nova to capture the following information related to- Pharmacies under Nova, Pharmaceutical Companies that supply drugs to pharmacies of Nova, Patients, Doctors, Drugs at different pharmacies of Nova, Prescriptions from doctors to patients etc., as detailed below.
1. For each patient we store details- AadharID (unique), name, address, and age.
2. For doctors we need to store- AadharID (unique), name, specialty and years of experience.
3. Each pharmaceutical company is identified by name and has a phone-number.
4. For each drug we need to store the trade name and the formula. Each drug is sold by a given pharmaceutical company. The trade name identifies the drug uniquely among the drugs produced by that company. If a pharmaceutical company is deleted we don’t have to keep the details of the drugs of the company.
5. Each pharmacy has name, address and phone.
6. Each patient has a primary physician and every doctor has at least one patient.
7. each pharmacy sells several drugs (at least 10) and has price for each drug. A drug could be sold at several pharmacies, and the price of the same drug may vary from one pharmacy to other.
8. Doctors prescribe drugs for patients. A doctor could prescribe one or more drugs, for several patients. A patient can get prescription from several doctors. Each prescription has a date and quantity for each drug prescribed in it. If a doctor gives more than one prescription to a single patient, latest one need to be stored. Doctors give max one prescription to a given patient, on a given date.
9. Pharmaceutical companies have contracts with pharmacies. We store contract start date and end date and contract content, in database. Each pharmacy assigns a supervisor for each contract. And for a contract, supervisor can be changed.
