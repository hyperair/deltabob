use <MCAD/array/along_curve.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/cylinder.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>

include <MCAD/units/metric.scad>

wall_thickness = 3;
default_screwsize = M3;
default_screwhole_d = default_screwsize + 0.3;

effector_od = 60;
effector_id = 40;
effector_h = 8;
effector_screwsize = M4;
effector_screwhole_d = effector_screwsize + 0.3;
effector_screw_orbit_r = 25;

microswitch_width = 12.8;
microswitch_hole_separation = 6.5;
microswitch_hole_base_offset = 5.2;
microswitch_hole_elevation = 8;
microswitch_screwsize = 2;
microswitch_hole_d = microswitch_screwsize + 0.3;
microswitch_button_offset = 0;

probe_nozzle_xy_offset = 50;
probe_offset_from_edge = probe_nozzle_xy_offset - effector_od / 2;
probe_height = microswitch_hole_elevation + microswitch_hole_base_offset;
probe_height2 = 25;
probe_d = 3;

retractable_height = 30;
retractable_width = 15;
retractable_depth = probe_d + wall_thickness * 2;

foot_thickness = 3;
grip_thickness = 2;

spring_d = 1.3;

$fs = 0.4;
$fa = 1;

module foot ()
{
    translate ([-effector_od / 2, 0, 0])
    intersection () {
        difference () {
            mcad_tube (od = effector_od + wall_thickness * 2,
                id = effector_id - wall_thickness * 2,
                h = foot_thickness + grip_thickness);

            translate ([0, 0, -epsilon])
            mcad_tube (od = effector_od, id = effector_id,
                h = grip_thickness);

            // effector screwhole
            translate ([effector_screw_orbit_r, 0, 0])
            mcad_polyhole (d = effector_screwhole_d, h = 1000);
        }

        ccube ([10000, retractable_width, 1000], center = Y);
    }
}

module retractable_body ()
{
    module slot ()
    {
        hull () {
            mcad_linear_multiply (no = 2, separation = 1000, axis = X)
            cylinder (d = probe_d, h = 1000);
        }
    }

    difference () {
        radius = 1;
        translate ([radius, 0, retractable_height / 2])
        mcad_rounded_box (
            size = [retractable_depth + radius * 2,
                retractable_width, retractable_height],
            radius = radius,
            center = true,
            sidesonly = true
        );

        // flatten one side
        translate ([retractable_depth / 2, 0])
        ccube ([1000, 1000, 1000], center = Y + Z);

        translate ([0, microswitch_button_offset]) {
            // probe hole
            mcad_polyhole (d = probe_d, h = 1000, center = true);

            translate ([0, 0, probe_height])
            slot ();

            translate ([0, 0, probe_height2])
            hull () {
                slot ();

                rotate (45, Z)
                slot ();
            }
        }
    }
}

module microswitch_screwholes ()
{
    mcad_linear_multiply (no = 2, separation = microswitch_hole_separation,
        axis = Y)
    translate ([0, -microswitch_hole_separation / 2, microswitch_hole_elevation])
    rotate (90, Y) {
        cylinder (d = microswitch_hole_d, h = 1000, center = true);

        translate ([0, 0, -retractable_depth / 2 - epsilon])
        mcad_nut_hole (size = microswitch_screwsize);
    }
}

module place_spring_screwhole ()
{
    translate ([
            0,
            -(retractable_width + probe_d)/ 4 + microswitch_button_offset / 2,
            probe_height2 - default_screwhole_d / 2 - 2
        ])
    children ();
}

module spring_screwhole ()
{
    place_spring_screwhole ()
    rotate (90, Y) {
        cylinder (d = default_screwhole_d, h = 1000, center = true);

        translate ([0, 0, -retractable_depth / 2 - epsilon])
        mcad_nut_hole (size = default_screwsize);
    }
}

module spring_hole ()
{
    place_spring_screwhole ()
    translate ([0, 0, default_screwhole_d / 2 + 4])
    rotate (90, Y)
    cylinder (d = spring_d, h = 1000, center = true);
}

module retractable ()
{
    module place_body ()
    translate ([probe_offset_from_edge, 0])
    children ();

    difference () {
        union () {
            place_body ()
            retractable_body ();

            foot ();

            // joint
            ccube ([probe_offset_from_edge - (retractable_depth - probe_d) / 2,
                    retractable_width,
                    foot_thickness + grip_thickness],
                center = Y);
        }

        place_body () {
            microswitch_screwholes ();
            spring_screwhole ();
            spring_hole ();
        }
    }
}

retractable ();
