begin;

create temporary table seeded_universe on commit drop as
with src(name, seq_no) as (
  values
    ('Olympus Court', 1),
    ('Underworld Reach', 2),
    ('Faerie Wilds', 3)
),
ins as (
  insert into universe (name)
  select name
  from src
  returning universe_id, name
)
select src.seq_no, ins.universe_id, ins.name
from ins
join src using (name);

create temporary table seeded_employee on commit drop as
with src(name, job_role, specialty, hire_date, phone, email, schedule, seq_no) as (
  values
    ('Healer Lyra Dawnmantle', 'Veterinarian', 'General Practice', date '2019-03-15', '205-555-4101', 'lyra.dawnmantle@mm.example', 'Mon-Thu 8:00-17:00', 1),
    ('Healer Orion Stormvale', 'Veterinarian', 'Surgery', date '2018-07-09', '205-555-4102', 'orion.stormvale@mm.example', 'Tue-Fri 7:00-16:00', 2),
    ('Healer Thalia Starbrook', 'Veterinarian', 'Dermatology', date '2020-01-20', '205-555-4103', 'thalia.starbrook@mm.example', 'Mon-Fri 9:00-18:00', 3),
    ('Healer Cassian Emberwake', 'Veterinarian', 'Exotics', date '2021-05-03', '205-555-4104', 'cassian.emberwake@mm.example', 'Wed-Sat 8:00-17:00', 4),
    ('Astra Runebinder', 'Technician', 'Anesthesia', date '2022-02-14', '205-555-4105', 'astra.runebinder@mm.example', 'Mon-Fri 8:00-17:00', 5),
    ('Fen Hollowquill', 'Technician', 'Laboratory', date '2021-09-06', '205-555-4106', 'fen.hollowquill@mm.example', 'Tue-Sat 9:00-18:00', 6),
    ('Mira Goldleaf', 'Receptionist', null, date '2023-04-10', '205-555-4107', 'mira.goldleaf@mm.example', 'Mon-Fri 7:30-16:30', 7),
    ('Rowan Nightglass', 'Receptionist', null, date '2024-01-08', '205-555-4108', 'rowan.nightglass@mm.example', 'Mon-Fri 10:00-19:00', 8),
    ('Bram Gatekeeper', 'Office Manager', null, date '2017-11-27', '205-555-4109', 'bram.gatekeeper@mm.example', 'Mon-Fri 8:00-17:00', 9),
    ('Elowen Mossmere', 'Boarding Coordinator', 'Griffin Care', date '2022-06-01', '205-555-4110', 'elowen.mossmere@mm.example', 'Sun-Thu 6:00-15:00', 10)
),
ins as (
  insert into employee (name, job_role, specialty, hire_date, phone, email, schedule)
  select name, job_role, specialty, hire_date, phone, email, schedule
  from src
  returning employee_id, name
)
select src.seq_no, ins.employee_id, ins.name
from ins
join src using (name);

create temporary table seeded_owner on commit drop as
with src as (
  select
    gs as seq_no,
    (array[
      'Ariadne', 'Evander', 'Selene', 'Theron', 'Callista', 'Leander',
      'Nyx', 'Perseus', 'Cyra', 'Alaric', 'Ione', 'Dorian'
    ])[((gs - 1) % 12) + 1]
      || ' '
      || (array[
        'Mooncrest', 'Ashborne', 'Starseer', 'Vale', 'Thornfield', 'Silverkeep',
        'Duskwhisper', 'Brightspear', 'Embermere', 'Frosthelm', 'Willowshade', 'Ravenholt'
      ])[((gs - 1) % 12) + 1]
      || ' '
      || lpad(gs::text, 2, '0') as name,
    '205-555-' || lpad((4200 + gs)::text, 4, '0') as phone,
    'keeper' || lpad(gs::text, 3, '0') || '@mythic.example' as email,
    gs || ' Moonlit Causeway' as address,
    ((gs - 1) % 3) + 1 as universe_seq_no
  from generate_series(1, 36) as gs
),
ins as (
  insert into owner (name, phone, email, address, universe_id)
  select s.name, s.phone, s.email, s.address, u.universe_id
  from src as s
  join seeded_universe as u
    on u.seq_no = s.universe_seq_no
  returning owner_id, name
)
select src.seq_no, ins.owner_id, ins.name, src.universe_seq_no
from ins
join src using (name);

create temporary table seeded_patient on commit drop as
with src as (
  select
    gs as seq_no,
    date '2014-01-01' + ((gs * 37) % 3650) as dob,
    (array['Phoenix', 'Griffin', 'Kelpie', 'Cerberus', 'Pegasus', 'Sphinx', 'Basilisk', 'Chimera', 'Selkie', 'Dryad', 'Hippogriff', 'Manticore'])[((gs - 1) % 12) + 1]
      || ' '
      || lpad(gs::text, 3, '0') as name,
    (array['Ember', 'Moonwhite', 'Stormgray', 'Sun-gold', 'Mossgreen', 'Midnight', 'Silver', 'Cinder'])[((gs - 1) % 8) + 1] as color,
    ((gs - 1) % 36) + 1 as owner_seq_no,
    ((gs - 1) % 4) + 1 as species_id,
    ((gs - 1) % 12) + 1 as breed_id
  from generate_series(1, 60) as gs
),
ins as (
  insert into patient (dob, name, color, owner_id, species_id, breed_id, universe_id)
  select
    s.dob,
    s.name,
    s.color,
    o.owner_id,
    s.species_id,
    s.breed_id,
    u.universe_id
  from src as s
  join seeded_owner as o
    on o.seq_no = s.owner_seq_no
  join seeded_universe as u
    on u.seq_no = o.universe_seq_no
  returning patient_id, name
)
select src.seq_no, ins.patient_id, ins.name
from ins
join src using (name);

create temporary table seeded_diagnosis on commit drop as
with src(name, description, code, seq_no) as (
  values
    ('Aetheric Fatigue', 'Routine depletion of magical reserves', 'MY100', 1),
    ('Wing Membrane Tear', 'Minor tearing or irritation of wing tissue', 'MY110', 2),
    ('Scale Rot', 'Inflammation beneath damaged scales', 'MY120', 3),
    ('Moon Pollen Dermatitis', 'Skin irritation caused by enchanted pollen', 'MY130', 4),
    ('Hoofstone Arthritis', 'Chronic stiffness in enchanted joints', 'MY140', 5),
    ('Cauldron Belly', 'Digestive upset after ingesting unstable potions', 'MY150', 6),
    ('Frostbreath Congestion', 'Respiratory irritation after cold-magic exposure', 'MY160', 7),
    ('Overfed on Ambrosia', 'Excess weight requiring diet management', 'MY170', 8),
    ('Claw Laceration', 'Soft tissue wound from horn or talon', 'MY180', 9),
    ('Shadow Parasite Exposure', 'Possible infestation by spectral mites or worms', 'MY190', 10),
    ('Rune Vaccine Follow-up', 'Expected recheck after warding inoculation', 'MY200', 11),
    ('Post-Summoning Recheck', 'Follow-up after ritual or portal procedure', 'MY210', 12)
),
ins as (
  insert into diagnosis (name, description, code)
  select name, description, code
  from src
  returning diagnosis_id, code
)
select src.seq_no, ins.diagnosis_id, src.code
from ins
join src using (code);

create temporary table seeded_procedure on commit drop as
with src(name, description, standard_cost, seq_no) as (
  values
    ('Oracle Examination', 'Full physical exam with aura review', 65.00, 1),
    ('Ward Renewal', 'Routine protective charm administration', 42.50, 2),
    ('Feather and Scale Cleansing', 'Diagnostic cleaning with restorative balm', 58.00, 3),
    ('Fang Polishing', 'Dental prophylaxis under dream-sleep sedation', 285.00, 4),
    ('Rune Cytology', 'Microscopic review of skin or feather sample', 72.00, 5),
    ('Crystal Scryograph', 'Diagnostic imaging by mirrored crystal', 145.00, 6),
    ('Aether Blood Panel', 'Comprehensive in-house alchemical panel', 110.00, 7),
    ('Talon and Hide Repair', 'Treatment and closure of soft tissue wounds', 210.00, 8),
    ('Hoof and Claw Trim', 'Routine grooming trim', 24.00, 9),
    ('Post-Ritual Check', 'Recovery and incision evaluation after ritual care', 55.00, 10)
),
ins as (
  insert into procedure_definition (name, description, standard_cost)
  select name, description, standard_cost
  from src
  returning procedure_id, name
)
select src.seq_no, ins.procedure_id, ins.name
from ins
join src using (name);

create temporary table seeded_ability on commit drop as
with src(name, ability_type, seq_no) as (
  values
    ('Fire Breath', 'Trick', 1),
    ('Shadow Step', 'Trick', 2),
    ('Sky Dive', 'Trick', 3),
    ('Glamour Shift', 'Trick', 4),
    ('Runic Recall', 'Training', 5),
    ('Portal Walking', 'Training', 6),
    ('Stable in Starlight Pens', 'Behavior', 7),
    ('Potion Tolerant', 'Behavior', 8),
    ('Aerial Agility', 'Sport', 9),
    ('Cloud Racing', 'Sport', 10),
    ('Moonpool Trained', 'Behavior', 11),
    ('Harness of Hermes Trained', 'Training', 12)
),
ins as (
  insert into ability (name, ability_type)
  select name, ability_type
  from src
  returning ability_id, name
)
select src.seq_no, ins.ability_id, ins.name
from ins
join src using (name);

insert into patient_ability (patient_id, ability_id)
select p.patient_id, a.ability_id
from seeded_patient as p
join seeded_ability as a
  on a.seq_no = ((p.seq_no - 1) % 12) + 1;

insert into patient_ability (patient_id, ability_id)
select p.patient_id, a.ability_id
from seeded_patient as p
join seeded_ability as a
  on a.seq_no = ((p.seq_no + 4) % 12) + 1
where p.seq_no % 3 <> 0;

create temporary table seeded_visit on commit drop as
with src as (
  select
    gs as seq_no,
    ((gs - 1) % 60) + 1 as patient_seq_no,
    timestamptz '2025-01-02 08:00:00+00' + ((gs - 1) * interval '18 hours') as start_at,
    timestamptz '2025-01-02 08:45:00+00' + ((gs - 1) * interval '18 hours') as end_at,
    (array[
      'Annual oracle wellness visit',
      'Ward booster appointment',
      'Wing irritation and molt check',
      'Moon pollen rash evaluation',
      'Fang polishing consult',
      'Limp after chariot race',
      'Follow-up after ritual repair',
      'Potion-related digestive upset',
      'Ambrosia weight management check',
      'New familiar intake'
    ])[((gs - 1) % 10) + 1] as reason,
    ((gs - 1) % 4) + 1 as vet_seq_no
  from generate_series(1, 120) as gs
),
ins as (
  insert into visit (patient_id, start_at, end_at, reason, vet_id)
  select p.patient_id, s.start_at, s.end_at, s.reason, e.employee_id
  from src as s
  join seeded_patient as p
    on p.seq_no = s.patient_seq_no
  join seeded_employee as e
    on e.seq_no = s.vet_seq_no
  returning visit_id, start_at
)
select src.seq_no, ins.visit_id, src.patient_seq_no, src.vet_seq_no, src.start_at
from ins
join src using (start_at);

insert into visit_diagnosis (visit_id, diagnosis_id, employee_id, recorded_at)
select
  v.visit_id,
  d.diagnosis_id,
  e.employee_id,
  v.start_at + interval '20 minutes'
from seeded_visit as v
join seeded_diagnosis as d
  on d.seq_no = ((v.seq_no - 1) % 12) + 1
join seeded_employee as e
  on e.seq_no = v.vet_seq_no;

create temporary table seeded_visit_procedure on commit drop as
with primary_src as (
  select
    v.seq_no,
    v.visit_id,
    ((v.seq_no - 1) % 10) + 1 as procedure_seq_no,
    case when v.seq_no % 2 = 0 then 5 else v.vet_seq_no end as employee_seq_no,
    v.start_at + interval '35 minutes' as performed_at
  from seeded_visit as v
),
secondary_src as (
  select
    v.seq_no + 1000 as seq_no,
    v.visit_id,
    ((v.seq_no + 3) % 10) + 1 as procedure_seq_no,
    6 as employee_seq_no,
    v.start_at + interval '70 minutes' as performed_at
  from seeded_visit as v
  where v.seq_no % 4 = 0
),
src as (
  select * from primary_src
  union all
  select * from secondary_src
),
ins as (
  insert into visit_procedure (visit_id, procedure_id, employee_id, performed_at)
  select v.visit_id, p.procedure_id, e.employee_id, s.performed_at
  from src as s
  join seeded_visit as v
    on v.visit_id = s.visit_id
  join seeded_procedure as p
    on p.seq_no = s.procedure_seq_no
  join seeded_employee as e
    on e.seq_no = s.employee_seq_no
  returning visit_procedure_id, visit_id, performed_at
)
select src.seq_no, ins.visit_procedure_id, ins.visit_id, ins.performed_at
from ins
join src
  on src.visit_id = ins.visit_id
 and src.performed_at = ins.performed_at;

insert into observation (visit_procedure_id, observation_type, observed_value, unit, description)
select
  vp.visit_procedure_id,
  case vp.seq_no % 3
    when 0 then 'temperature'
    when 1 then 'weight'
    else 'heart_rate'
  end,
  case vp.seq_no % 3
    when 0 then round((100.0 + ((vp.seq_no % 8) * 0.3))::numeric, 2)
    when 1 then round((12.0 + ((vp.seq_no % 40) * 1.4))::numeric, 2)
    else round((80.0 + ((vp.seq_no % 35) * 2.0))::numeric, 2)
  end,
  case vp.seq_no % 3
    when 0 then 'F'
    when 1 then 'lb'
    else 'bpm'
  end,
  case vp.seq_no % 3
    when 0 then 'Recorded during aura intake exam'
    when 1 then 'Updated body weight after scrying'
    else 'Pulse captured during ritual preparation'
  end
from seeded_visit_procedure as vp;

create temporary table seeded_invoice on commit drop as
with src as (
  select
    v.seq_no,
    v.visit_id,
    case v.seq_no % 4
      when 0 then 'paid'
      when 1 then 'paid'
      when 2 then 'partial'
      else 'open'
    end as status,
    (v.start_at at time zone 'UTC')::date + 30 as due_date,
    (v.start_at at time zone 'UTC')::date as issue_date
  from seeded_visit as v
),
ins as (
  insert into invoice (visit_id, status, due_date, issue_date)
  select visit_id, status, due_date, issue_date
  from src
  returning invoice_id, visit_id
)
select src.seq_no, ins.invoice_id, ins.visit_id, src.status, src.issue_date
from ins
join src using (visit_id);

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'procedure',
  vp.visit_procedure_id,
  null,
  null,
  null
from seeded_invoice as i
join seeded_visit_procedure as vp
  on vp.visit_id = i.visit_id;

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'medication',
  null,
  1000 + i.seq_no,
  null,
  null
from seeded_invoice as i
where i.seq_no % 5 = 0;

insert into line_item (invoice_id, line_item_type, visit_procedure_id, medication_id, vaccination_id, boarding_stay_id)
select
  i.invoice_id,
  'vaccination',
  null,
  null,
  2000 + i.seq_no,
  null
from seeded_invoice as i
where i.seq_no % 8 = 0;

insert into payment (invoice_id, payment_date, amount, payment_method)
select
  i.invoice_id,
  i.issue_date + ((i.seq_no % 12) + 1),
  case
    when i.status = 'paid' then round((95.00 + ((i.seq_no % 9) * 18.75))::numeric, 2)
    else round((45.00 + ((i.seq_no % 6) * 12.50))::numeric, 2)
  end,
  case i.seq_no % 3
    when 0 then 'Rune Card'
    when 1 then 'Gold Coin'
    else 'Temple Ledger'
  end
from seeded_invoice as i
where i.status in ('paid', 'partial');

commit;
