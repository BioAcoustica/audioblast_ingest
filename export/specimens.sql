-- BioAcoustica's published specimens and observations, from the Drupal
-- database, in the columns of audioBLAST!'s specimens table (see
-- getHeaders("specimens") in audioBlastIngest). The columns are named after
-- the Darwin Core terms they hold.
--
-- The place is where the specimen was collected, which is not always where it
-- was recorded: recordings made in a laboratory give the laboratory. The
-- taxa a specimen is identified as, the recordings of it and the references
-- it is cited in are exported by links.R, and its collector number, field
-- number and field notes by details.R.

SELECT
  n.nid AS id,
  (SELECT GROUP_CONCAT(t.name ORDER BY tn.delta SEPARATOR '; ')
     FROM field_data_field_taxonomic_name tn
     JOIN taxonomy_term_data t ON t.tid = tn.field_taxonomic_name_tid
    WHERE tn.entity_type = 'node' AND tn.entity_id = n.nid AND tn.deleted = 0
      AND tn.language IN (n.language, 'und')) AS scientificName,
  bor.field_basis_of_record_value AS basisOfRecord,
  ic.field_institution_code_value AS institutionCode,
  cc.field_collection_code_value AS collectionCode,
  cn.field_catalogue_number_value AS catalogNumber,
  ocn.field_other_catalogue_numbers_value AS otherCatalogNumbers,
  ts.field_type_status_value AS typeStatus,
  sx.field_sex_value AS sex,
  ls.field_lifestage_value AS lifeStage,
  ct.field_count_value AS individualCount,
  (SELECT GROUP_CONCAT(TRIM(CONCAT_WS(' ', g.field_user_given_names_value, fn.field_user_family_name_value))
                       ORDER BY c.delta SEPARATOR '; ')
     FROM field_data_field_collector c
     LEFT JOIN field_data_field_user_given_names g
       ON g.entity_type = 'user' AND g.entity_id = c.field_collector_uid AND g.deleted = 0
     LEFT JOIN field_data_field_user_family_name fn
       ON fn.entity_type = 'user' AND fn.entity_id = c.field_collector_uid AND fn.deleted = 0
    WHERE c.entity_type = 'node' AND c.entity_id = n.nid AND c.deleted = 0
      AND c.language IN (n.language, 'und')) AS recordedBy,
  dc.field_date_collected_value AS eventDate,
  (SELECT GROUP_CONCAT(TRIM(CONCAT_WS(' ', g.field_user_given_names_value, fn.field_user_family_name_value))
                       ORDER BY i.delta SEPARATOR '; ')
     FROM field_data_field_identified_by i
     LEFT JOIN field_data_field_user_given_names g
       ON g.entity_type = 'user' AND g.entity_id = i.field_identified_by_uid AND g.deleted = 0
     LEFT JOIN field_data_field_user_family_name fn
       ON fn.entity_type = 'user' AND fn.entity_id = i.field_identified_by_uid AND fn.deleted = 0
    WHERE i.entity_type = 'node' AND i.entity_id = n.nid AND i.deleted = 0
      AND i.language IN (n.language, 'und')) AS identifiedBy,
  di.field_date_identified_value AS dateIdentified,
  iq.field_identification_qualifier_value AS identificationQualifier,
  (SELECT GROUP_CONCAT(gb.field_genbank_number_value ORDER BY gb.delta SEPARATOR '; ')
     FROM field_data_field_genbank_number gb
    WHERE gb.entity_type = 'node' AND gb.entity_id = n.nid AND gb.deleted = 0
      AND gb.language IN (n.language, 'und')) AS associatedSequences,
  lo.field_locality_value AS locality,
  co.field_country_iso2 AS countryCode,
  m.field_map_latitude AS decimalLatitude,
  m.field_map_longitude AS decimalLongitude,
  rm.field_remarks_value AS occurrenceRemarks,
  CONCAT('https://bio.acousti.ca/node/', n.nid) AS info_url
FROM node n
LEFT JOIN field_data_field_basis_of_record bor
  ON bor.entity_type = 'node' AND bor.entity_id = n.nid AND bor.deleted = 0
     AND bor.delta = 0 AND bor.language IN (n.language, 'und')
LEFT JOIN field_data_field_institution_code ic
  ON ic.entity_type = 'node' AND ic.entity_id = n.nid AND ic.deleted = 0
     AND ic.delta = 0 AND ic.language IN (n.language, 'und')
LEFT JOIN field_data_field_collection_code cc
  ON cc.entity_type = 'node' AND cc.entity_id = n.nid AND cc.deleted = 0
     AND cc.delta = 0 AND cc.language IN (n.language, 'und')
LEFT JOIN field_data_field_catalogue_number cn
  ON cn.entity_type = 'node' AND cn.entity_id = n.nid AND cn.deleted = 0
     AND cn.delta = 0 AND cn.language IN (n.language, 'und')
LEFT JOIN field_data_field_other_catalogue_numbers ocn
  ON ocn.entity_type = 'node' AND ocn.entity_id = n.nid AND ocn.deleted = 0
     AND ocn.delta = 0 AND ocn.language IN (n.language, 'und')
LEFT JOIN field_data_field_type_status ts
  ON ts.entity_type = 'node' AND ts.entity_id = n.nid AND ts.deleted = 0
     AND ts.delta = 0 AND ts.language IN (n.language, 'und')
LEFT JOIN field_data_field_sex sx
  ON sx.entity_type = 'node' AND sx.entity_id = n.nid AND sx.deleted = 0
     AND sx.delta = 0 AND sx.language IN (n.language, 'und')
LEFT JOIN field_data_field_lifestage ls
  ON ls.entity_type = 'node' AND ls.entity_id = n.nid AND ls.deleted = 0
     AND ls.delta = 0 AND ls.language IN (n.language, 'und')
LEFT JOIN field_data_field_count ct
  ON ct.entity_type = 'node' AND ct.entity_id = n.nid AND ct.deleted = 0
     AND ct.delta = 0 AND ct.language IN (n.language, 'und')
LEFT JOIN field_data_field_date_collected dc
  ON dc.entity_type = 'node' AND dc.entity_id = n.nid AND dc.deleted = 0
     AND dc.delta = 0 AND dc.language IN (n.language, 'und')
LEFT JOIN field_data_field_date_identified di
  ON di.entity_type = 'node' AND di.entity_id = n.nid AND di.deleted = 0
     AND di.delta = 0 AND di.language IN (n.language, 'und')
LEFT JOIN field_data_field_identification_qualifier iq
  ON iq.entity_type = 'node' AND iq.entity_id = n.nid AND iq.deleted = 0
     AND iq.delta = 0 AND iq.language IN (n.language, 'und')
LEFT JOIN field_data_field_remarks rm
  ON rm.entity_type = 'node' AND rm.entity_id = n.nid AND rm.deleted = 0
     AND rm.delta = 0 AND rm.language IN (n.language, 'und')
LEFT JOIN field_data_field_location l
  ON l.entity_type = 'node' AND l.entity_id = n.nid AND l.deleted = 0
     AND l.delta = 0 AND l.language IN (n.language, 'und')
LEFT JOIN node ln ON ln.nid = l.field_location_nid AND ln.status = 1
LEFT JOIN field_data_field_locality lo
  ON lo.entity_type = 'node' AND lo.entity_id = ln.nid AND lo.deleted = 0
     AND lo.delta = 0 AND lo.language IN (ln.language, 'und')
LEFT JOIN field_data_field_country co
  ON co.entity_type = 'node' AND co.entity_id = ln.nid AND co.deleted = 0
     AND co.delta = 0 AND co.language IN (ln.language, 'und')
LEFT JOIN field_data_field_map m
  ON m.entity_type = 'node' AND m.entity_id = ln.nid AND m.deleted = 0
     AND m.delta = 0 AND m.language IN (ln.language, 'und')
WHERE n.type = 'specimen_observation' AND n.status = 1
ORDER BY n.nid
