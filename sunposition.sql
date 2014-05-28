--DROP FUNCTION sunposition(timestamp with time zone,geometry)
CREATE OR REPLACE FUNCTION sunposition(date timestamp with time zone, coord geometry) RETURNS geometry AS $$

DECLARE
rad decimal = Pi()/180;
dayMs decimal = 1000*60*60*24;
J1970 decimal = 2440588;
J2000 decimal = 2451545;
e decimal = rad*23.4397;
dateMS decimal;

lon float = st_x(coord);
lat float = st_y(coord);

lw decimal = rad*(-lon);
phi decimal = rad*lat;

toJulian decimal;
toDays decimal;
SolarMeanAnomaly decimal;
EquationOfCenter decimal;
EclipticLongitude decimal;
Declination decimal;
RightAscension decimal;
SiderealTime decimal;
H decimal;
Altitude decimal;
Azimuth decimal;
timeMS decimal;
 
BEGIN
dateMS = date_part('epoch',date);
toJulian = dateMS/dayMs - 0.5+J1970;
toDays = toJulian - J2000;
SolarMeanAnomaly = rad*(357.5291 + 0.98560028*toDays);
EquationOfCenter = rad * (1.9148*sin(SolarMeanAnomaly) + 0.0200 * sin(2*SolarMeanAnomaly) + 0.0003 * sin(3*SolarMeanAnomaly));
EclipticLongitude = SolarMeanAnomaly+EquationOfCenter+(rad*102.9372)+pi();
Declination = asin(sin(0)*cos(e) + cos(0)*sin(e)*sin(EclipticLongitude));
RightAscension = atan2(sin(EclipticLongitude)*cos(e) - tan(0)*sin(e), cos(EclipticLongitude));
SiderealTime = rad * (280.16 + 360.9856235*toDays) - lw;
H = SiderealTime - RightAscension;
Altitude = asin(sin(phi)*sin(Declination) + cos(phi)*cos(Declination)*cos(H));
Azimuth = (atan2(sin(H), cos(H)*sin(phi) - tan(Declination)*cos(phi))) - pi()/2;

--RETURN xmlelement(name sunposition, xmlattributes( Azimuth as azimuth, Altitude as altitude));
RETURN ST_MakePoint(Altitude, Azimuth);

END;

$$ LANGUAGE plpgsql;

--SELECT sunposition(1401271200,0,0);
SELECT ST_AsText(sunposition('2014-05-28 12:00:00+02', ST_PointFromText('POINT(15 10)')));