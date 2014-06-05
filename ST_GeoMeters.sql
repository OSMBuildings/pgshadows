-- DROP FUNCTION ST_GeoMeters(geometry);
CREATE OR REPLACE FUNCTION ST_GeoMeters(point geometry) RETURNS vector
AS $$

DECLARE
  m1 decimal = 111132.92; 
  m2 decimal = -559.82; 
  m3 decimal = 1.175; 
  m4 decimal = -0.0023; 
  p1 decimal = 111412.84; 
  p2 decimal = -93.5; 
  p3 decimal = 0.118; 

  lat decimal;
  lat_len decimal;
  lon_len decimal;
  
BEGIN 
  lat = ST_Y(point) * PI()/180.0;
  lat_len  = m1 + (m2 * COS(2 * lat)) + (m3 * COS(4 * lat)) + (m4 * COS(6 * lat));
  lon_len = (p1 * COS(lat)) + (p2 * COS(3 * lat)) + (p3 * COS(5 * lat));

  RETURN ROW(lon_len, lat_len);
END;

$$ LANGUAGE plpgsql;

-- SELECT ST_GeoMeters(ST_GeomFromText('POINT(52.52 13.37)', 4326));
