function shadow(date, center, polygon, height) {
  var sunpos = suncalc(date, center.y, center.x);

  var dir = {
    x: Math.cos(sunpos.azimuth) / Math.tan(sunpos.altitude),
    y: Math.sin(sunpos.azimuth) / Math.tan(sunpos.altitude)
  };

  var
    mode,
     x1,  y1,  x2,  y2,
    _x1, _y1, _x2, _y2,
    res = [];

  var gm = geometers(center.y);

  mode = null;
  for (var i = 0, il = polygon.length-1; i < il; i++) {
    x1 = polygon[i].x;
    y1 = polygon[i].y;
    x2 = polygon[i+1].x;
    y2 = polygon[i+1].y;

    _x1 = x1 + dir.x*height / gm.y;
    _y1 = y1 - dir.y*height / gm.x;

    _x2 = x2 + dir.x*height / gm.y;
    _y2 = y2 - dir.y*height / gm.x;

    // mode 0: floor edges, mode 1: roof edges
    if ((x2-x1) * (_y1-y1) > (_x1-x1) * (y2-y1)) {
      if (mode === 1) {
        res.push({ x:x1, y:y1 });
      }
      mode = 0;
      if (!i) {
        res.push({ x:x1, y:y1 });
      }
      res.push({ x:x2, y:y2 });
    } else {
      if (mode === 0) {
        res.push({ x:_x1, y:_y1 });
      }
      mode = 1;
      if (!i) {
        res.push({ x:_x1, y:_y1 });
      }
      res.push({ x:_x2, y:_y2 });
    }
  }

  res.push(res[0]);

  var coordinates = [];
  for (var i = 0; i < res.length; i++) {
    coordinates[i] = [ res[i].x, res[i].y ];
  }

  return { type:'LineString', coordinates:coordinates };
}
