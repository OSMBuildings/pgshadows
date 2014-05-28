CREATE OR REPLACE FUNCTION Shadow(XOff decimal, YOff decimal, geom geometry, height decimal) RETURNS geometry
AS $$

DECLARE
  i integer;
  line geometry;
  m integer = 0;

  p geometry;

  x1 decimal;
  y1 decimal;
  _x1 decimal;
  _y1 decimal;
  
  x2 decimal;
  y2 decimal;
  _x2 decimal;
  _y2 decimal;

BEGIN
  line = ST_ExteriorRing(geom);

  FOR i IN 0..ST_NPoints(line)-2 LOOP
    x1 = ST_X(ST_PointN(line, i+1));
    y1 = ST_Y(ST_PointN(line, i+1));
    _x1 = x1 + XOff*height;
    _y1 = y1 + YOff*height;

    x2 = ST_X(ST_PointN(line, i+2));
    y2 = ST_Y(ST_PointN(line, i+2));
    _x2 = x2 + XOff*height;
    _y2 = y2 + YOff*height;

    -- m:FALSE - floor edges, m:TRUE - roof edges
    IF ((x2-x1) * (_y1-y1) > (_x1-x1) * (y2-y1)) THEN
      IF m = 1 THEN
        SELECT ST_SetPoint(line, i, ST_MakePoint(x1, y1)) INTO line;
      END IF;

      m = -1;

      IF i = 0 THEN
        SELECT ST_SetPoint(line, i, ST_MakePoint(x1, y1)) INTO line;
      END IF;

      SELECT ST_SetPoint(line, i, ST_MakePoint(x2, y2)) INTO line;
    ELSE
      IF m = -1 THEN
        SELECT ST_SetPoint(line, i, ST_MakePoint(_x1, _y1)) INTO line;
      END IF;

      m = 1;

      IF i = 0 THEN
        SELECT ST_SetPoint(line, i, ST_MakePoint(_x1, _y1)) INTO line;
      END IF;

      SELECT ST_SetPoint(line, i, ST_MakePoint(_x2, _y2)) INTO line;
  END IF;
  END LOOP;

  p = ST_PointN(line, 1);
  SELECT ST_AddPoint(line, p) INTO line;

  RETURN ST_MakePolygon(line);

END; 
$$ LANGUAGE plpgsql;


-- SELECT ST_ASTEXT(ST_GeomFromText('POLYGON ((10 20, 30 60, 50 20, 10 20))', 4326)) AS f, ST_ASTEXT(Shadow(50, 50, ST_GeomFromText('POLYGON ((10 20, 30 60, 50 20, 10 20))', 4326), 20)) AS s;

SELECT cartodb_id, Shadow(50, 50, the_geom_webmercator, 20) AS the_geom_webmercator FROM buildings
