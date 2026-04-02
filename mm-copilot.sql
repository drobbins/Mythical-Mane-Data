CREATE TABLE universe (
  universe_id BIGSERIAL PRIMARY KEY,
  name TEXT
);

CREATE TABLE owner (
  owner_id BIGSERIAL PRIMARY KEY,
  name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  universe_id BIGINT,
  CONSTRAINT fk_owner_universe_id
    FOREIGN KEY (universe_id)
      REFERENCES universe(universe_id)
);

CREATE TABLE patient (
  patient_id BIGSERIAL PRIMARY KEY,
  dob DATE,
  name TEXT,
  color TEXT,
  owner_id BIGINT,
  species_id BIGINT,
  breed_id BIGINT,
  universe_id BIGINT,
  CONSTRAINT fk_patient_universe_id
    FOREIGN KEY (universe_id)
      REFERENCES universe(universe_id),
  CONSTRAINT fk_patient_owner_id
    FOREIGN KEY (owner_id)
      REFERENCES owner(owner_id)
);

CREATE TABLE visit (
  visit_id BIGSERIAL PRIMARY KEY,
  patient_id BIGINT,
  start_datetime TIMESTAMPTZ,
  end_datetime TIMESTAMPTZ,
  reason TEXT,
  vet_id BIGINT,
  CONSTRAINT fk_visit_patient_id
    FOREIGN KEY (patient_id)
      REFERENCES patient(patient_id)
);

CREATE TABLE diagnosis (
  diagnosis_id BIGSERIAL PRIMARY KEY,
  name TEXT,
  description TEXT,
  code TEXT
);

CREATE TABLE visit_diagnosis (
  visit_diagnosis_id BIGSERIAL PRIMARY KEY,
  visit_id BIGINT,
  diagnosis_id BIGINT,
  employee_id BIGINT,
  recorded_at TIMESTAMPTZ,
  CONSTRAINT fk_visit_diagnosis_visit_id
    FOREIGN KEY (visit_id)
      REFERENCES visit(visit_id),
  CONSTRAINT fk_visit_diagnosis_diagnosis_id
    FOREIGN KEY (diagnosis_id)
      REFERENCES diagnosis(diagnosis_id)
);

CREATE TABLE employee (
  employee_id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  specialty TEXT,
  hire_date DATE NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  schedule TEXT
);

CREATE TABLE medical_procedure (
  procedure_id BIGSERIAL PRIMARY KEY,
  name TEXT,
  description TEXT,
  standard_cost NUMERIC
);

CREATE TABLE visit_procedure (
  visit_procedure_id BIGSERIAL PRIMARY KEY,
  visit_id BIGINT,
  procedure_id BIGINT,
  employee_id BIGINT,
  recorded_at TIMESTAMPTZ,
  CONSTRAINT fk_visit_procedure_employee_id
    FOREIGN KEY (employee_id)
      REFERENCES employee(employee_id),
  CONSTRAINT fk_visit_procedure_visit_id
    FOREIGN KEY (visit_id)
      REFERENCES visit(visit_id),
  CONSTRAINT fk_visit_procedure_procedure_id
    FOREIGN KEY (procedure_id)
      REFERENCES medical_procedure(procedure_id)
);

CREATE TABLE observation (
  observation_id BIGSERIAL PRIMARY KEY,
  visit_procedure_id BIGINT,
  type TEXT,
  value NUMERIC,
  unit TEXT,
  description TEXT,
  CONSTRAINT fk_observation_visit_procedure_id
    FOREIGN KEY (visit_procedure_id)
      REFERENCES visit_procedure(visit_procedure_id)
);

CREATE TABLE ability (
  ability_id BIGSERIAL PRIMARY KEY,
  name TEXT,
  type TEXT
);

CREATE TABLE patient_ability (
  patient_ability_id BIGSERIAL PRIMARY KEY,
  patient_id BIGINT,
  ability_id BIGINT,
  CONSTRAINT fk_patient_ability_ability_id
    FOREIGN KEY (ability_id)
      REFERENCES ability(ability_id),
  CONSTRAINT fk_patient_ability_patient_id
    FOREIGN KEY (patient_id)
      REFERENCES patient(patient_id)
);

CREATE TABLE invoice (
  invoice_id BIGSERIAL PRIMARY KEY,
  visit_id BIGINT,
  status TEXT NOT NULL,
  due_date DATE,
  issue_date DATE NOT NULL,
  CONSTRAINT fk_invoice_visit_id
    FOREIGN KEY (visit_id)
      REFERENCES visit(visit_id)
);

CREATE TABLE line_item (
  line_item_id BIGSERIAL PRIMARY KEY,
  invoice_id BIGINT NOT NULL,
  type TEXT NOT NULL,
  visit_procedure_id BIGINT,
  medication_id BIGINT,
  vaccination_id BIGINT,
  boarding_stay_id BIGINT,
  CONSTRAINT fk_line_item_invoice_id
    FOREIGN KEY (invoice_id)
      REFERENCES invoice(invoice_id),
  CONSTRAINT fk_line_item_visit_procedure_id
    FOREIGN KEY (visit_procedure_id)
      REFERENCES visit_procedure(visit_procedure_id)
);

CREATE TABLE payment (
  payment_id BIGSERIAL PRIMARY KEY,
  invoice_id BIGINT,
  payment_date DATE NOT NULL,
  amount NUMERIC NOT NULL,
  method TEXT NOT NULL,
  CONSTRAINT fk_payment_invoice_id
    FOREIGN KEY (invoice_id)
      REFERENCES invoice(invoice_id)
);
