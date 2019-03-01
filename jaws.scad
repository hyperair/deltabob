use <MCAD/array/rectangular.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

// outer diameter of tube
h = 7;

// standard rostock settings
jaw_inner_width = 8.4;
jaw_outer_width = 14;

// adjusts the shape of the taper and length of the plug
plug_offset = 20;
plug_d = 6.45;
plug_length = 20;

// a square at the end to ease with the overhang
bridge_helper = true;

// automatically calculated
d = h / cos (30);
r = d / 2;
jaw_depth = jaw_inner_width * 0.5;

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
                cylinder (d1 = jaw_outer_width * 1.6, d2 = d, h = plug_offset,
                    $fn = 6);
            }

            cube ([1000, jaw_outer_width, h], center = true);
        }

        // cutout for ujoint movement
        for (a = [45, 0, -45])
        translate ([(a == 0) ? jaw_depth : 0, 0, 0])
        rotate (a, Y)
        hull ()
        mcad_linear_multiply (2, 30, axis = -X)
        rotate (30, Z)
        cylinder (d = jaw_inner_width, h = h * 2.5, center = true ,$fn = 6);

        // m3 screwhole/shaft
        rotate ([90, 0, 0])
        mcad_polyhole (d = 3, h = 40, center =true, $fn = 12);
    }

    // plug
    translate ([plug_offset - epsilon, 0, 0])
    rotate (90, Y)
    rotate (30, Z)
    cylinder (d = plug_d, h = plug_length + epsilon, $fn = 6);

    // cube for bridge helper
    if (bridge_helper)
    translate ([plug_length + plug_offset - epsilon, 0, 0])
    ccube (size = [3, plug_d * 2, h], center = [false, true, true]);
}

translate ([0, 0, h/2])
jaws (true);
