use <MCAD/shapes/polyhole.scad>

h = 6.5;
r = h/2 / cos(30);

module stumpy() {
  rotate([0, 90, 0]) rotate([0, 0, 30]) intersection() {
    cylinder(r=r, h=8, center=true, $fn=6);
    sphere(r=5.1, $fn=24);
  }
}

module middle() {
  difference() {
    union() {
      translate([-2, 0, 0]) stumpy();
      translate([2, 0, 0]) stumpy();
      rotate([0, 0, 90]) stumpy();
    }
    rotate([90, 0, 0]) mcad_polyhole (d=3.2, h=30, center=true);
    rotate([0, 90, 0]) mcad_polyhole (d=3.2, h=30, center=true);
  }
}

translate([0, 0, h/2]) middle();
