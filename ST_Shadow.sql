
--DROP FUNCTION shadow(sunpos, geometry, numeric);
CREATE OR REPLACE FUNCTION ST_Shadow(sunpos vector, geom geometry, height decimal) RETURNS geometry
AS $$

DECLARE
  i integer;
  src_line geometry;
  dst_line geometry;
  m integer = -1;
 
  geometers vector;
  p geometry;

   x1 decimal;
   y1 decimal;
  _x1 decimal;
  _y1 decimal;
  
   x2 decimal;
   y2 decimal;
  _x2 decimal;
  _y2 decimal;

  length decimal;
  sun_vector vector;
  
BEGIN
  length = TAN(sunpos.y);
  sun_vector.x = COS(sunpos.x) / length;
  sun_vector.y = SIN(sunpos.x) / length;

  src_line = ST_ExteriorRing(geom);

  geometers = ST_GeoMeters(ST_Centroid(src_line));
  dst_line = ST_GeomFromText('LINESTRING(0 0, 1 1)');
  
  FOR i IN 0..ST_NPoints(src_line)-2 LOOP
    x1 = ST_X(ST_PointN(src_line, i+1));
    y1 = ST_Y(ST_PointN(src_line, i+1));
   _x1 = x1 + sun_vector.x*height / geometers.x;
   _y1 = y1 + sun_vector.y*height / geometers.y;

    x2 = ST_X(ST_PointN(src_line, i+2));
    y2 = ST_Y(ST_PointN(src_line, i+2));
   _x2 = x2 + sun_vector.x*height / geometers.x;
   _y2 = y2 + sun_vector.y*height / geometers.y;

  -- m:0 => floor edges, m:1 => shadow edges
    IF ((x2-x1) * (_y1-y1) > (_x1-x1) * (y2-y1)) THEN
      IF m = 1 THEN
        SELECT ST_AddPoint(dst_line, ST_MakePoint(x1, y1)) INTO dst_line;
      END IF;

      m = 0;

      IF i = 0 THEN
        SELECT ST_AddPoint(dst_line, ST_MakePoint(x1, y1)) INTO dst_line;
      END IF;

      SELECT ST_AddPoint(dst_line, ST_MakePoint(x2, y2)) INTO dst_line;
    ELSE
      IF m = 0 THEN
        SELECT ST_AddPoint(dst_line, ST_MakePoint(_x1, _y1)) INTO dst_line;
      END IF;

      m = 1;

      IF i = 0 THEN
        SELECT ST_AddPoint(dst_line, ST_MakePoint(_x1, _y1)) INTO dst_line;
      END IF;

      SELECT ST_AddPoint(dst_line, ST_MakePoint(_x2, _y2)) INTO dst_line;
    END IF;
  END LOOP;

  SELECT ST_RemovePoint(dst_line, 0) INTO dst_line;
  SELECT ST_RemovePoint(dst_line, 0) INTO dst_line;

  RETURN ST_MakePolygon(dst_line);
END;

$$ LANGUAGE plpgsql;

SELECT
 'POLYGON ((13.441895842552185 52.5433400349193, 13.442716598510742 52.54299095345783, 13.443360328674315 52.543565142053, 13.442534208297728 52.54391421894826, 13.441895842552185 52.5433400349193))' AS poly,
 ST_ASGeoJSON(
  ST_Shadow(
    suncalc('2014-08-16 19:00:00', ST_PointFromText('POINT(13.37 52.52)')), 
    ST_GeomFromText('POLYGON ((13.441895842552185 52.5433400349193, 13.442716598510742 52.54299095345783, 13.443360328674315 52.543565142053, 13.442534208297728 52.54391421894826, 13.441895842552185 52.5433400349193))', 4326),
    20.0
  ), 4
) AS s;
