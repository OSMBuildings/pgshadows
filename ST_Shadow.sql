-- geom can be a Polygon or MultiPolygon, inner rings are not supported yet

-- DROP FUNCTION ST_Shadow(vector, geometry, numeric);
-- DROP FUNCTION ST_Shadow(timestamp, geometry, numeric);
CREATE OR REPLACE FUNCTION ST_Shadow(date timestamp, geom geometry, height decimal) RETURNS geometry
AS $$

DECLARE
  i integer;

  poly geometry;
  poly_srid integer;

  footprint geometry;
  shadow geometry;
  shadow_poly geometry;
  result geometry;

  x decimal;
  y decimal;
  
  f1 geometry;
  f2 geometry;
  s1 geometry;
  s2 geometry;

  sun_pos vector;
  sun_vector vector;

BEGIN
  sun_pos = suncalc(date, ST_Centroid(geom));
    
  IF sun_pos.y < 0 THEN
    RETURN NULL;
  END IF;

  sun_vector.x = COS(sun_pos.x) / TAN(sun_pos.y);
  sun_vector.y = SIN(sun_pos.x) / TAN(sun_pos.y);

  poly = ST_GeometryN(geom, 1);

  IF ST_GeometryType(poly) != 'ST_Polygon' THEN
    RETURN NULL;
  END IF;

  poly_srid = ST_SRID(geom);

  footprint   = ST_Transform(ST_ExteriorRing(poly), 900913);
  shadow      = ST_Translate(footprint, sun_vector.x*height, sun_vector.y*height);
  shadow_poly = ST_MakePolygon(shadow);
  result      = ST_GeomFromText('LINESTRING(0 0, 1 1)', 900913);

  FOR i IN 0..ST_NPoints(footprint)-2 LOOP
    f1 = ST_PointN(footprint, i+1);
    f2 = ST_PointN(footprint, i+2);
    s1 = ST_PointN(shadow, i+1);
    s2 = ST_PointN(shadow, i+2);

    IF ST_Contains(shadow_poly, f1) THEN
      result = ST_AddPoint(result, s1);
      result = ST_AddPoint(result, s2);
    ELSE
      result = ST_AddPoint(result, f1);
      IF ST_Contains(shadow_poly, f2) THEN
	result = ST_AddPoint(result, s1);
      END IF;
    END IF;
  END LOOP;

  result = ST_RemovePoint(result, 0);
  result = ST_RemovePoint(result, 0);
  result = ST_AddPoint(result, ST_PointN(result, 1));

  RETURN ST_Transform(ST_MakePolygon(result), poly_srid);
END;

$$ LANGUAGE plpgsql;

SELECT
  ST_ASGeoJSON(ST_Shadow(
    '2014-05-15T08:00:00',
    ST_GeomFromText('POLYGON ((13.441895842552185 52.5433400349193, 13.442716598510742 52.54299095345783, 13.443360328674315 52.543565142053, 13.442534208297728 52.54391421894826, 13.441895842552185 52.5433400349193))', 4326),
    15.0), 4
  );

SELECT cartodb_id, ST_Shadow('2014-05-15T08:00:00', the_geom, 15.0) AS sx, the_geom_webmercator FROM berlin_filtered WHERE ST_GeometryType(the_geom) = 'ST_Polygon' OR ST_GeometryType(the_geom) = 'ST_MultiPolygon';