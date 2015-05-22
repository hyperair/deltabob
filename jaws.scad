use <MCAD/array/along_curve.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

h = 9.6;
d = h / cos (30);
r = d / 2;

jaw_inner_width = 8.4;
jaw_outer_width = 14;
plug_offset = 20;

jaw_depth = r * 1.5;

$fs = 0.4;
$fa = 1;

module jaws () {
    difference () {
        intersection () {
            union () {
                rotate (90, X)
                cylinder (d = d, h = jaw_outer_width, center = true);

                rotate (90, Y)
                rotate (30, Z)
                cylinder (d1 = jaw_outer_width * 1.6, d2 = d, h = plug_offset, $fn = 6);
            }

            cube ([1000, jaw_outer_width, h], center = true);
        }

        *union () {
            intersection () {
                rotate ([90, 0, 0])
                cylinder (r = h / 2, h = jaw_outer_width, center = true);

                translate ([-4, 0, 0])
                cube ([10, 14, h], center = true);
            }

            intersection () {
                translate ([12, 0, 0])
                cube ([26, 14, h], center = true);

                translate ([10, 0, 0])
                rotate ([0, 90, 0])
                rotate ([0, 0, 30])
                cylinder (r1 = 10, r2 = r, h = 26, center = true, $fn = 6);
            }
        }

        translate ([3.5 - 5, 0, 0])
        cube ([10, jaw_inner_width, h], center = true);

        *union () {
            translate ([3.5, 0, 0])
            rotate ([0, 0, 30])
            cylinder (r = 4.2, h = 10, center = true, $fn = 6);

            translate ([4, 0, 4])
            rotate ([0, 45, 0])
            rotate ([0, 0, 30])
            cylinder (r = 4.2, h = 8, center = true, $fn = 6);

            translate ([4, 0, -4])
            rotate ([0, -45, 0])
            rotate ([0, 0, 30])
            cylinder (r = 4.2, h = 8, center = true, $fn = 6);
        }

        for (a = [45, 0, -45])
        rotate (a, Y)
        hull ()
        mcad_linear_multiply (2, 30, axis = -X)
        rotate (30, Z)
        cylinder (d = jaw_inner_width, h = h * 2.5, center = true ,$fn = 6);

        rotate ([90, 0, 0])
        mcad_polyhole (d = 3, h = 40, center =true, $fn = 12);
    }
}

translate ([0, 0, h/2]) jaws ();
