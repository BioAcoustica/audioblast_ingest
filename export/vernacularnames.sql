-- BioAcoustica's vernacular names, from the Drupal database, for audioBLAST!'s
-- vernacularnames table (see getHeaders("vernacularnames") in
-- audioBlastIngest): the names a taxon is known by in a language, in columns
-- named after the Darwin Core terms for them.
--
-- A vernacular name is a Vernacular Name field collection item of a term of
-- the site's Classification vocabulary, and is identified by the id of that
-- item, as a trait value is. The taxon a name is for and the reference it was
-- taken from are links (see links.sql), so they are not columns here.
--
-- Each of these fields holds one value for an item, so they are joined rather
-- than grouped, and a field collection item has no language of its own for
-- their rows to be taken in. An item with no name is left out, as is one whose
-- term is gone: a name with nothing to name, or nothing left to name it.

SELECT
  i.item_id AS id,
  vn.field_vernacular_name_value AS vernacularName,
  l.field_language_value AS language,
  loc.field_vernacular_locality_value AS locality,
  rem.field_vernacular_name_remarks_value AS remarks
FROM field_collection_item i
JOIN field_data_field_vernacular_name_collection c
  ON c.field_vernacular_name_collection_value = i.item_id
  AND c.entity_type = 'taxonomy_term' AND c.deleted = 0
JOIN taxonomy_term_data t ON t.tid = c.entity_id
JOIN field_data_field_vernacular_name vn
  ON vn.entity_type = 'field_collection_item' AND vn.entity_id = i.item_id AND vn.deleted = 0
  AND TRIM(vn.field_vernacular_name_value) <> ''
LEFT JOIN field_data_field_language l
  ON l.entity_type = 'field_collection_item' AND l.entity_id = i.item_id AND l.deleted = 0
LEFT JOIN field_data_field_vernacular_locality loc
  ON loc.entity_type = 'field_collection_item' AND loc.entity_id = i.item_id AND loc.deleted = 0
LEFT JOIN field_data_field_vernacular_name_remarks rem
  ON rem.entity_type = 'field_collection_item' AND rem.entity_id = i.item_id AND rem.deleted = 0
WHERE i.field_name = 'field_vernacular_name_collection' AND i.archived = 0
ORDER BY c.entity_id, c.delta
