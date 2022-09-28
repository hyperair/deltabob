include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>

$fs = 0.4;
$fa = 1;

rod_d = 6;
rod_depth = rod_d * 2;
wall_thickness = 2;

d2 = 5.8;
bore = 4.3;

screw_size = 4;
screwhead_size = 7;
screw_length = 11;
screwhead_thickness = screw_size;
clearance = 0.3;

d1 = rod_d + wall_thickness * 2;
cone_h = screw_length;

module ball_end ()
{
    difference () {
        union () {
            translate ([0, 0, rod_depth + screwhead_thickness])
            cylinder (d2 = d2, d1 = d1, h = cone_h);

            cylinder (d = d1, h = rod_depth + screwhead_thickness);
        }

        translate ([0, 0, -epsilon]) {
            /* screwhole */
            mcad_polyhole (d = screw_size + clearance,
                           h = rod_depth + cone_h + screwhead_thickness +
                           epsilon * 2);

            /* caphead hole */
            mcad_polyhole (d = screwhead_size + clearance,
                           h = rod_depth + screwhead_thickness + epsilon);

            /* rod depth */
            mcad_polyhole (d = rod_d,
                           h = rod_depth);
        }
    }
}

ball_end ();
