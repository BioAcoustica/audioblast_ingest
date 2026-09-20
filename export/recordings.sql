-- BioAcoustica's published recordings that have a sound file, from the Drupal
-- database, in the columns of audioBLAST!'s recordings table (see
-- getHeaders("recordings") in audioBlastIngest).
--
-- Values are as BioAcoustica holds them, and audioBlastIngest normalises them:
-- dates and times are as they were entered, and channels are named rather than
-- counted. The file, its size, the post date and the licence are finished by
-- recordings.R. Everything else a recording holds, from the tapes and CDs of
-- the NHM Sound Collection to the conditions it was made in, is exported by
-- details.R, and its taxa, specimens and references by links.R.
--
-- The author is who made the recording, not whoever uploaded it, so it is
-- empty where no recordist is given. The place is where the recording was
-- made; where a specimen was collected is held by the specimen.

SELECT
  n.nid AS id,
  n.title AS Title,
  (SELECT GROUP_CONCAT(t.name ORDER BY s.delta SEPARATOR '; ')
     FROM field_data_field_species s
     JOIN taxonomy_term_data t ON t.tid = s.field_species_tid
    WHERE s.entity_type = 'node' AND s.entity_id = n.nid AND s.deleted = 0) AS taxon,
  fm.uri AS file,
  (SELECT GROUP_CONCAT(TRIM(CONCAT_WS(' ', g.field_user_given_names_value, fn.field_user_family_name_value))
                       ORDER BY r.delta SEPARATOR '; ')
     FROM field_data_field_recorded_by r
     LEFT JOIN field_data_field_user_given_names g
       ON g.entity_type = 'user' AND g.entity_id = r.field_recorded_by_uid AND g.deleted = 0
     LEFT JOIN field_data_field_user_family_name fn
       ON fn.entity_type = 'user' AND fn.entity_id = r.field_recorded_by_uid AND fn.deleted = 0
    WHERE r.entity_type = 'node' AND r.entity_id = n.nid AND r.deleted = 0) AS author,
  n.created AS post_date,
  NULL AS size,
  NULLIF(fm.filesize, 0) AS size_raw,
  fm.filemime AS type,
  (SELECT GROUP_CONCAT(t.name ORDER BY ns.delta SEPARATOR '; ')
     FROM field_data_field_non_specimen_recording ns
     JOIN taxonomy_term_data t ON t.tid = ns.field_non_specimen_recording_tid
    WHERE ns.entity_type = 'node' AND ns.entity_id = n.nid AND ns.deleted = 0) AS NonSpecimen,
  dr.field_date_recorded_value AS Date,
  lt.field_local_time_value AS Time,
  g3.duration AS Duration,
  NULL AS deployment,
  m.field_map_latitude AS lat,
  m.field_map_longitude AS lon,
  NULL AS time_of_day,
  lic.field_license_licence AS license,
  CONCAT('https://bio.acousti.ca/node/', n.nid) AS info_url,
  CONCAT_WS('; ', NULLIF(TRIM(rec.field_recorder_value), ''),
                  NULLIF(TRIM(mic.field_microphone_power_value), '')) AS device,
  ch.field_copyright_holder_value AS rights_holder,
  co.field_country_iso2 AS country,
  lo.field_locality_value AS locality,
  NULLIF(g3.audio_sample_rate, 0) AS sample_rate,
  NULLIF(g3.audio_channel_mode, '') AS channels
FROM node n
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid
LEFT JOIN getid3_meta g3 ON g3.fid = fm.fid
LEFT JOIN field_data_field_date_recorded dr
  ON dr.entity_type = 'node' AND dr.entity_id = n.nid AND dr.deleted = 0 AND dr.delta = 0
LEFT JOIN field_data_field_local_time lt
  ON lt.entity_type = 'node' AND lt.entity_id = n.nid AND lt.deleted = 0 AND lt.delta = 0
LEFT JOIN field_data_field_license lic
  ON lic.entity_type = 'node' AND lic.entity_id = n.nid AND lic.deleted = 0 AND lic.delta = 0
LEFT JOIN field_data_field_recorder rec
  ON rec.entity_type = 'node' AND rec.entity_id = n.nid AND rec.deleted = 0 AND rec.delta = 0
LEFT JOIN field_data_field_microphone_power_supply mps
  ON mps.entity_type = 'node' AND mps.entity_id = n.nid AND mps.deleted = 0 AND mps.delta = 0
LEFT JOIN field_data_field_microphone_power mic
  ON mic.entity_type = 'field_collection_item' AND mic.entity_id = mps.field_microphone_power_supply_value
     AND mic.deleted = 0 AND mic.delta = 0
LEFT JOIN field_data_field_copyright_holder ch
  ON ch.entity_type = 'node' AND ch.entity_id = n.nid AND ch.deleted = 0 AND ch.delta = 0
LEFT JOIN field_data_field_recording_location rl
  ON rl.entity_type = 'node' AND rl.entity_id = n.nid AND rl.deleted = 0 AND rl.delta = 0
LEFT JOIN node ln ON ln.nid = rl.field_recording_location_nid AND ln.status = 1
LEFT JOIN field_data_field_map m
  ON m.entity_type = 'node' AND m.entity_id = ln.nid AND m.deleted = 0
     AND m.delta = 0 AND m.language IN (ln.language, 'und')
LEFT JOIN field_data_field_country co
  ON co.entity_type = 'node' AND co.entity_id = ln.nid AND co.deleted = 0
     AND co.delta = 0 AND co.language IN (ln.language, 'und')
LEFT JOIN field_data_field_locality lo
  ON lo.entity_type = 'node' AND lo.entity_id = ln.nid AND lo.deleted = 0
     AND lo.delta = 0 AND lo.language IN (ln.language, 'und')
WHERE n.type = 'recording' AND n.status = 1
ORDER BY n.nid
