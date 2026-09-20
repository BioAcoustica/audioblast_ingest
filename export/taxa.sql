-- BioAcoustica's classification, from the Drupal database, for audioBLAST!'s
-- taxa table (see getHeaders("taxa") in audioBlastIngest). A taxon is a term
-- of the site's Classification vocabulary, identified by its term id, which is
-- what recordings, traits, specimens and references link to.
--
-- A Scratchpads taxon name is held as up to four unit names (e.g. genus,
-- subgenus, species and subspecies), and the term's own name is those units
-- joined. The name is given here as the term holds it and the units as their
-- parts; taxa.R tidies the whitespace in both, which is all that they differ
-- by. A taxon's parent is its place in the classification, and is 0 for the
-- two roots.
--
-- A few fields have a row for the term's language and another for none, with
-- the same value in both (no term's rows disagree), so each field is taken
-- once for the term rather than joined twice.

SELECT t.tid AS id, MAX(t.name) AS taxon,
  MAX(u1.field_unit_name1_value) AS unit1,
  MAX(u2.field_unit_name2_value) AS unit2,
  MAX(u3.field_unit_name3_value) AS unit3,
  MAX(u4.field_unit_name4_value) AS unit4,
  MAX(r.field_rank_value) AS `rank`,
  h.parent AS parent_id,
  MAX(p.name) AS parent_taxon
FROM taxonomy_term_data t
JOIN taxonomy_term_hierarchy h ON h.tid = t.tid
LEFT JOIN taxonomy_term_data p ON p.tid = h.parent
LEFT JOIN field_data_field_unit_name1 u1
  ON u1.entity_type = 'taxonomy_term' AND u1.entity_id = t.tid AND u1.deleted = 0
  AND u1.delta = 0 AND u1.language IN (t.language, 'und')
LEFT JOIN field_data_field_unit_name2 u2
  ON u2.entity_type = 'taxonomy_term' AND u2.entity_id = t.tid AND u2.deleted = 0
  AND u2.delta = 0 AND u2.language IN (t.language, 'und')
LEFT JOIN field_data_field_unit_name3 u3
  ON u3.entity_type = 'taxonomy_term' AND u3.entity_id = t.tid AND u3.deleted = 0
  AND u3.delta = 0 AND u3.language IN (t.language, 'und')
LEFT JOIN field_data_field_unit_name4 u4
  ON u4.entity_type = 'taxonomy_term' AND u4.entity_id = t.tid AND u4.deleted = 0
  AND u4.delta = 0 AND u4.language IN (t.language, 'und')
LEFT JOIN field_data_field_rank r
  ON r.entity_type = 'taxonomy_term' AND r.entity_id = t.tid AND r.deleted = 0
  AND r.delta = 0 AND r.language IN (t.language, 'und')
WHERE t.vid = 4
GROUP BY t.tid, h.parent
ORDER BY t.tid
