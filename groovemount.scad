include <MCAD/units/metric.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/cylinder.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/array/along_curve.scad>
use </home/hyperair/src/rostock/platform.scad>


effector_od = 60;
effector_id = 40;
effector_h = 8;
effector_screwsize = M4;
effector_screwhole_d = effector_screwsize + 0.3;

effector_screw_orbit_r = 25;

arm_thickness = 8;
arm_width = 15;

jhead_lip_h = 3.7;
jhead_lip_d = 16;
jhead_groove_d = 12;
jhead_groove_h = 5.4;

bowden_connector_d = 12;

mounting_plate_d = jhead_lip_d + 19;
mounting_plate_h = 5;
mounting_plate_screwsize = M3;
mounting_plate_screwhole_d = mounting_plate_screwsize + 0.3;
mounting_plate_screw_orbit_r = (mounting_plate_d + jhead_lip_d) / 4;

$fs = 0.4;
$fa = 1;

module round (r)
{
    offset (r = r)
    offset (r = -r)
    children ();
}

module slot_basic_shape ()
{
    linear_extrude (height = arm_thickness)
    round (2)
    round (-5)
    union () {
        circle (d = mounting_plate_d);

        for (a = [0:120:359])
        rotate (a, Z)
        intersection () {
            circle (d = effector_od);

            translate ([0, -arm_width / 2])
            square ([effector_od, arm_width]);
        }
    }
}

module place_effector_screwholes ()
{
    mcad_rotate_multiply (3, angle = 120)
    translate ([effector_screw_orbit_r, 0])
    children ();
}

module effector_screwholes ()
{
    place_effector_screwholes ()
    mcad_polyhole (d = effector_screwhole_d, h = 1000, center = true);
}

module effector_nutholes ()
{
    translate ([0, 0, -epsilon])
    place_effector_screwholes ()
    rotate (90, Z)
    mcad_nut_hole (size = effector_screwsize, tolerance = 0.1);
}

module place_mounting_plate_screwholes ()
{
    mcad_rotate_multiply (3, angle = 120)
    translate ([mounting_plate_screw_orbit_r, 0])
    children ();
}

module mounting_plate_screwholes ()
{
    place_mounting_plate_screwholes ()
    mcad_polyhole (d = mounting_plate_screwhole_d, h = 1000, center = true);
}

module mounting_plate_nutholes ()
{
    translate ([0, 0, -epsilon])
    place_mounting_plate_screwholes ()
    mcad_nut_hole (size = mounting_plate_screwsize, tolerance = 0.1);

}

module stretch (length = 100, axis = X)
{
    hull ()
    mcad_linear_multiply (2, separation = length, axis = axis)
    children ();
}

module jhead_groove_slot ()
{
    rotate (360 / 3 / 2, Z) {
        // groove inner diameter
        stretch ()
        mcad_polyhole (d = jhead_groove_d, h = 1000, center = true);

        // secondary lip
        translate ([0, 0, arm_thickness - jhead_lip_h - jhead_groove_h])
        stretch ()
        mcad_polyhole (d = jhead_lip_d, h = 2.7);
    }
}

module slot_piece ()
{
    difference () {
        slot_basic_shape ();
        jhead_groove_slot ();

        effector_screwholes ();
        effector_nutholes ();

        mounting_plate_screwholes ();
        mounting_plate_nutholes ();
    }
}

module top_plate ()
{
    difference () {
        mcad_tube (od = mounting_plate_d, id = bowden_connector_d,
            h = mounting_plate_h);

        // reduce this size by 0.1 for interference fit
        translate ([0, 0, -epsilon - 0.1])
        mcad_polyhole (d = jhead_lip_d, h = jhead_lip_h + epsilon);

        mounting_plate_screwholes ();
    }
}

%rotate (90, Z)
translate ([0, 0, arm_thickness])
platform ();

translate ([0, 0, arm_thickness])
top_plate ();
slot_piece ();

epsilon = 0.015;
