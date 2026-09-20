-- Everything else that BioAcoustica's recordings and specimens hold, from the
-- Drupal database, for audioBLAST!'s details table (see getHeaders("details")
-- in audioBlastIngest): a row for each value, named, with a unit where it is
-- measured, so that records can keep what they hold without a column for each
-- of it. A record's values of one name are numbered by delta.
--
-- Recordings give the tapes, CDs and tracks of the NHM Sound Collection, the
-- kit they were made with and the conditions they were made in; specimens give
-- their numbers and field notes. Files are made into URLs by details.R, and
-- values are otherwise as BioAcoustica holds them.
--
-- The unit each part starts with is cast to CHAR because a column that is NULL
-- in every part of a UNION is a binary one, which comes back as raw bytes
-- rather than as the text of the units that the other parts give.

SELECT d.type, d.id, d.name, d.delta, d.value, d.unit FROM (
  SELECT 'recordings' AS type, x.entity_id AS id, 'tape' AS name, x.delta AS delta,
         x.field_tape_value AS value, CAST(NULL AS CHAR) AS unit, x.language AS language
    FROM field_data_field_tape x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_tape_value IS NOT NULL
     AND x.field_tape_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'track' AS name, x.delta AS delta,
         x.field_track_s__value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_track_s_ x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_track_s__value IS NOT NULL
     AND x.field_track_s__value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'cd_id' AS name, x.delta AS delta,
         x.field_original_cd_id_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_original_cd_id x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_original_cd_id_value IS NOT NULL
     AND x.field_original_cd_id_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'cd_track' AS name, x.delta AS delta,
         x.field_original_cd_track_number_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_original_cd_track_number x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_original_cd_track_number_value IS NOT NULL
     AND x.field_original_cd_track_number_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'nhm_tape_number' AS name, x.delta AS delta,
         x.field_original_cd_nhm_tape_numbe_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_original_cd_nhm_tape_numbe x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_original_cd_nhm_tape_numbe_value IS NOT NULL
     AND x.field_original_cd_nhm_tape_numbe_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'verbatim_species' AS name, x.delta AS delta,
         x.field_original_cd_verbatim_speci_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_original_cd_verbatim_speci x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_original_cd_verbatim_speci_value IS NOT NULL
     AND x.field_original_cd_verbatim_speci_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'gain_control_position' AS name, x.delta AS delta,
         x.field_gain_control_position_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_gain_control_position x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_gain_control_position_value IS NOT NULL
     AND x.field_gain_control_position_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'peak_meter_reading' AS name, x.delta AS delta,
         x.field_peak_meter_reading_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_peak_meter_reading x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_peak_meter_reading_value IS NOT NULL
     AND x.field_peak_meter_reading_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'power_supply' AS name, x.delta AS delta,
         x.field_power_supply_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_power_supply x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_power_supply_value IS NOT NULL
     AND x.field_power_supply_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'reference_signal' AS name, x.delta AS delta,
         x.field_reference_signal_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_reference_signal x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_reference_signal_value IS NOT NULL
     AND x.field_reference_signal_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'light' AS name, x.delta AS delta,
         x.field_light_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_light x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_light_value IS NOT NULL
     AND x.field_light_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'air_movement' AS name, x.delta AS delta,
         x.field_air_movement_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_air_movement x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_air_movement_value IS NOT NULL
     AND x.field_air_movement_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'substrate_cage' AS name, x.delta AS delta,
         x.field_substrate_cage_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_substrate_cage x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_substrate_cage_value IS NOT NULL
     AND x.field_substrate_cage_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'extraneous_noise' AS name, x.delta AS delta,
         x.field_extraneous_noise_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_extraneous_noise x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_extraneous_noise_value IS NOT NULL
     AND x.field_extraneous_noise_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'biotic_factors' AS name, x.delta AS delta,
         x.field_biotic_factors_experimenta_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_biotic_factors_experimenta x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_biotic_factors_experimenta_value IS NOT NULL
     AND x.field_biotic_factors_experimenta_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'cultural_usage' AS name, x.delta AS delta,
         x.field_cultural_usage_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_cultural_usage x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_cultural_usage_value IS NOT NULL
     AND x.field_cultural_usage_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'description' AS name, x.delta AS delta,
         x.body_value AS value, NULL AS unit, x.language AS language
    FROM field_data_body x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.body_value IS NOT NULL
     AND x.body_value <> ''
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'tape_speed' AS name, x.delta AS delta,
         x.field_tape_speed_cm_s__value AS value, 'cm/s' AS unit, x.language AS language
    FROM field_data_field_tape_speed_cm_s_ x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_tape_speed_cm_s__value IS NOT NULL
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'temperature_start' AS name, x.delta AS delta,
         x.field_temperature_initial_celsiu_value AS value, '°C' AS unit, x.language AS language
    FROM field_data_field_temperature_initial_celsiu x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_temperature_initial_celsiu_value IS NOT NULL
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'temperature_end' AS name, x.delta AS delta,
         x.field_temperature_final_celsius__value AS value, '°C' AS unit, x.language AS language
    FROM field_data_field_temperature_final_celsius_ x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_temperature_final_celsius__value IS NOT NULL
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'humidity_start' AS name, x.delta AS delta,
         x.field_relative_humidity_initial__value AS value, '%' AS unit, x.language AS language
    FROM field_data_field_relative_humidity_initial_ x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_relative_humidity_initial__value IS NOT NULL
  UNION ALL
  SELECT 'recordings' AS type, x.entity_id AS id, 'humidity_end' AS name, x.delta AS delta,
         x.field_relative_humidity_final__value AS value, '%' AS unit, x.language AS language
    FROM field_data_field_relative_humidity_final_ x
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
     AND x.field_relative_humidity_final__value IS NOT NULL
  UNION ALL
  SELECT 'recordings', x.entity_id, 'voyage', x.delta, t.name, NULL, x.language
    FROM field_data_field_rec_voyage x
    JOIN taxonomy_term_data t ON t.tid = x.field_rec_voyage_tid
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
  UNION ALL
  SELECT 'recordings', x.entity_id, 'project', x.delta, t.name, NULL, x.language
    FROM field_data_field_project x
    JOIN taxonomy_term_data t ON t.tid = x.field_project_tid
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
  UNION ALL
  SELECT 'recordings', x.entity_id, 'original_metadata_image', x.delta, f.uri, NULL, x.language
    FROM field_data_field_original_metadata_image x
    JOIN file_managed f ON f.fid = x.field_original_metadata_image_fid
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
  UNION ALL
  SELECT 'recordings', x.entity_id, 'original_trace_image', x.delta, f.uri, NULL, x.language
    FROM field_data_field_original_trace_images x
    JOIN file_managed f ON f.fid = x.field_original_trace_images_fid
   WHERE x.entity_type = 'node' AND x.bundle = 'recording' AND x.deleted = 0
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'microphone_power_supply', mps.delta, x.field_microphone_power_value, NULL, mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_microphone_power x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_microphone_power_value IS NOT NULL AND x.field_microphone_power_value <> ''
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'microphone_distance', mps.delta, x.field_distance_from_subject_cm__value, 'cm', mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_distance_from_subject_cm_ x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_distance_from_subject_cm__value IS NOT NULL AND x.field_distance_from_subject_cm__value <> ''
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'windshield', mps.delta, x.field_windshield_value, NULL, mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_windshield x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_windshield_value IS NOT NULL AND x.field_windshield_value <> ''
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'reflector', mps.delta, x.field_reflector_value, NULL, mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_reflector x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_reflector_value IS NOT NULL AND x.field_reflector_value <> ''
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'preamplifier', mps.delta, x.field_preamplifier_value, NULL, mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_preamplifier x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_preamplifier_value IS NOT NULL AND x.field_preamplifier_value <> ''
  UNION ALL
  SELECT 'recordings', mps.entity_id, 'filter', mps.delta, x.field_filter_value, NULL, mps.language
    FROM field_data_field_microphone_power_supply mps
    JOIN field_data_field_filter x ON x.entity_type = 'field_collection_item' AND x.deleted = 0
      AND x.entity_id = mps.field_microphone_power_supply_value AND x.delta = 0
   WHERE mps.entity_type = 'node' AND mps.bundle = 'recording' AND mps.deleted = 0
     AND x.field_filter_value IS NOT NULL AND x.field_filter_value <> ''
) d
JOIN node n ON n.nid = d.id AND n.type = 'recording' AND n.status = 1
  AND d.language IN (n.language, 'und')
JOIN field_data_field_recording fr
  ON fr.entity_type = 'node' AND fr.entity_id = n.nid AND fr.deleted = 0 AND fr.delta = 0
JOIN file_managed fm ON fm.fid = fr.field_recording_fid

UNION ALL

SELECT d.type, d.id, d.name, d.delta, d.value, d.unit FROM (
  SELECT 'specimens' AS type, x.entity_id AS id, 'collector_number' AS name, x.delta AS delta,
         x.field_collector_number_value AS value, CAST(NULL AS CHAR) AS unit, x.language AS language
    FROM field_data_field_collector_number x
   WHERE x.entity_type = 'node' AND x.bundle = 'specimen_observation' AND x.deleted = 0
     AND x.field_collector_number_value IS NOT NULL
     AND x.field_collector_number_value <> ''
  UNION ALL
  SELECT 'specimens' AS type, x.entity_id AS id, 'field_number' AS name, x.delta AS delta,
         x.field_number_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_number x
   WHERE x.entity_type = 'node' AND x.bundle = 'specimen_observation' AND x.deleted = 0
     AND x.field_number_value IS NOT NULL
     AND x.field_number_value <> ''
  UNION ALL
  SELECT 'specimens' AS type, x.entity_id AS id, 'field_notes' AS name, x.delta AS delta,
         x.field_notes_value AS value, NULL AS unit, x.language AS language
    FROM field_data_field_notes x
   WHERE x.entity_type = 'node' AND x.bundle = 'specimen_observation' AND x.deleted = 0
     AND x.field_notes_value IS NOT NULL
     AND x.field_notes_value <> ''
) d
JOIN node n ON n.nid = d.id AND n.type = 'specimen_observation' AND n.status = 1
  AND d.language IN (n.language, 'und')

ORDER BY type, id, name, delta
