insert into patient (dob, name, color, owner_id, species_id, breed_id, universe_id)
select
  date '2014-01-01' + ((gs * 37) % 3650),
  (array['Bella', 'Max', 'Luna', 'Charlie', 'Lucy', 'Milo', 'Daisy', 'Cooper', 'Sadie', 'Rocky', 'Cleo', 'Toby'])[((gs - 1) % 12) + 1]
    || ' '
    || lpad(gs::text, 3, '0'),
  (array['Black', 'White', 'Golden', 'Brown', 'Gray', 'Tabby', 'Calico', 'Cream'])[((gs - 1) % 8) + 1],
  o.owner_id,
  ((gs - 1) % 4) + 1,
  ((gs - 1) % 12) + 1,
  o.universe_id
from generate_series(1, 60) as gs
join owner as o
  on o.owner_id = ((gs - 1) % 36) + 1;

insert into diagnosis (name, description, code)
values
  ('Annual Wellness Exam', 'Routine preventive examination', 'DX100'),
  ('Otitis Externa', 'External ear infection', 'DX110'),
  ('Dental Disease', 'Plaque and periodontal disease', 'DX120'),
  ('Dermatitis', 'Skin irritation or allergy response', 'DX130'),
  ('Arthritis', 'Chronic joint inflammation', 'DX140'),
  ('Gastroenteritis', 'Digestive upset with vomiting or diarrhea', 'DX150'),
  ('Upper Respiratory Infection', 'Respiratory inflammation and congestion', 'DX160'),
  ('Obesity', 'Excess body weight requiring management', 'DX170'),
  ('Laceration', 'Soft tissue wound requiring treatment', 'DX180'),
  ('Parasite Exposure', 'Possible flea, tick, or intestinal parasite issue', 'DX190'),
  ('Vaccination Follow-up', 'Expected post-vaccine recheck', 'DX200'),
  ('Post-Op Recheck', 'Follow-up after surgery or procedure', 'DX210');

insert into procedure_definition (name, description, standard_cost)
values
  ('Physical Exam', 'Full physical exam with vitals', 65.00),
  ('Vaccination', 'Routine vaccine administration', 42.50),
  ('Ear Cleaning', 'Diagnostic cleaning and topical treatment', 58.00),
  ('Dental Cleaning', 'Dental prophylaxis under anesthesia', 285.00),
  ('Skin Cytology', 'Microscopic review of skin sample', 72.00),
  ('Radiograph', 'Diagnostic x-ray imaging', 145.00),
  ('Blood Panel', 'Comprehensive in-house lab panel', 110.00),
  ('Wound Repair', 'Treatment and closure of soft tissue wound', 210.00),
  ('Nail Trim', 'Routine grooming nail trim', 24.00),
  ('Post-Op Check', 'Procedure recovery and incision evaluation', 55.00);

insert into ability (name, ability_type)
values
  ('Sit', 'Trick'),
  ('Stay', 'Trick'),
  ('Fetch', 'Trick'),
  ('Roll Over', 'Trick'),
  ('Heel', 'Training'),
  ('Leash Walking', 'Training'),
  ('Crate Trained', 'Behavior'),
  ('Medication Tolerant', 'Behavior'),
  ('Agility Basics', 'Sport'),
  ('Dock Diving', 'Sport'),
  ('Litter Box Trained', 'Behavior'),
  ('Harness Trained', 'Training');

insert into patient_ability (patient_id, ability_id)
select patient_id, ((patient_id - 1) % 12) + 1
from patient;

insert into patient_ability (patient_id, ability_id)
select patient_id, ((patient_id + 4) % 12) + 1
from patient
where patient_id % 3 <> 0;

insert into visit (patient_id, start_at, end_at, reason, vet_id)
select
  ((gs - 1) % 60) + 1,
  timestamptz '2025-01-02 08:00:00+00' + ((gs - 1) * interval '18 hours'),
  timestamptz '2025-01-02 08:45:00+00' + ((gs - 1) * interval '18 hours'),
  (array[
    'Annual wellness visit',
    'Vaccination booster',
    'Ear irritation',
    'Skin rash',
    'Dental consult',
    'Limping evaluation',
    'Follow-up after procedure',
    'Digestive upset',
    'Weight management check',
    'New patient intake'
  ])[((gs - 1) % 10) + 1],
  ((gs - 1) % 4) + 1
from generate_series(1, 120) as gs;

insert into visit_diagnosis (visit_id, diagnosis_id, employee_id, recorded_at)
select
  v.visit_id,
  ((v.visit_id - 1) % 12) + 1,
  v.vet_id,
  v.start_at + interval '20 minutes'
from visit as v;

insert into visit_procedure (visit_id, procedure_id, employee_id, performed_at)
select
  v.visit_id,
  ((v.visit_id - 1) % 10) + 1,
  case
    when v.visit_id % 2 = 0 then 5
    else v.vet_id
  end,
  v.start_at + interval '35 minutes'
from visit as v;

insert into visit_procedure (visit_id, procedure_id, employee_id, performed_at)
select
  v.visit_id,
  ((v.visit_id + 3) % 10) + 1,
  6,
  v.start_at + interval '70 minutes'
from visit as v
where v.visit_id % 4 = 0;

insert into observation (visit_procedure_id, observation_type, observed_value, unit, description)
select
  vp.visit_procedure_id,
  case vp.visit_procedure_id % 3
    when 0 then 'temperature'
    when 1 then 'weight'
    else 'heart_rate'
  end,
  case vp.visit_procedure_id % 3
    when 0 then round((100.0 + ((vp.visit_procedure_id % 8) * 0.3))::numeric, 2)
    when 1 then round((12.0 + ((vp.visit_procedure_id % 40) * 1.4))::numeric, 2)
    else round((80.0 + ((vp.visit_procedure_id % 35) * 2.0))::numeric, 2)
  end,
  case vp.visit_procedure_id % 3
    when 0 then 'F'
    when 1 then 'lb'
    else 'bpm'
  end,
  case vp.visit_procedure_id % 3
    when 0 then 'Recorded during intake exam'
    when 1 then 'Updated body weight after exam'
    else 'Pulse captured during procedure prep'
  end
from visit_procedure as vp;

insert into invoice (visit_id, status, due_date, issue_date)
select
  v.visit_id,
  case v.visit_id % 4
    when 0 then 'paid'
    when 1 then 'paid'
    when 2 then 'partial'
    else 'open'
  end,
  (v.start_at at time zone 'UTC')::date + 30,
  (v.start_at at time zone 'UTC')::date
from visit as v;

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'procedure',
  vp.visit_procedure_id,
  null,
  null,
  null
from invoice as i
join visit_procedure as vp
  on vp.visit_id = i.visit_id;

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'medication',
  null,
  1000 + i.invoice_id,
  null,
  null
from invoice as i
where i.invoice_id % 5 = 0;

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'vaccination',
  null,
  null,
  2000 + i.invoice_id,
  null
from invoice as i
where i.invoice_id % 8 = 0;

insert into payment (invoice_id, payment_date, amount, payment_method)
select
  i.invoice_id,
  i.issue_date + 1,
  case
    when i.status = 'paid' then round((95.00 + ((i.invoice_id % 9) * 18.75))::numeric, 2)
    else round((45.00 + ((i.invoice_id % 6) * 12.50))::numeric, 2)
  end,
  case i.invoice_id % 3
    when 0 then 'Credit Card'
    when 1 then 'Cash'
    else 'Debit Card'
  end
from invoice as i
where i.status in ('paid', 'partial');