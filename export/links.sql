-- Links between BioAcoustica's records, from the Drupal database, for
-- audioBLAST!'s links table (see getHeaders("links") in audioBlastIngest).
-- Records are identified by their type (data module) and their id at
-- bio.acousti.ca: references, recordings, specimens and onomatopoeia by node
-- id, traits and vernacular names by the id of their field collection item
-- (for traits the traitID of traits.txt), images by file id and taxa by term
-- id. Only links between published nodes, and to taxa that still exist, are
-- given. References, recordings, trait values, specimens, images and
-- onomatopoeia are all about taxa (IAO "is about"), so everything about a
-- taxon can be found by one predicate; a vernacular name denotes its taxon,
-- which is a kind of being about it.
--
-- What a reference holds about a taxon (content, or a term named here), its
-- topics and how one taxon interacts with another are given as Drupal term ids
-- or term names; links.R replaces them with the vocab.audioblast.org terms for
-- them. A link that a reference established gives it, and audioBlastIngest
-- makes a link of that too, so that what established a relationship is said of
-- the relationship.

-- References about taxa: the taxa that papers are tagged with
SELECT 'references' AS subject_type, tn.entity_id AS subject_id,
  'http://purl.obolibrary.org/obo/IAO_0000136' AS predicate,
  'taxa' AS object_type, tn.field_taxonomic_name_tid AS object_id,
  NULL AS content, NULL AS topic, NULL AS remarks, NULL AS term, NULL AS reference, NULL AS interaction
FROM field_data_field_taxonomic_name tn
JOIN node n ON n.nid = tn.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE tn.entity_type = 'node' AND tn.deleted = 0

UNION ALL

-- What papers contain about taxa (their Contents: an oscillogram of a taxon,
-- a description of its song...)
SELECT 'references', c.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', tn.field_taxonomic_name_tid, bc.field_biblio_contents_tid, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_contents c
JOIN node n ON n.nid = c.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN field_data_field_biblio_contents bc
  ON bc.entity_type = 'field_collection_item' AND bc.entity_id = c.field_contents_value AND bc.deleted = 0
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'field_collection_item' AND tn.entity_id = c.field_contents_value AND tn.deleted = 0
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE c.entity_type = 'node' AND c.deleted = 0

UNION ALL

-- The references that treat a taxon. The Reference on a classification term
-- is any work treating it, from a revision to a checklist, and not only where
-- its name was published, so the link says that the reference is about the
-- taxon, with the page the term gives as its remarks.
SELECT 'references', f.field_reference_nid, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', f.entity_id, NULL, NULL,
  CONCAT('p. ', NULLIF(TRIM(p.field_page_number_value), '')), 'TaxonomicTreatment', NULL, NULL
FROM field_data_field_reference f
JOIN taxonomy_term_data t ON t.tid = f.entity_id
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
LEFT JOIN field_data_field_page_number p
  ON p.entity_type = 'taxonomy_term' AND p.entity_id = f.entity_id AND p.deleted = 0
WHERE f.entity_type = 'taxonomy_term' AND f.deleted = 0

UNION ALL

-- Recordings of taxa (their species)
SELECT 'recordings', s.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', s.field_species_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_species s
JOIN node n ON n.nid = s.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN taxonomy_term_data t ON t.tid = s.field_species_tid
WHERE s.entity_type = 'node' AND s.deleted = 0

UNION ALL

-- Recordings of specimens
SELECT 'recordings', sp.entity_id, 'http://rs.tdwg.org/ac/terms/associatedSpecimenReference',
  'specimens', sp.field_specimen_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_specimen sp
JOIN node n ON n.nid = sp.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN node s ON s.nid = sp.field_specimen_nid AND s.type = 'specimen_observation' AND s.status = 1
WHERE sp.entity_type = 'node' AND sp.deleted = 0

UNION ALL

-- The taxa that specimens are identified as
SELECT 'specimens', tn.entity_id, 'http://rs.tdwg.org/dwc/iri/toTaxon',
  'taxa', tn.field_taxonomic_name_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_taxonomic_name tn
JOIN node n ON n.nid = tn.entity_id AND n.type = 'specimen_observation' AND n.status = 1
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE tn.entity_type = 'node' AND tn.deleted = 0

UNION ALL

-- The taxa that specimens with no determination of their own were recorded as,
-- so that a specimen is related to the taxon that specimens.sql names it with.
-- The barcoding of the sound collection in the first half of 2017 left the
-- determination of over a thousand specimens on the recordings they were made
-- from, as specimens.sql says. A specimen keeps its own determination where it
-- has one; one whose term is gone has nothing to be related to, so it too is
-- taken from its recordings.
SELECT 'specimens', sp.field_specimen_nid, 'http://rs.tdwg.org/dwc/iri/toTaxon',
  'taxa', s.field_species_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_specimen sp
JOIN node n ON n.nid = sp.field_specimen_nid AND n.type = 'specimen_observation' AND n.status = 1
JOIN node rn ON rn.nid = sp.entity_id AND rn.type = 'recording' AND rn.status = 1
JOIN field_data_field_species s
  ON s.entity_type = 'node' AND s.entity_id = rn.nid AND s.deleted = 0
JOIN taxonomy_term_data t ON t.tid = s.field_species_tid
WHERE sp.entity_type = 'node' AND sp.deleted = 0
  AND NOT EXISTS (SELECT 1 FROM field_data_field_taxonomic_name tn
                    JOIN taxonomy_term_data tt ON tt.tid = tn.field_taxonomic_name_tid
                   WHERE tn.entity_type = 'node' AND tn.entity_id = n.nid
                     AND tn.deleted = 0)

UNION ALL

-- Specimens cited in references
SELECT 'specimens', c.entity_id, 'http://purl.org/dc/terms/isReferencedBy',
  'references', c.field_cited_in__nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_cited_in_ c
JOIN node n ON n.nid = c.entity_id AND n.type = 'specimen_observation' AND n.status = 1
JOIN node b ON b.nid = c.field_cited_in__nid AND b.type = 'biblio' AND b.status = 1
WHERE c.entity_type = 'node' AND c.deleted = 0

UNION ALL

-- Trait values of taxa: the taxa of the traits node that a value belongs to
SELECT 'traits', h.field_bioacoustic_traits_value, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', tn.field_taxonomic_name_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_bioacoustic_traits h
JOIN node n ON n.nid = h.entity_id AND n.status = 1
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = h.entity_id AND tn.deleted = 0
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE h.entity_type = 'node' AND h.deleted = 0

UNION ALL

-- Recordings published in references (e.g. on a CD, or in a paper)
SELECT 'recordings', r.entity_id, 'http://purl.org/dc/terms/isReferencedBy',
  'references', r.field_published_reference_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_published_reference r
JOIN node n ON n.nid = r.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN node b ON b.nid = r.field_published_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE r.entity_type = 'node' AND r.deleted = 0

UNION ALL

-- Trait values taken from references
SELECT 'traits', f.entity_id, 'http://purl.org/dc/terms/source',
  'references', f.field_reference_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_reference f
JOIN field_data_field_bioacoustic_traits h
  ON h.field_bioacoustic_traits_value = f.entity_id AND h.entity_type = 'node' AND h.deleted = 0
JOIN node n ON n.nid = h.entity_id AND n.status = 1
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE f.entity_type = 'field_collection_item' AND f.bundle = 'field_bioacoustic_traits' AND f.deleted = 0

UNION ALL

-- The places recordings were made. A place is described once, in
-- locations.sql, however many records were made or collected there.
SELECT 'recordings', l.entity_id, 'http://rs.tdwg.org/dwc/iri/inDescribedPlace',
  'locations', l.field_recording_location_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_recording_location l
JOIN node n ON n.nid = l.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN node p ON p.nid = l.field_recording_location_nid AND p.type = 'location' AND p.status = 1
WHERE l.entity_type = 'node' AND l.deleted = 0

UNION ALL

-- The places specimens were collected or observed
SELECT 'specimens', l.entity_id, 'http://rs.tdwg.org/dwc/iri/inDescribedPlace',
  'locations', l.field_location_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_location l
JOIN node n ON n.nid = l.entity_id AND n.type = 'specimen_observation' AND n.status = 1
JOIN node p ON p.nid = l.field_location_nid AND p.type = 'location' AND p.status = 1
WHERE l.entity_type = 'node' AND l.deleted = 0

UNION ALL

-- The taxa that vernacular names name. Darwin Core has no property that takes
-- a taxon for a vernacular name (dwc:vernacularName takes the name itself),
-- and dwc:relationshipOfResourceID asks for an OBO relation, so the predicate
-- is IAO "denotes": a name is made to pick out the thing it names, which is
-- what denotation is. It is a subproperty of IAO "is about", so a vernacular
-- name is still about its taxon, as everything else linked to one is.
--
-- A vernacular name is a Vernacular Name field collection item of a
-- classification term, identified by the id of that item, as
-- vernacularnames.sql gives it; one with no name, or whose term is gone, is
-- left out, as it is there.
SELECT 'vernacularnames', i.item_id, 'http://purl.obolibrary.org/obo/IAO_0000219',
  'taxa', c.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_collection_item i
JOIN field_data_field_vernacular_name_collection c
  ON c.field_vernacular_name_collection_value = i.item_id
  AND c.entity_type = 'taxonomy_term' AND c.deleted = 0
JOIN taxonomy_term_data t ON t.tid = c.entity_id
JOIN field_data_field_vernacular_name vn
  ON vn.entity_type = 'field_collection_item' AND vn.entity_id = i.item_id AND vn.deleted = 0
  AND TRIM(vn.field_vernacular_name_value) <> ''
WHERE i.field_name = 'field_vernacular_name_collection' AND i.archived = 0

UNION ALL

-- The references that vernacular names were taken from
SELECT 'vernacularnames', i.item_id, 'http://purl.org/dc/terms/source',
  'references', f.field_reference_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_collection_item i
JOIN field_data_field_vernacular_name_collection c
  ON c.field_vernacular_name_collection_value = i.item_id
  AND c.entity_type = 'taxonomy_term' AND c.deleted = 0
JOIN taxonomy_term_data t ON t.tid = c.entity_id
JOIN field_data_field_vernacular_name vn
  ON vn.entity_type = 'field_collection_item' AND vn.entity_id = i.item_id AND vn.deleted = 0
  AND TRIM(vn.field_vernacular_name_value) <> ''
JOIN field_data_field_reference f
  ON f.entity_type = 'field_collection_item' AND f.entity_id = i.item_id AND f.deleted = 0
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE i.field_name = 'field_vernacular_name_collection' AND i.archived = 0

UNION ALL

-- The taxa whose sounds onomatopoeia and imitations render. A rendering is
-- about its taxon rather than denoting it: "bark" picks out the sound a dog
-- makes, not the dog, and "Get the beer check" is a way of remembering a song
-- rather than anything the bird is called. Denoting is what a vernacular name
-- does and what reads a name onto its taxon, so being about the taxon is both
-- the true relation and what keeps these out of the names a taxon is known by.
SELECT 'onomatopoeia', n.nid, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', tn.field_taxonomic_name_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM node n
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = n.nid AND tn.deleted = 0
JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
WHERE n.type = 'onomatopoeia_or_imitation' AND n.status = 1
  AND TRIM(COALESCE(n.title, '')) <> ''

UNION ALL

-- The references that onomatopoeia and imitations were taken from
SELECT 'onomatopoeia', n.nid, 'http://purl.org/dc/terms/source',
  'references', f.field_reference_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM node n
JOIN field_data_field_reference f
  ON f.entity_type = 'node' AND f.entity_id = n.nid AND f.deleted = 0
JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE n.type = 'onomatopoeia_or_imitation' AND n.status = 1
  AND TRIM(COALESCE(n.title, '')) <> ''

UNION ALL

-- References about topics (the site's Non-bio terms, e.g. Soundscapes)
SELECT 'references', f.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'term', NULL, NULL, f.field_non_biological_tid, NULL, NULL, NULL, NULL
FROM field_data_field_non_biological f
JOIN node n ON n.nid = f.entity_id AND n.type = 'biblio' AND n.status = 1
WHERE f.entity_type = 'node' AND f.deleted = 0

UNION ALL

-- How one taxon interacts with another: the acoustically orientating predators
-- and parasites that find their prey and hosts by listening for them, and the
-- taxa that answer another's alarm call. An interaction node names the taxon
-- that acts and the reference it was read from, and the taxa acted upon are the
-- items of its collection. Both taxa are named as the site names them, which is
-- why they are not the interaction's own record: the relationship is all there
-- is to say.
SELECT 'taxa', tn.field_taxonomic_name_tid, 'placeholder',
  'taxa', otn.field_taxonomic_name_tid, NULL, NULL, NULL, NULL,
  f.field_reference_nid, it.name
FROM node n
JOIN field_data_field_taxonomic_name tn
  ON tn.entity_type = 'node' AND tn.entity_id = n.nid AND tn.deleted = 0 AND tn.delta = 0
JOIN taxonomy_term_data st ON st.tid = tn.field_taxonomic_name_tid
JOIN field_data_field_interaction_type ity
  ON ity.entity_type = 'node' AND ity.entity_id = n.nid AND ity.deleted = 0
JOIN taxonomy_term_data it ON it.tid = ity.field_interaction_type_tid
JOIN field_data_field_int_collection ic
  ON ic.entity_type = 'node' AND ic.entity_id = n.nid AND ic.deleted = 0
JOIN field_data_field_taxonomic_name otn
  ON otn.entity_type = 'field_collection_item' AND otn.entity_id = ic.field_int_collection_value
  AND otn.deleted = 0
JOIN taxonomy_term_data ot ON ot.tid = otn.field_taxonomic_name_tid
LEFT JOIN field_data_field_reference f
  ON f.entity_type = 'node' AND f.entity_id = n.nid AND f.deleted = 0
LEFT JOIN node b ON b.nid = f.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE n.type = 'ecological_interactions' AND n.status = 1

UNION ALL

-- The recordings whose original metadata sheets were scanned. A scan is
-- about the recording it documents, and one sheet often covers several
-- recordings, which is why the image is a record of its own (see images.sql)
-- rather than a value on each recording.
SELECT 'images', x.field_original_metadata_image_fid,
  'http://purl.obolibrary.org/obo/IAO_0000136',
  'recordings', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_original_metadata_image x
JOIN node n ON n.nid = x.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN file_managed f ON f.fid = x.field_original_metadata_image_fid
  AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The recordings whose paper oscillographic traces were scanned
SELECT 'images', x.field_original_trace_images_fid,
  'http://purl.obolibrary.org/obo/IAO_0000136',
  'recordings', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_original_trace_images x
JOIN node n ON n.nid = x.entity_id AND n.type = 'recording' AND n.status = 1
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
JOIN file_managed f ON f.fid = x.field_original_trace_images_fid
  AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The specimens that images show
SELECT 'images', x.field_media_fid,
  'http://rs.tdwg.org/ac/terms/associatedSpecimenReference',
  'specimens', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_media x
JOIN node n ON n.nid = x.entity_id AND n.type = 'specimen_observation' AND n.status = 1
JOIN file_managed f ON f.fid = x.field_media_fid AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The places that images were taken in
SELECT 'images', x.field_images_fid, 'http://rs.tdwg.org/dwc/iri/inDescribedPlace',
  'locations', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_images x
JOIN node n ON n.nid = x.entity_id AND n.type = 'location' AND n.status = 1
JOIN file_managed f ON f.fid = x.field_images_fid AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The species profiles that images illustrate. The object here is the profile
-- node, and links.R makes it the descriptions that descriptions.sql numbers
-- after that node, because a profile's figures illustrate everything it says.
SELECT 'images', x.field_media_fid, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'descriptions', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_media x
JOIN node n ON n.nid = x.entity_id AND n.type = 'spm' AND n.status = 1
JOIN file_managed f ON f.fid = x.field_media_fid AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The references that images were attached to
SELECT 'images', x.field_file_fid, 'http://purl.org/dc/terms/source',
  'references', x.entity_id, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_file x
JOIN node n ON n.nid = x.entity_id AND n.type = 'biblio' AND n.status = 1
JOIN file_managed f ON f.fid = x.field_file_fid AND f.type = 'image' AND f.status = 1
WHERE x.entity_type = 'node' AND x.deleted = 0

UNION ALL

-- The papers that figures were taken from. A file's fields have a row for
-- each of the site's fifteen interface languages, all saying the same thing,
-- so each value is taken once.
SELECT DISTINCT 'images', x.entity_id, 'http://purl.org/dc/terms/source',
  'references', x.field_reference_nid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_reference x
JOIN file_managed f ON f.fid = x.entity_id AND f.type = 'image' AND f.status = 1
JOIN node b ON b.nid = x.field_reference_nid AND b.type = 'biblio' AND b.status = 1
WHERE x.entity_type = 'file' AND x.deleted = 0

UNION ALL

-- The taxa that images show
SELECT DISTINCT 'images', x.entity_id, 'http://purl.obolibrary.org/obo/IAO_0000136',
  'taxa', x.field_taxonomic_name_tid, NULL, NULL, NULL, NULL, NULL, NULL
FROM field_data_field_taxonomic_name x
JOIN file_managed f ON f.fid = x.entity_id AND f.type = 'image' AND f.status = 1
JOIN taxonomy_term_data t ON t.tid = x.field_taxonomic_name_tid AND t.vid = 4
WHERE x.entity_type = 'file' AND x.deleted = 0
