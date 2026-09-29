-- The recordings that are not BioAcoustica's to share, which the exports leave
-- out altogether: the recordings themselves, their details and their links.
--
-- These are the recordings of the Macaulay Library project: copies of the
-- Macaulay Library's own recordings, titled with its catalogue numbers (e.g.
-- ML 47481), which the site holds with no licence and does not show the
-- public. A recording is withheld by its project rather than by its title or
-- id, so that one added to the project later is withheld with the others.

SELECT DISTINCT p.entity_id AS id
FROM field_data_field_project p
JOIN taxonomy_term_data t ON t.tid = p.field_project_tid
WHERE p.entity_type = 'node' AND p.bundle = 'recording' AND p.deleted = 0
  AND t.name = 'Macaulay Library'
ORDER BY id
