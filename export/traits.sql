-- BioAcoustica's bioacoustic traits, from the Drupal database, for audioBLAST!'s
-- traits table (see getHeaders("traits") in audioBlastIngest). A trait value is
-- an item of the field_bioacoustic_traits collection on a traits node, and the
-- traitID is the item's id, which is what links to references and taxa point at.
--
-- One row is given for each item. A traits node can carry several taxa, and the
-- old export repeated the item once for each of them, which gave 108 rows that
-- shared a traitID and so overwrote each other on upload. The taxon here is the
-- node's first; every taxon of every item is in links.sql.
--
-- The trait itself is a term of the site's Bioacoustics ontology vocabulary,
-- whose ontology link traits.R repairs. Reference is left empty, as which
-- reference a value came from is a link (see links.sql).

SELECT fci.item_id AS traitID,
  MAX(tn.field_taxonomic_name_tid) AS taxonID,
  MAX(tx.name) AS taxon,
  MAX(t.name) AS trait,
  MAX(ol.field_ontology_link_value) AS ontology_link,
  MAX(v.field_value_value) AS `value`,
  MAX(ct.field_call_type_value) AS call_type,
  MAX(sx.field_sex_trait_value) AS sex,
  MAX(tp.field_temperature_value) AS temperature,
  MAX(cd.field_cascade_down_value) AS `cascade`,
  MAX(ai.field_annotation_id_value) AS annotation_id,
  COUNT(DISTINCT tnall.field_taxonomic_name_tid) AS taxa
FROM field_collection_item fci
JOIN field_data_field_bioacoustic_traits h
  ON h.field_bioacoustic_traits_value = fci.item_id AND h.entity_type = 'node' AND h.deleted = 0
JOIN node n ON n.nid = h.entity_id AND n.type = 'bioacoustic_traits' AND n.status = 1
LEFT JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = n.nid AND tn.deleted = 0 AND tn.delta = 0
LEFT JOIN taxonomy_term_data tx ON tx.tid = tn.field_taxonomic_name_tid
LEFT JOIN field_data_field_taxonomic_name tnall
  ON tnall.entity_type = 'node' AND tnall.entity_id = n.nid AND tnall.deleted = 0
LEFT JOIN field_data_field_trait ft
  ON ft.entity_type = 'field_collection_item' AND ft.entity_id = fci.item_id AND ft.deleted = 0 AND ft.delta = 0
LEFT JOIN taxonomy_term_data t ON t.tid = ft.field_trait_tid
LEFT JOIN field_data_field_ontology_link ol
  ON ol.entity_type = 'taxonomy_term' AND ol.entity_id = t.tid AND ol.deleted = 0 AND ol.delta = 0
LEFT JOIN field_data_field_value v
  ON v.entity_type = 'field_collection_item' AND v.entity_id = fci.item_id AND v.deleted = 0 AND v.delta = 0
LEFT JOIN field_data_field_call_type ct
  ON ct.entity_type = 'field_collection_item' AND ct.entity_id = fci.item_id AND ct.deleted = 0 AND ct.delta = 0
LEFT JOIN field_data_field_sex_trait sx
  ON sx.entity_type = 'field_collection_item' AND sx.entity_id = fci.item_id AND sx.deleted = 0 AND sx.delta = 0
LEFT JOIN field_data_field_temperature tp
  ON tp.entity_type = 'field_collection_item' AND tp.entity_id = fci.item_id AND tp.deleted = 0 AND tp.delta = 0
LEFT JOIN field_data_field_cascade_down cd
  ON cd.entity_type = 'field_collection_item' AND cd.entity_id = fci.item_id AND cd.deleted = 0 AND cd.delta = 0
LEFT JOIN field_data_field_annotation_id ai
  ON ai.entity_type = 'field_collection_item' AND ai.entity_id = fci.item_id AND ai.deleted = 0 AND ai.delta = 0
WHERE fci.field_name = 'field_bioacoustic_traits' AND fci.archived = 0
GROUP BY fci.item_id
ORDER BY fci.item_id
