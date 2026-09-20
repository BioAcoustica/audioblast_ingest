-- Links between BioAcoustica's records, from the Drupal database, for
-- audioBLAST!'s links table (see getHeaders("links") in audioBlastIngest).
-- Records are identified by their type (data module) and their id at
-- bio.acousti.ca: references and recordings by node id, traits by the id of
-- their field collection item (the traitID of traits.txt) and taxa by term id.
-- Only links between published nodes, and to taxa that still exist, are given.
-- References, recordings and trait values are all about taxa (IAO "is about"),
-- so everything about a taxon can be found by one predicate.
--
-- What a reference contains (content) and its topics are given as Drupal term
-- ids; links.R replaces them with the vocab.audioblast.org terms for them.
-- Each row says which kind of link it is, so that links.R can qualify the
-- references that are tagged with a taxon and those the classification cites.

-- References about taxa: the taxa that papers are tagged with
SELECT 'references' AS subject_type, tn.entity_id AS subject_id,
  'http://purl.obolibrary.org/obo/IAO_0000136' AS predicate,
  'taxa' AS object_type, tn.field_taxonomic_name_tid AS object_id,
  NULL AS content, NULL AS topic, NULL AS remarks, 'tagged' AS kind
FROM field_data_field_taxonomic_name tn
JOIN node n ON n.nid = tn.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE tn.entity_type = 'node' AND tn.deleted = 0

UNION ALL

-- What papers contain about taxa (their Contents: an oscillogram of a taxon,
-- a description of its song...)
SELECT 'references', c.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', tn.field_taxonomic_name_tid, bc.field_biblio_contents_tid, NULL, NULL, 'contents'
FROM field_data_field_contents c
JOIN node n ON n.nid = c.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN field_data_field_biblio_contents bc
  ON bc.entity_type = 'field_collection_item' AND bc.entity_id = c.field_contents_value AND bc.deleted = 0
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'field_collection_item' AND tn.entity_id = c.field_contents_value AND tn.deleted = 0
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE c.entity_type = 'node' AND c.deleted = 0

UNION ALL

-- Recordings of taxa (their species)
SELECT 'recordings', s.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', s.field_species_tid, NULL, NULL, NULL, 'recording'
FROM field_data_field_species s
JOIN node n ON n.nid = s.entity_id AND n.type = 'recording' AND n.status = 1
JOIN taxonomy_term_data t ON t.tid = s.field_species_tid
WHERE s.entity_type = 'node' AND s.deleted = 0

UNION ALL

-- Trait values of taxa: the taxa of the traits node that a value belongs to
SELECT 'traits', h.field_bioacoustic_traits_value, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', tn.field_taxonomic_name_tid, NULL, NULL, NULL, 'trait'
FROM field_data_field_bioacoustic_traits h
JOIN node n ON n.nid = h.entity_id AND n.status = 1
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = h.entity_id AND tn.deleted = 0
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE h.entity_type = 'node' AND h.deleted = 0

UNION ALL

-- Recordings published in references (e.g. on a CD, or in a paper)
SELECT 'recordings', r.entity_id, 'http://purl.org/dc/terms/isReferencedBy',
  'references', r.field_published_reference_nid, NULL, NULL, NULL, 'published'
FROM field_data_field_published_reference r
JOIN node n ON n.nid = r.entity_id AND n.type = 'recording' AND n.status = 1
JOIN node b ON b.nid = r.field_published_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE r.entity_type = 'node' AND r.deleted = 0

UNION ALL

-- Trait values taken from references
SELECT 'traits', f.entity_id, 'http://purl.org/dc/terms/source',
  'references', f.field_reference_nid, NULL, NULL, NULL, 'source'
FROM field_data_field_reference f
JOIN field_data_field_bioacoustic_traits h
  ON h.field_bioacoustic_traits_value = f.entity_id AND h.entity_type = 'node' AND h.deleted = 0
JOIN node n ON n.nid = h.entity_id AND n.status = 1
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE f.entity_type = 'field_collection_item' AND f.bundle = 'field_bioacoustic_traits' AND f.deleted = 0

UNION ALL

-- The reference a taxon's Classification entry gives, with the page where
-- given. The site calls that page the one the taxon was described on, but the
-- reference is filled in with whatever work treats the taxon: a revision, a
-- checklist, or a paper that only gives it an informal name ("tiny low
-- ticker"). It is therefore given as the reference being about the taxon, and
-- not as the name having been published in it.
SELECT 'references', f.field_reference_nid, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', f.entity_id, NULL, NULL, CONCAT('p. ', p.field_page_number_value), 'classification'
FROM field_data_field_reference f
JOIN taxonomy_term_data t ON t.tid = f.entity_id
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
LEFT JOIN field_data_field_page_number p
  ON p.entity_type = 'taxonomy_term' AND p.entity_id = f.entity_id AND p.deleted = 0
WHERE f.entity_type = 'taxonomy_term' AND f.deleted = 0

UNION ALL

-- References about topics (the site's Non-bio terms, e.g. Soundscapes)
SELECT 'references', f.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'term', NULL, NULL, f.field_non_biological_tid, NULL, 'topic'
FROM field_data_field_non_biological f
JOIN node n ON n.nid = f.entity_id AND n.type = 'biblio' AND n.status = 1
WHERE f.entity_type = 'node' AND f.deleted = 0
