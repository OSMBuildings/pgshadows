--DROP FUNCTION latlonglength(numeric);

CREATE OR REPLACE FUNCTION LatLongLength(degree double precision) RETURNS point
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
  latlen decimal;
  longlen decimal;
  
BEGIN 
lat = degree * PI() / 180.0;

latlen  = m1 + (m2 * COS(2 * lat)) + (m3 * COS(4 * lat)) + (m4 * COS(6 * lat));
longlen = (p1 * COS(lat)) + (p2 * COS(3 * lat)) + (p3 * COS(5 * lat));

RETURN (longlen, latlen);

END;
$$ LANGUAGE plpgsql;

SELECT LatLongLength(13.5);