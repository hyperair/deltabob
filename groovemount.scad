include <MCAD/units/metric.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/fasteners/threads.scad>
use <MCAD/shapes/cylinder.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/array/along_curve.scad>
use <utils.scad>


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

bowden_tube_d = 4.5;
use_ptc = false;

// ptc settings
bowden_connector_d = 12;

// non-ptc settings
cap_nut_size = M4;
cap_thread_length = 10;
cap_thread_d = 16;
cap_thread_pitch = 2;
cap_thread_clearance = 0.3;
cap_supported_length = 5;

// don't modify
cap_thread_minor_d = cap_thread_d - cos (30) * cap_thread_pitch * 10 / 8;

cap_length = cap_thread_length + cap_supported_length - cap_thread_pitch;

mounting_plate_d = jhead_lip_d + 19;
mounting_plate_h = 5;
mounting_plate_screwsize = M3;
mounting_plate_screwhole_d = mounting_plate_screwsize + 0.3;
mounting_plate_screw_orbit_r = (mounting_plate_d + jhead_lip_d) / 4;

nut_tolerance = 0.01;

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
    mcad_nut_hole (size = effector_screwsize, tolerance = nut_tolerance);
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
    mcad_nut_hole (size = mounting_plate_screwsize, tolerance = nut_tolerance);

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
        translate ([0, 0, arm_thickness - jhead_groove_h])
        stretch ()
        mirror (Z)
        mcad_polyhole (d = jhead_lip_d, h = 1000);
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

module basic_top_plate ()
{
    difference () {
        cylinder (d = mounting_plate_d, h = mounting_plate_h);

        // reduce this size by 0.1 for interference fit
        translate ([0, 0, -epsilon - 0.1])
        mcad_polyhole (d = jhead_lip_d, h = jhead_lip_h + epsilon);

        mounting_plate_screwholes ();
    }
}

module top_plate_ptc ()
{
    difference () {
        basic_top_plate ();

        // hole for ptc
        translate ([0, 0, -epsilon])
        mcad_polyhole (d = bowden_connector_d,
            h = mounting_plate_h + epsilon * 2);
    }
}

module top_plate_nut ()
{
    difference () {
        union () {
            basic_top_plate ();

            relief = 1;

            translate ([0, 0, mounting_plate_h])
            difference () {
                metric_thread (
                    diameter = cap_thread_d,
                    pitch = cap_thread_pitch,
                    length = cap_thread_length
                );

                // chamfered entrance
                chamfer_depth = cap_thread_pitch;

                translate ([0, 0, cap_thread_length - chamfer_depth])
                difference () {
                    ccube ([cap_thread_d, cap_thread_d, chamfer_depth * 2],
                        center = X + Y);

                    cylinder (d1 = cap_thread_d,
                        d2 = cap_thread_d - chamfer_depth * 2,
                        h = chamfer_depth);
                }
            }

            // filleted base of thread
            translate ([0, 0, mounting_plate_h])
            filleted_cylinder (d = cap_thread_minor_d, h = relief,
                fillet_r = cap_thread_pitch);
        }

        // bowden tube hole
        translate ([0, 0, -epsilon])
        mcad_polyhole (d = bowden_tube_d,
            h = mounting_plate_h + cap_thread_length + epsilon * 2);

        // m4 nut hole (allow to freely rotate so we can fine-tune tube level)
        translate ([0, 0, mounting_plate_h + cap_thread_length + 0.1])
        mirror (Z)
        //mcad_nut_hole (size = cap_nut_size, tolerance = nut_tolerance);
        mcad_polyhole (
            d = mcad_metric_nut_ac_width (cap_nut_size) + nut_tolerance * 2,
            h = mcad_metric_nut_thickness (cap_nut_size)
        );
    }
}

module top_plate ()
{
    if (use_ptc)
    top_plate_ptc ();

    else
    top_plate_nut ();
}

module top_plate_cap ()
{
    wall_thickness = 2;

    difference () {
        union () {
            od = cap_thread_d + wall_thickness * 2;

            cylinder (d = od, h = cap_length);

            linear_extrude (height = cap_supported_length)
            round (r = 2)
            difference () {
                od2 = od + 10;
                circumference = od2 * PI;
                notch_d = 5;
                notches = round (circumference / notch_d / 2);

                circle (d = od2);

                for (a = [0:360/notches:359.99])
                rotate (a, Z)
                translate ([od2 / 2 + notch_d * .2, 0])
                circle (d = notch_d);
            }

            // fillets
            translate ([0, 0, cap_supported_length - epsilon])
            filleted_cylinder (d = od, h = 1, fillet_r = 1);
        }

        // thread
        translate ([0, 0, cap_supported_length])
        metric_thread (diameter = cap_thread_d + cap_thread_clearance,
            pitch = cap_thread_pitch,
            length = cap_thread_length + epsilon,
            internal = true);

        // chamfered entrance
        chamfer_depth = cap_thread_pitch;
        translate ([0, 0, cap_length + epsilon])
        mirror (Z)
        cylinder (d1 = cap_thread_minor_d + chamfer_depth * 2,
            d2 = cap_thread_minor_d,
            h = chamfer_depth);

        // hole for bowden tubep
        translate ([0, 0, -epsilon])
        mcad_polyhole (d = bowden_tube_d, h = 1000);
    }
}

translate ([0, 0, arm_thickness]) {
    top_plate ();

    %translate (
        [0, 0, mounting_plate_h + cap_thread_length + cap_supported_length])
    mirror (Z)
    !top_plate_cap ();

}
slot_piece ();


epsilon = 0.015;
