-- BioAcoustica's onomatopoeia and imitations, from the Drupal database, for
-- audioBLAST!'s onomatopoeia table (see getHeaders("onomatopoeia") in
-- audioBlastIngest): the words a human language renders an animal's sound
-- with, such as bow-wow for a dog barking.
--
-- Each is an Onomatopoeia or Imitation node, identified by its node id, and
-- the word itself is the node's title. The kind of rendering it is is the
-- site's own word (imitation, onomatopoeia verb, mnemonic or musical
-- notation); audioBlastIngest reads the term each kind names, as it does a
-- description's topic.
--
-- The taxon whose sound is rendered, and the reference the rendering was taken
-- from, are links (see links.sql), so they are not columns here. A rendering
-- is about its taxon rather than denoting it: "bark" names the sound a dog
-- makes, not the dog, so unlike a vernacular name it is never read onto the
-- taxon as a name for it.
--
-- The body is what the site says about a rendering, and holds what the fields
-- have no column for: the sex or life stage it belongs to, the people who use
-- it, and remarks. onomatopoeia.R reads those out and drops the column.

SELECT n.nid AS id,
  n.title AS word,
  ty.field_onomatopoeia_type_value AS kind,
  la.field_onomatopoeia_language_value AS language,
  b.body_value AS body,
  CONCAT('https://bio.acousti.ca/node/', n.nid) AS info_url
FROM node n
LEFT JOIN field_data_field_onomatopoeia_type ty
  ON ty.entity_type = 'node' AND ty.entity_id = n.nid AND ty.deleted = 0
  AND ty.language IN (n.language, 'und')
LEFT JOIN field_data_field_onomatopoeia_language la
  ON la.entity_type = 'node' AND la.entity_id = n.nid AND la.deleted = 0
  AND la.language IN (n.language, 'und')
LEFT JOIN field_data_body b
  ON b.entity_type = 'node' AND b.entity_id = n.nid AND b.deleted = 0
  AND b.language IN (n.language, 'und')
WHERE n.type = 'onomatopoeia_or_imitation' AND n.status = 1
  AND TRIM(COALESCE(n.title, '')) <> ''
ORDER BY n.nid
