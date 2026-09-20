-- BioAcoustica's images, from the Drupal database, for audioBLAST!'s images
-- table (see getHeaders("images") in audioBlastIngest). An image is a file
-- entity of type image, identified by its file id, and what it shows is
-- links (see links.sql), so that one scan shared by four recordings is
-- described once and linked four times.
--
-- Only the images that links.sql can link to something are exported: the
-- scans of the original metadata and traces of recordings that audioBLAST
-- holds, the media on a specimen, place, species profile or reference, and
-- the figures that name the taxon they show or the paper they came from.
-- The rest are images on comments, user pictures, and scans of recordings
-- whose sound the site never received, none of which audioBLAST has anything
-- to say about. The two sets of anchors must stay in step with links.sql, or
-- an image would be exported with no link or linked without being exported.
--
-- The site holds an image's licence, creator, caption, taxon and reference on
-- the file itself, once each. title is the name the site gives the file,
-- which for a figure taken from a paper is its legend and for a scan is the
-- name it was scanned under. file is the file's URI, which images.R makes a
-- URL of, and license is a Creative Commons licence type, which images.R
-- names.

SELECT f.fid AS id, f.filename AS title, f.uri AS file,
  -- What kind of image it is: the site's own imaging technique where it gives
  -- one, and otherwise the part the image plays where it is attached. The two
  -- meet on eight scans, seven of which the site also calls a Scan.
  COALESCE(tech.name,
           CASE WHEN a.metadata_scan THEN 'Original metadata scan'
                WHEN a.trace_scan THEN 'Original trace scan' END) AS subtype,
  cr.field_creator_value AS creator,
  cc.field_cc_licence_licence AS license,
  f.timestamp AS post_date,
  f.filemime AS type,
  f.filesize AS size_raw,
  dim.width AS width,
  dim.height AS height,
  cap.field_description_value AS caption
FROM (
  SELECT anchor.fid,
    MAX(anchor.metadata_scan) AS metadata_scan,
    MAX(anchor.trace_scan) AS trace_scan
  FROM (
    -- Scans of the sheet a recording's metadata was written on
    SELECT x.field_original_metadata_image_fid AS fid, 1 AS metadata_scan, 0 AS trace_scan
      FROM field_data_field_original_metadata_image x
      JOIN node n ON n.nid = x.entity_id AND n.type = 'recording' AND n.status = 1
      JOIN field_data_field_recording fr ON fr.entity_type = 'node' AND fr.entity_id = n.nid
        AND fr.deleted = 0 AND fr.delta = 0
     WHERE x.entity_type = 'node' AND x.deleted = 0
    UNION ALL
    -- Scans of the paper oscillographic traces made from a recording
    SELECT x.field_original_trace_images_fid, 0, 1
      FROM field_data_field_original_trace_images x
      JOIN node n ON n.nid = x.entity_id AND n.type = 'recording' AND n.status = 1
      JOIN field_data_field_recording fr ON fr.entity_type = 'node' AND fr.entity_id = n.nid
        AND fr.deleted = 0 AND fr.delta = 0
     WHERE x.entity_type = 'node' AND x.deleted = 0
    UNION ALL
    -- Media on a specimen or a species profile
    SELECT x.field_media_fid, 0, 0
      FROM field_data_field_media x
      JOIN node n ON n.nid = x.entity_id AND n.status = 1
        AND n.type IN ('specimen_observation', 'spm')
     WHERE x.entity_type = 'node' AND x.deleted = 0
    UNION ALL
    -- Images of a place
    SELECT x.field_images_fid, 0, 0
      FROM field_data_field_images x
      JOIN node n ON n.nid = x.entity_id AND n.status = 1 AND n.type = 'location'
     WHERE x.entity_type = 'node' AND x.deleted = 0
    UNION ALL
    -- Images attached to a reference
    SELECT x.field_file_fid, 0, 0
      FROM field_data_field_file x
      JOIN node n ON n.nid = x.entity_id AND n.status = 1 AND n.type = 'biblio'
     WHERE x.entity_type = 'node' AND x.deleted = 0
    UNION ALL
    -- Figures that name the taxon they show
    SELECT x.entity_id, 0, 0
      FROM field_data_field_taxonomic_name x
      JOIN taxonomy_term_data t ON t.tid = x.field_taxonomic_name_tid AND t.vid = 4
     WHERE x.entity_type = 'file' AND x.deleted = 0
    UNION ALL
    -- Figures that name the paper they came from
    SELECT x.entity_id, 0, 0
      FROM field_data_field_reference x
      JOIN node b ON b.nid = x.field_reference_nid AND b.type = 'biblio' AND b.status = 1
     WHERE x.entity_type = 'file' AND x.deleted = 0
  ) anchor
  GROUP BY anchor.fid
) a
JOIN file_managed f ON f.fid = a.fid AND f.type = 'image' AND f.status = 1
LEFT JOIN image_dimensions dim ON dim.fid = f.fid
LEFT JOIN field_data_field_cc_licence cc
  ON cc.entity_type = 'file' AND cc.entity_id = f.fid AND cc.deleted = 0 AND cc.delta = 0
LEFT JOIN field_data_field_creator cr
  ON cr.entity_type = 'file' AND cr.entity_id = f.fid AND cr.deleted = 0 AND cr.delta = 0
LEFT JOIN field_data_field_description cap
  ON cap.entity_type = 'file' AND cap.entity_id = f.fid AND cap.deleted = 0 AND cap.delta = 0
LEFT JOIN field_data_field_imaging_technique it
  ON it.entity_type = 'file' AND it.entity_id = f.fid AND it.deleted = 0 AND it.delta = 0
LEFT JOIN taxonomy_term_data tech ON tech.tid = it.field_imaging_technique_tid
ORDER BY f.fid
