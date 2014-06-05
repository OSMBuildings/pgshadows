function compute(deg) {

  lat = deg * Math.PI / 180.0;
  m1 = 111132.92; // latitude calculation term 1
  m2 = -559.82; // latitude calculation term 2
  m3 = 1.175; // latitude calculation term 3
  m4 = -0.0023; // latitude calculation term 4
  p1 = 111412.84; // longitude calculation term 1
  p2 = -93.5; // longitude calculation term 2
  p3 = 0.118; // longitude calculation term 3

  // Calculate the length of a degree of latitude and longitude in meters
  latlen  = m1 + (m2 * Math.cos(2 * lat)) + (m3 * Math.cos(4 * lat)) + (m4 * Math.cos(6 * lat));
  longlen = (p1 * Math.cos(lat)) + (p2 * Math.cos(3 * lat)) + (p3 * Math.cos(5 * lat));
}



function lon2meters(deg) {
  lat = deg * Math.PI / 180.0;
  p1 = 111412.84; // longitude calculation term 1
  p2 = -93.5; // longitude calculation term 2
  p3 = 0.118; // longitude calculation term 3

  return p1*Math.cos(lat) + p2*Math.cos(3*lat) + p3*Math.cos(5*lat);
}
