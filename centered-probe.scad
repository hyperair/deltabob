include <MCAD/units/metric.scad>
use <MCAD/array/mirror.scad>
use <MCAD/shapes/cylinder.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <utils.scad>

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
microswitch_thickness = 5;
microswitch_hole_separation = 6.5;
microswitch_hole_base_offset = 5.2;
microswitch_elevation = -1;
microswitch_screwsize = 2;
microswitch_hole_d = microswitch_screwsize + 0.3;
microswitch_button_offset = 7.2; // offset from center of switch

foot_thickness = 2;
grip_thickness = 4;

probe_width = 15;
probe_arm_length = 80;
probe_arm_thickness = 8;
probe_arm_xy_offset = 60;

$fs = 0.4;
$fa = 1;

module probe_foot ()
{
    // translate ([-effector_od / 2, 0, 0])
    difference () {
        translate ([0, 0, -grip_thickness])
        ccube (
            [
                probe_arm_xy_offset,
                probe_width,
                foot_thickness + grip_thickness
            ],
            center = Y
        );

        // effector ring
        mirror (Z)
        translate ([0, 0, -epsilon])
        mcad_tube (od = effector_od, id = effector_id - 0.3,
            h = 1000);

        // effector center hole
        cylinder (d = effector_id - wall_thickness * 2, h = 1000,
            center = true);

        // effector screwhole
        translate ([effector_screw_orbit_r, 0, 0])
        mcad_polyhole (d = effector_screwhole_d, h = 1000);
    }
}

module probe_vertical_arm ()
{
    translate ([probe_arm_xy_offset, 0, foot_thickness])
    mirror (Z)
    ccube (
        size = [
            probe_arm_thickness,
            probe_width,
            probe_arm_length + foot_thickness + epsilon
        ],
        center = Y
    );
}

module probe_switch_holder ()
{
    translate ([0, 0, -probe_arm_length])
    mirror (Z)
    difference () {
        translate ([microswitch_button_offset - microswitch_width / 2, 0, 0])
        ccube (
            size = [
                (probe_arm_xy_offset + probe_arm_thickness +
                    microswitch_width / 2 - microswitch_button_offset),
                probe_width,
                probe_arm_thickness
            ],
            center = Y
        );

        // hole for sticking microswitch in
        translate ([microswitch_button_offset, 0, 0])
        stretch (direction = Y, distance = 100)
        ccube (
            size = [
                microswitch_width + epsilon * 2,
                microswitch_thickness + 0.3,
                1000
            ],
            center = X + Y + Z
        );

        // microswitch mounting hole
        translate ([microswitch_button_offset, 0, 0])
        mcad_mirror_duplicate (X)
        translate ([
                microswitch_hole_separation / 2,
                0,
                probe_arm_thickness - microswitch_hole_base_offset -
                microswitch_elevation
            ])
        rotate (90, X)
        mcad_polyhole (d = microswitch_hole_d, h = 1000, center = true);
    }
}

module probe ()
{
    probe_foot ();
    probe_vertical_arm ();
    probe_switch_holder ();
}

probe ();
