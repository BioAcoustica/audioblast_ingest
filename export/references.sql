-- BioAcoustica's bibliography, from the Drupal Biblio module's tables, in the
-- columns of audioBLAST!'s references table (see getHeaders("references") in
-- audioBlastIngest). There is a row for each published reference. One (At Home
-- With Wild Nature, 1922) could only be viewed by the members of a group, but
-- that was only because it was added to the private Brazil Project group.
--
-- Values are as BioAcoustica holds them: titles, abstracts and notes are HTML,
-- and names are as they were entered, either "Surname, First" or "First
-- Surname", except that corporate names are in braces, as in BibTeX (e.g.
-- "{Colorado State University}"). audioBlastIngest converts them when it reads
-- the file. Names and keywords are separated by semicolons. Attachments are
-- added by references.R.

SELECT
  n.nid AS id,
  CASE b.biblio_type
    WHEN 100 THEN 'book'
    WHEN 101 THEN 'inbook'
    WHEN 102 THEN 'article'
    WHEN 103 THEN 'inproceedings'
    WHEN 104 THEN 'proceedings'
    WHEN 108 THEN IF(b.biblio_type_of_work REGEXP 'master|msc', 'mastersthesis', 'phdthesis')
    WHEN 109 THEN 'techreport'
    WHEN 124 THEN 'unpublished'
    ELSE 'misc'
  END AS type,
  n.title,
  -- Authors (including corporate authors), then editors, in the order given
  (SELECT GROUP_CONCAT(IF(c.auth_type = 5 OR cd.literal = 1, CONCAT('{', cd.name, '}'), cd.name)
                       ORDER BY c.`rank` SEPARATOR '; ')
     FROM biblio_contributor c JOIN biblio_contributor_data cd ON cd.cid = c.cid
    WHERE c.vid = n.vid AND c.auth_category IN (1, 5) AND c.auth_type <> 14) AS author,
  (SELECT GROUP_CONCAT(IF(c.auth_type = 5 OR cd.literal = 1, CONCAT('{', cd.name, '}'), cd.name)
                       ORDER BY c.`rank` SEPARATOR '; ')
     FROM biblio_contributor c JOIN biblio_contributor_data cd ON cd.cid = c.cid
    WHERE c.vid = n.vid AND (c.auth_category = 2 OR c.auth_type = 14)) AS editor,
  b.biblio_year AS year,
  -- Only the year of publication is given: most of Biblio's dates were
  -- garbled when they were imported from CrossRef
  NULL AS month,
  -- Biblio's secondary title is a series, book, conference, or department,
  -- or else a journal, depending on the type of reference
  CASE WHEN b.biblio_type IN (100, 101, 103, 104, 108, 109, 114) THEN NULL
    ELSE b.biblio_secondary_title END AS journal,
  CASE WHEN b.biblio_type IN (101, 103, 104) THEN b.biblio_secondary_title END AS booktitle,
  CASE WHEN b.biblio_type IN (100, 109, 114) THEN b.biblio_secondary_title
    ELSE b.biblio_tertiary_title END AS series,
  NULL AS howpublished,
  b.biblio_volume AS volume,
  COALESCE(NULLIF(b.biblio_issue, ''), b.biblio_number) AS number,
  -- CrossRef imports put the first page of journal articles in Biblio's
  -- section, so it only stands in for pages that are missing
  CASE WHEN b.biblio_type = 102 AND IFNULL(b.biblio_pages, '') = '' THEN b.biblio_section
    ELSE b.biblio_pages END AS pages,
  CASE WHEN b.biblio_type <> 102 THEN b.biblio_section END AS chapter,
  b.biblio_edition AS edition,
  CASE WHEN b.biblio_type NOT IN (108, 109) THEN b.biblio_publisher END AS publisher,
  NULL AS organization,
  CASE WHEN b.biblio_type = 109 THEN b.biblio_publisher END AS institution,
  CASE WHEN b.biblio_type = 108
    THEN CONCAT_WS(', ', NULLIF(b.biblio_secondary_title, ''), NULLIF(b.biblio_publisher, '')) END AS school,
  b.biblio_place_published AS address,
  b.biblio_type_of_work AS type_of_work,
  CONCAT_WS('\n\n', NULLIF(b.biblio_notes, ''), NULLIF(body.body_value, '')) AS note,
  b.biblio_isbn AS isbn,
  b.biblio_issn AS issn,
  b.biblio_doi AS doi,
  b.biblio_url AS url,
  NULL AS attachments,
  (SELECT GROUP_CONCAT(kd.word ORDER BY kd.word SEPARATOR '; ')
     FROM biblio_keyword k JOIN biblio_keyword_data kd ON kd.kid = k.kid
    WHERE k.vid = n.vid) AS keywords,
  b.biblio_abst_e AS abstract,
  t.name AS type_name,
  COALESCE(NULLIF(b.biblio_short_title, ''), b.biblio_alternate_title) AS journal_abbreviation,
  p.biblio_pubmed_id AS pmid,
  CONCAT('https://bio.acousti.ca/node/', n.nid) AS info_url
FROM node n
JOIN biblio b ON b.vid = n.vid
JOIN biblio_types t ON t.tid = b.biblio_type
LEFT JOIN field_data_body body
  ON body.entity_type = 'node' AND body.entity_id = n.nid AND body.deleted = 0 AND body.delta = 0
LEFT JOIN biblio_pubmed p ON p.nid = n.nid
WHERE n.type = 'biblio' AND n.status = 1
ORDER BY n.nid
