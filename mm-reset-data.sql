begin;

truncate table
  universe,
  owner,
  employee,
  patient,
  visit,
  diagnosis,
  visit_diagnosis,
  procedure_definition,
  visit_procedure,
  observation,
  ability,
  patient_ability,
  invoice,
  line_item,
  payment
restart identity cascade;

commit;