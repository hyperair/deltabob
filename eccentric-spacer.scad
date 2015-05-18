use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

min_wall_thickness = 1;
neck_length = 3.5;
outer_length = 7.5;
chamfer_thickness = 1;

eccentricity = 1;
bore_d = 5;
clearance = 0.3;
neck_d = 8;

total_thickness = outer_length + neck_length;

hex_ac_width = neck_d * 1.8;
hex_af_width = 2 * hex_ac_width / 2 * cos (30);

module cylinder_chamfer (d, h, t)
{
    translate ([0, 0, t])
    cylinder (d = d, h - t * 2);

    intersection () {
        cylinder (d = d, h = h);
        cylinder (d1 = d - t * 2, d2 = d + epsilon, h = t + epsilon);
    }

    intersection () {
        cylinder (d = d, h = h);

        translate ([0, 0, h - t - epsilon])
        cylinder (d1 = d + epsilon, d2 = d - t * 2, h = t + epsilon);
    }
}

module eccentric_spacer ()
{
    difference () {
        // hex
        union () {
            intersection () {
                cylinder (d = hex_ac_width, h = outer_length, $fn = 6);

                cylinder_chamfer (d = hex_ac_width, h = outer_length,
                    t = chamfer_thickness);
            }

            cylinder (d = neck_d, h = outer_length + neck_length);
        }

        translate ([0, eccentricity, -epsilon])
        mcad_polyhole (d = bore_d + clearance, h = total_thickness +
            epsilon * 2);

        translate ([0, hex_af_width / 2 - 1, (outer_length - 2) / 2 + 0.8])
        rotate (-90, X)
        rotate (-90, Z)
        linear_extrude (height = 1.1)
        circle (d = outer_length - 2, $fn = 3);
    }
}

eccentric_spacer ();
