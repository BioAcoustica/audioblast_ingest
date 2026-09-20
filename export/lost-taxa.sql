-- The records that name a taxon the classification no longer holds, for the
-- exports to say so rather than lose it in silence. Every export reaches a
-- taxon's name through taxonomy_term_data, and links.sql links only to taxa
-- that still exist, so a term deleted from the site takes the name and the
-- link with it and leaves the record holding nothing but a term id.
--
-- Records are named and identified as links.sql names and identifies them.
-- One row is one record and one taxon it has lost, however many rows the site
-- holds for it: a reference tagged with a term in fourteen languages has lost
-- one taxon, not fourteen. Each record is found under the conditions of the
-- export it belongs to, so that only taxa the exports would have given are
-- counted.

-- The taxa that specimens are identified as
SELECT 'specimens' AS type, tn.entity_id AS id, tn.field_taxonomic_name_tid AS tid
FROM field_data_field_taxonomic_name tn
JOIN node n ON n.nid = tn.entity_id AND n.type = 'specimen_observation' AND n.status = 1
LEFT JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE tn.entity_type = 'node' AND tn.deleted = 0 AND t.tid IS NULL

UNION

-- The species of recordings that have a sound file, which are the recordings
-- that recordings.sql exports
SELECT 'recordings', s.entity_id, s.field_species_tid
FROM field_data_field_species s
JOIN node n ON n.nid = s.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
LEFT JOIN taxonomy_term_data t ON t.tid = s.field_species_tid
WHERE s.entity_type = 'node' AND s.deleted = 0 AND t.tid IS NULL

UNION

-- The taxa of the traits node a trait value belongs to. traits.sql names only
-- the first of them, so a value can lose its name here, its link in
-- links.sql, or both
SELECT 'traits', h.field_bioacoustic_traits_value, tn.field_taxonomic_name_tid
FROM field_data_field_bioacoustic_traits h
JOIN node n ON n.nid = h.entity_id AND n.status = 1
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = h.entity_id AND tn.deleted = 0
LEFT JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE h.entity_type = 'node' AND h.deleted = 0 AND t.tid IS NULL

UNION

-- The taxa that references are tagged with
SELECT 'references', tn.entity_id, tn.field_taxonomic_name_tid
FROM field_data_field_taxonomic_name tn
JOIN node n ON n.nid = tn.entity_id AND n.type = 'biblio' AND n.status = 1
LEFT JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE tn.entity_type = 'node' AND tn.deleted = 0 AND t.tid IS NULL

UNION

-- The taxa named by a reference's Contents, each of which is an oscillogram, a
-- song description or some other thing the reference holds about that taxon
SELECT 'references', c.entity_id, tn.field_taxonomic_name_tid
FROM field_data_field_contents c
JOIN node n ON n.nid = c.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'field_collection_item' AND tn.entity_id = c.field_contents_value
     AND tn.deleted = 0
LEFT JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE c.entity_type = 'node' AND c.deleted = 0 AND t.tid IS NULL

UNION

-- The taxa that references treat, which the site holds the other way round,
-- as a Reference on the classification term itself
SELECT 'references', f.field_reference_nid, f.entity_id
FROM field_data_field_reference f
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
LEFT JOIN taxonomy_term_data t ON t.tid = f.entity_id
WHERE f.entity_type = 'taxonomy_term' AND f.deleted = 0 AND t.tid IS NULL

ORDER BY type, id, tid
