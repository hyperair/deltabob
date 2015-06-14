use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/2Dshapes.scad>

include <MCAD/units/metric.scad>

od = 20;

bearing_od = 10;
bearing_thickness = 4;
bearing_separation = 2;

bearing_hole_clearance = 0.3;
ridge = 0.4;

thickness = bearing_thickness * 2 + bearing_separation;

flange_height = 2;
flange_angle = 30;
flange_d = od + flange_height * 2 + 1;

$fs = 0.4;
$fa = 1;

module mirror_duplicate (axis)
{
    children ();

    mirror (axis)
    children ();
}

difference () {
    rotate_extrude ()
    offset (r = -1)
    offset (r = 1)
    union () {
        // crowned portion
        intersection () {
            translate ([0, -thickness / 2])
            square ([od * 2, thickness]);

            circle (d = od);
            // ellipse (width = od + 1, height = thickness * 2);
        }

        // flange
        mirror_duplicate (Y)
        translate ([flange_d / 4, -thickness / 2])
        trapezoid (bottom = flange_d / 2, height = flange_height,
            left_angle = 90, right_angle = flange_angle);
    }

    mirror_duplicate (Z)
    translate ([0, 0, bearing_separation / 2])
    mcad_polyhole (d = bearing_od + bearing_hole_clearance, h = 100);

    mcad_polyhole (d = bearing_od - ridge * 2, h = 1000, center = true);
}
