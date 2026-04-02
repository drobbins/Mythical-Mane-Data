CREATE TABLE "Universe" (
  "UniverseID" bigserial,
  "Name" VARCHAR,
  PRIMARY KEY ("UniverseID")
);

CREATE TABLE "Owner" (
  "OwnerID" bigserial,
  "Name" VARCHAR,
  "Phone" VARCHAR,
  "Email" VARCHAR,
  "Address" VARCHAR,
  "UniverseID" bigint,
  PRIMARY KEY ("OwnerID"),
  CONSTRAINT "FK_Owner_UniverseID"
    FOREIGN KEY ("UniverseID")
      REFERENCES "Universe"("UniverseID")
);

CREATE TABLE "Patient" (
  "PatientID" bigserial,
  "DOB" DATE,
  "Name" VARCHAR,
  "Color" VARCHAR,
  "OwnerID" bigint,
  "SpeciesID" bigint,
  "BreedID" bigint,
  "UniverseID" bigint,
  PRIMARY KEY ("PatientID"),
  CONSTRAINT "FK_Patient_UniverseID"
    FOREIGN KEY ("UniverseID")
      REFERENCES "Universe"("UniverseID"),
  CONSTRAINT "FK_Patient_OwnerID"
    FOREIGN KEY ("OwnerID")
      REFERENCES "Owner"("OwnerID")
);

CREATE TABLE "Visit" (
  "VisitID" bigserial,
  "PatientID" bigint,
  "StartDateTime" DATETIME,
  "EndDateTime" DATETIME,
  "Reason" VARCHAR,
  "VetID" bigint,
  PRIMARY KEY ("VisitID"),
  CONSTRAINT "FK_Visit_PatientID"
    FOREIGN KEY ("PatientID")
      REFERENCES "Patient"("PatientID")
);

CREATE TABLE "Diagnosis" (
  "DiagnosisID" bigserial,
  "Name" VARCHAR,
  "Description" VARCHAR,
  "Code" VARCHAR,
  PRIMARY KEY ("DiagnosisID")
);

CREATE TABLE "VisitDiagnosis" (
  "VisitDiagnosisID" bigserial,
  "VisitID" bigint,
  "DiagnosisID" bigint,
  "EmployeeID" bigint,
  "Timestamp" DATETIME,
  PRIMARY KEY ("VisitDiagnosisID"),
  CONSTRAINT "FK_VisitDiagnosis_VisitID"
    FOREIGN KEY ("VisitID")
      REFERENCES "Visit"("VisitID"),
  CONSTRAINT "FK_VisitDiagnosis_DiagnosisID"
    FOREIGN KEY ("DiagnosisID")
      REFERENCES "Diagnosis"("DiagnosisID")
);

CREATE TABLE "Employee" (
  "EmployeeID" bigserial,
  "Name R" VARCHAR,
  "Role R" VARCHAR?,
  "Specialty" VARCHAR?,
  "HireDate R" DATE,
  "Phone R" VARCHAR,
  "Email R" VARCHAR,
  "Schedule" VARCHAR,
  PRIMARY KEY ("EmployeeID")
);

CREATE TABLE "Procedure" (
  "ProcedureID" bigserial,
  "Name" VARCHAR,
  "Description" VARCHAR,
  "StandardCost" DECIMAL,
  PRIMARY KEY ("ProcedureID")
);

CREATE TABLE "VisitProcedure" (
  "VisitProcedureID" bigserial,
  "VisitID" bigint,
  "ProcedureID" bigint,
  "EmployeeID" bigint,
  "Timestamp" DATETIME,
  PRIMARY KEY ("VisitProcedureID"),
  CONSTRAINT "FK_VisitProcedure_EmployeeID"
    FOREIGN KEY ("EmployeeID")
      REFERENCES "Employee"("EmployeeID"),
  CONSTRAINT "FK_VisitProcedure_VisitID"
    FOREIGN KEY ("VisitID")
      REFERENCES "Visit"("VisitID"),
  CONSTRAINT "FK_VisitProcedure_ProcedureID"
    FOREIGN KEY ("ProcedureID")
      REFERENCES "Procedure"("ProcedureID")
);

CREATE TABLE "Observation" (
  "ObservationID" bigserial,
  "VisitProcedureID" bigint,
  "Type" VARCHAR,
  "Value" DECIMAL,
  "Unit" VARCHAR,
  "Description" TEXT,
  PRIMARY KEY ("ObservationID"),
  CONSTRAINT "FK_Observation_VisitProcedureID"
    FOREIGN KEY ("VisitProcedureID")
      REFERENCES "VisitProcedure"("VisitProcedureID")
);

CREATE TABLE "Ability" (
  "AbilityID" bigserial,
  "Name" VARCHAR,
  "Type" VARCHAR,
  PRIMARY KEY ("AbilityID")
);

CREATE TABLE "PatientAbility" (
  "PatientAbilityID" bigserial,
  "PatientID" bigint,
  "AbilityID" bigint,
  PRIMARY KEY ("PatientAbilityID"),
  CONSTRAINT "FK_PatientAbility_AbilityID"
    FOREIGN KEY ("AbilityID")
      REFERENCES "Ability"("AbilityID"),
  CONSTRAINT "FK_PatientAbility_PatientID"
    FOREIGN KEY ("PatientID")
      REFERENCES "Patient"("PatientID")
);

CREATE TABLE "Invoice" (
  "InvoiceID" bigserial,
  "VisitID" bigint,
  "Status R" VARCHAR,
  "DueDate" DATE,
  "IssueDate R" DATE,
  PRIMARY KEY ("InvoiceID"),
  CONSTRAINT "FK_Invoice_VisitID"
    FOREIGN KEY ("VisitID")
      REFERENCES "Visit"("VisitID")
);

CREATE TABLE "LineItemID" (
  "LineItemID" bigserial,
  "InvoiceID R" INT,
  "Type R" VARCHAR,
  "VisitProcedureID" bigint,
  "MedicationID" bigint,
  "VaccinationID" bigint,
  "BoardingStayID" bigint,
  PRIMARY KEY ("LineItemID"),
  CONSTRAINT "FK_LineItemID_InvoiceID R"
    FOREIGN KEY ("InvoiceID R")
      REFERENCES "Invoice"("InvoiceID"),
  CONSTRAINT "FK_LineItemID_VisitProcedureID"
    FOREIGN KEY ("VisitProcedureID")
      REFERENCES "VisitProcedure"("VisitProcedureID")
);

CREATE TABLE "Payment" (
  "PaymentID" bigserial,
  "InvoiceID" bigint,
  "Date R" DATE,
  "Amount R" DECIMAL,
  "Method R" VARCHAR,
  PRIMARY KEY ("PaymentID"),
  CONSTRAINT "FK_Payment_InvoiceID"
    FOREIGN KEY ("InvoiceID")
      REFERENCES "Invoice"("InvoiceID")
);