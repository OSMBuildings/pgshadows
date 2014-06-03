-- DROP FUNCTION suncalc(timestamp with time zone, geometry);
CREATE OR REPLACE FUNCTION suncalc(date timestamp, coord geometry) RETURNS point AS $$

-- calculations based on algorithms from http://aa.quae.nl/en/reken/zonpositie.html
-- code taken from Vladimir Agafonkin's (@mourner) SunCalc https://github.com/mourner/suncalc
-- few modifications by Jan Marsch, OSM Buildings (@kekscom)
-- code migration to PostgreSQL by Sören Horn, OSM Buildings (@SoerenHorn85)

DECLARE
  rad decimal = PI()/180;
  day_s decimal = 60*60*24;
  j1970 decimal = 2440588;
  j2000 decimal = 2451545;
  e decimal = rad*23.4397;
  date_s decimal;

  lon float = st_x(coord);
  lat float = st_y(coord);

  lw decimal = rad*(-lon);
  phi decimal = rad*lat;

  in_julian decimal;
  in_days decimal;
  solar_mean_anomaly decimal;
  equation_of_center decimal;
  ecliptic_longitude decimal;
  declination decimal;
  right_ascension decimal;
  sidereal_time decimal;
  h decimal;
  altitude decimal;
  azimuth decimal;

BEGIN
  date_s = date_part('epoch', date);
  in_julian = date_s/day_s - 0.5 + j1970 - j2000;
  solar_mean_anomaly = rad * (357.5291 + 0.98560028*in_julian);
  equation_of_center = rad * (1.9148*SIN(solar_mean_anomaly) + 0.0200*SIN(2*solar_mean_anomaly) + 0.0003*SIN(3*solar_mean_anomaly));
  ecliptic_longitude = solar_mean_anomaly + equation_of_center + rad*102.9372 + PI();
  declination = ASIN(SIN(0)*COS(e) + COS(0)*SIN(e)*SIN(ecliptic_longitude));
  right_ascension = ATAN2(SIN(ecliptic_longitude)*COS(e) - tan(0)*SIN(e), COS(ecliptic_longitude));
  sidereal_time = rad * (280.16 + 360.9856235*in_julian) - lw;
  h = sidereal_time - right_ascension;
  altitude = ASIN(SIN(phi)*SIN(declination) + COS(phi)*COS(declination)*COS(h));
  azimuth  = (ATAN2(SIN(h), COS(h)*SIN(phi) - tan(declination)*COS(phi))) - PI()/2;

  RETURN (azimuth, altitude);
END;

$$ LANGUAGE plpgsql;

SELECT suncalc('2014-05-15 10:30:00', ST_PointFromText('POINT(13.37 52.52)'));
