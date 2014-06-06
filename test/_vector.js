var sun = suncalc(...);
var length = 1 / tan(sun.altitude);
var v = {
  x: cos(sun.azimuth) * length,
  y: sin(sun.azimuth) * length
};
