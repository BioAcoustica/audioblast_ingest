-- What BioAcoustica's species profiles say about taxa, from the Drupal
-- database, for audioBLAST!'s descriptions table (see getHeaders("descriptions")
-- in audioBlastIngest). A species profile node has a field for each of the many
-- things such a profile can describe, and BioAcoustica fills four of them: how
-- a taxon behaves, and general, diagnostic and morphological descriptions of
-- it. Each of those is a description of its own.
--
-- A description is identified by the node it is on, and by the node and the
-- number of the description where a node makes more than one (12289 and
-- 12289.2), so that a description keeps its id however many a node gains.
--
-- The taxa a profile is about are given as term ids for links.R to make links
-- of, and descriptions.R drops them from the file. The text is as the site
-- holds it, HTML and [bib]12290[/bib] citations and all: audioBlastIngest
-- makes it plain text, and descriptions.R takes the citations out once links.R
-- has read them.

SELECT CASE WHEN d.n = 1 THEN d.node ELSE CONCAT(d.node, '.', d.n) END AS id,
  d.topic, d.value,
  CONCAT('https://bio.acousti.ca/node/', d.node) AS info_url,
  d.taxa
FROM (
  SELECT x.node, x.topic, x.value,
    ROW_NUMBER() OVER (PARTITION BY x.node ORDER BY x.topic) AS n,
    (SELECT GROUP_CONCAT(tn.field_taxonomic_name_tid ORDER BY tn.delta)
       FROM field_data_field_taxonomic_name tn
       JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
      WHERE tn.entity_type = 'node' AND tn.entity_id = x.node AND tn.deleted = 0) AS taxa
  FROM (
    SELECT DISTINCT u.node, u.topic, u.value FROM (
      SELECT n.nid AS node, 'behaviour' AS topic, b.field_behavious_value AS value
        FROM field_data_field_behavious b
        JOIN node n ON n.nid = b.entity_id AND n.type = 'spm' AND n.status = 1
          AND b.language IN (n.language, 'und')
       WHERE b.entity_type = 'node' AND b.deleted = 0
         AND TRIM(COALESCE(b.field_behavious_value, '')) <> ''
      UNION ALL
      SELECT n.nid, 'diagnostic', dd.field_diagnostic_description_value
        FROM field_data_field_diagnostic_description dd
        JOIN node n ON n.nid = dd.entity_id AND n.type = 'spm' AND n.status = 1
          AND dd.language IN (n.language, 'und')
       WHERE dd.entity_type = 'node' AND dd.deleted = 0
         AND TRIM(COALESCE(dd.field_diagnostic_description_value, '')) <> ''
      UNION ALL
      SELECT n.nid, 'general', g.field_general_description_value
        FROM field_data_field_general_description g
        JOIN node n ON n.nid = g.entity_id AND n.type = 'spm' AND n.status = 1
          AND g.language IN (n.language, 'und')
       WHERE g.entity_type = 'node' AND g.deleted = 0
         AND TRIM(COALESCE(g.field_general_description_value, '')) <> ''
      UNION ALL
      SELECT n.nid, 'morphology', m.field_morphology_value
        FROM field_data_field_morphology m
        JOIN node n ON n.nid = m.entity_id AND n.type = 'spm' AND n.status = 1
          AND m.language IN (n.language, 'und')
       WHERE m.entity_type = 'node' AND m.deleted = 0
         AND TRIM(COALESCE(m.field_morphology_value, '')) <> ''
    ) u
  ) x
) d
ORDER BY d.node, d.topic
