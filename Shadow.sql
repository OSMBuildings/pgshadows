CREATE OR REPLACE FUNCTION Shadow(sunpos point, geom geometry, height decimal) RETURNS geometry
AS $$

DECLARE
  i integer;
  line geometry;
  m integer = 0;

  center geometry;
  LatLon point;
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
  xOff decimal;
  yOff decimal;
  
BEGIN
	length = 1 / tan(sunpos[1]);
	xOff = cos(sunpos[0]) * length;
	yOff = sin(sunpos[0]) * length;

  line = ST_ExteriorRing(geom);
  center = ST_Centroid(line);

  LatLon = LatLongLength(ST_Y(center));
  
    
  FOR i IN 0..ST_NPoints(line)-1 LOOP
    x1 = ST_X(ST_PointN(line, i+1));
    y1 = ST_Y(ST_PointN(line, i+1));
--    _x1 = x1 + XOff*height;
--    _y1 = y1 + YOff*height;
    _x1 = x1 + (15 / LatLon[0]);
    _y1 = y1 + (15 / LatLon[1]);

    p = ST_MakePoint(_x1,_y1);
   -- p = ST_PointN(line, 1);
    SELECT ST_SetPoint(line, i ,p) INTO line;
    END LOOP;

   RETURN ST_MakePolygon(line);

END;

$$ LANGUAGE plpgsql;


-- SELECT ST_ASTEXT(ST_GeomFromText('POLYGON ((10 20, 30 60, 50 20, 10 20))', 4326)) AS f, ST_ASTEXT(Shadow(sunposition('2014-05-28 12:00:00+02', ST_PointFromText('POINT(15 10)')), ST_GeomFromText('POLYGON ((10 20, 30 60, 50 20, 10 20))', 4326), 20)) AS s;

SELECT
 'POLYGON ((13.441895842552185 52.5433400349193, 13.442716598510742 52.54299095345783, 13.443360328674315 52.543565142053, 13.442534208297728 52.54391421894826, 13.441895842552185 52.5433400349193))' AS poly,
 ST_ASGEOJSON(
  Shadow(
    suncalc('2014-05-15 10:30:00', ST_PointFromText('POINT(13.37 52.52)')), 
    ST_GeomFromText('POLYGON ((13.441895842552185 52.5433400349193, 13.442716598510742 52.54299095345783, 13.443360328674315 52.543565142053, 13.442534208297728 52.54391421894826, 13.441895842552185 52.5433400349193))', 4326),
    20.0
  )
) AS s;

