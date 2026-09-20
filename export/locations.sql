-- The places BioAcoustica's recordings were made and its specimens collected,
-- from the Drupal database, for audioBLAST!'s locations table (see
-- getHeaders("locations") in audioBlastIngest). A place is a location node,
-- identified by its node id, and the recordings and specimens that are of it
-- are links (see links.sql), so that a place is described once however many
-- records share it.
--
-- The columns are named after the Darwin Core terms they hold. name is the
-- node's title, which is how the site names the place ("Chapman's Pool,
-- Dorset"); locality is the site's own locality field, which few places fill.
--
-- A few fields have a row for the node's language and another for none, so
-- each is taken once for the node rather than joined twice.

SELECT n.nid AS id, MAX(n.title) AS name,
  MAX(co.field_continent_or_ocean_value) AS continent,
  MAX(c.field_country_iso2) AS countryCode,
  MAX(sp.field_state_province_value) AS stateProvince,
  MAX(cy.field_county_value) AS county,
  MAX(i.field_island_value) AS island,
  MAX(ig.field_island_group_value) AS islandGroup,
  MAX(lo.field_locality_value) AS locality,
  MAX(m.field_map_latitude) AS decimalLatitude,
  MAX(m.field_map_longitude) AS decimalLongitude,
  MAX(u.field_coordinate_uncertainty_value) AS coordinateUncertaintyInMeters,
  MAX(gd.field_geodetic_datum_value) AS geodeticDatum,
  MAX(gr.field_georeference_remarks_value) AS georeferenceRemarks,
  MAX(mine.field_min_elevation_value) AS minimumElevationInMeters,
  MAX(maxe.field_max_elevation_value) AS maximumElevationInMeters,
  CONCAT('https://bio.acousti.ca/node/', n.nid) AS info_url
FROM node n
LEFT JOIN field_data_field_continent_or_ocean co
  ON co.entity_type = 'node' AND co.entity_id = n.nid AND co.deleted = 0 AND co.delta = 0
  AND co.language IN (n.language, 'und')
LEFT JOIN field_data_field_country c
  ON c.entity_type = 'node' AND c.entity_id = n.nid AND c.deleted = 0 AND c.delta = 0
  AND c.language IN (n.language, 'und')
LEFT JOIN field_data_field_state_province sp
  ON sp.entity_type = 'node' AND sp.entity_id = n.nid AND sp.deleted = 0 AND sp.delta = 0
  AND sp.language IN (n.language, 'und')
LEFT JOIN field_data_field_county cy
  ON cy.entity_type = 'node' AND cy.entity_id = n.nid AND cy.deleted = 0 AND cy.delta = 0
  AND cy.language IN (n.language, 'und')
LEFT JOIN field_data_field_island i
  ON i.entity_type = 'node' AND i.entity_id = n.nid AND i.deleted = 0 AND i.delta = 0
  AND i.language IN (n.language, 'und')
LEFT JOIN field_data_field_island_group ig
  ON ig.entity_type = 'node' AND ig.entity_id = n.nid AND ig.deleted = 0 AND ig.delta = 0
  AND ig.language IN (n.language, 'und')
LEFT JOIN field_data_field_locality lo
  ON lo.entity_type = 'node' AND lo.entity_id = n.nid AND lo.deleted = 0 AND lo.delta = 0
  AND lo.language IN (n.language, 'und')
LEFT JOIN field_data_field_map m
  ON m.entity_type = 'node' AND m.entity_id = n.nid AND m.deleted = 0 AND m.delta = 0
  AND m.language IN (n.language, 'und')
LEFT JOIN field_data_field_coordinate_uncertainty u
  ON u.entity_type = 'node' AND u.entity_id = n.nid AND u.deleted = 0 AND u.delta = 0
  AND u.language IN (n.language, 'und')
LEFT JOIN field_data_field_geodetic_datum gd
  ON gd.entity_type = 'node' AND gd.entity_id = n.nid AND gd.deleted = 0 AND gd.delta = 0
  AND gd.language IN (n.language, 'und')
LEFT JOIN field_data_field_georeference_remarks gr
  ON gr.entity_type = 'node' AND gr.entity_id = n.nid AND gr.deleted = 0 AND gr.delta = 0
  AND gr.language IN (n.language, 'und')
LEFT JOIN field_data_field_min_elevation mine
  ON mine.entity_type = 'node' AND mine.entity_id = n.nid AND mine.deleted = 0 AND mine.delta = 0
  AND mine.language IN (n.language, 'und')
LEFT JOIN field_data_field_max_elevation maxe
  ON maxe.entity_type = 'node' AND maxe.entity_id = n.nid AND maxe.deleted = 0 AND maxe.delta = 0
  AND maxe.language IN (n.language, 'und')
WHERE n.type = 'location' AND n.status = 1
GROUP BY n.nid
ORDER BY n.nid
