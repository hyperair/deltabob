use <MCAD/array/along_curve.scad>
use <MCAD/array/mirror.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/fasteners/threads.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>

use <lib/fillet.scad>

include <MCAD/units/metric.scad>
include <vitamins/e3dv5.scad>

fan_screw_distance = 33;
fan_width = 40;
fan_diameter = 38.8;
fan_corner_radius = 3.5;

fan_inset_depth = 1;
fan_offset = 7;

wall_thickness = 1.5;

fan_outer_width = fan_width + wall_thickness * 2;

hotend_sink_d = 25;
hotend_sink_h = 31.8;
hotend_whole_sink_h = 50.1;

exit_channel_width = 0.6 * hotend_sink_d;

hotend_cap_thickness = 10;
hotend_cap_arm_width = 15;
effector_d = 95;
effector_h = 10;
bowden_tube_d = 4.5;
bowden_nut_size = M4;

*%translate ([0, 0, -(e3dv6_heaterblock_h + e3dv5_transition_length + e3dv6_nozzle_outer_h)])
e3dv5 ();

function sq (x) = x * x;
function chord_length (radius, normal_length) = (
    sqrt (sq (radius) - sq (normal_length))
);

module rounded_square (size, r)
{
    hull ()
    for (x = [-1, 1] * (size[0]/2 - r))
        for (y = [-1, 1] * (size[1]/2 - r))
            translate ([x, y])
            circle (r = r);
}


module place_fan ()
{
    translate ([hotend_sink_d / 2 + fan_offset, 0, fan_outer_width / 2])
    rotate (90, Y)
    children ();
}

module basic_fanduct_shape ()
{
    render ()
    hull () {
        // basic fan shape
        place_fan ()
        linear_extrude (height = fan_inset_depth)
        rounded_square ([1, 1] * fan_outer_width, fan_corner_radius + wall_thickness);

        // encompass the fan
        cylinder (d = hotend_sink_d + wall_thickness * 2,
                  h = hotend_whole_sink_h);
    }
}

module fanduct_screw_pillars ()
{
    screw_offset = fan_screw_distance / 2;

    module single_pillar ()
    {
        place_fan ()
        translate ([0, screw_offset])
        hull ()
        mcad_linear_multiply (no = 2, separation = 8, axis = -Y)
        mirror (Z)
        cylinder (d = 8, h = 25);
    }

    mcad_mirror_duplicate (Y)
    for (z = [1, -1] * screw_offset) {
        render ()
        fillet (r = 3, steps = 10, include = false) {
            basic_fanduct_shape ();

            translate ([0, 0, z])
            single_pillar ();
        }

        translate ([0, 0, z])
        single_pillar ();
    }
}

module place_effector_prong ()
{
    for (i = [0:3]) {
        rotate (i * 120 + 60, Z)
        children ();
    }
}

module place_hotend_cap ()
{
    translate ([0, 0, hotend_whole_sink_h])
    children ();
}

module hotend_cap ()
{
    place_hotend_cap ()
    difference () {
        union () {
            linear_extrude (height = hotend_cap_thickness)
            round (5)
            round (-5)
            union () {
                circle (d = hotend_sink_d + wall_thickness * 2);

                intersection () {
                    place_effector_prong ()
                    translate ([0, -hotend_cap_arm_width / 2])
                    square ([100, hotend_cap_arm_width]);

                    circle (d = effector_d);
                }
            }

            // threaded bowden coupler
            translate ([0, 0, hotend_cap_thickness - epsilon])
            metric_thread (
                diameter = 16,
                pitch = 2,
                length = 10
            );

        }

        // taper for the thread
        translate ([0, 0, hotend_cap_thickness + 10 - 2])
        difference () {
            ccube ([20, 20, 20], center = X + Y);

            translate ([0, 0, -epsilon])
            cylinder (d1 = 16, d2 = 16 - 2*2, h = 2);
        }

        // bowden hole
        translate ([0, 0, -epsilon])
        cylinder (d = bowden_tube_d + 0.3,
                  h = 100);

        // bowden nut trap
        nut_thickness = mcad_metric_nut_thickness (bowden_nut_size);
        translate ([0, 0, hotend_cap_thickness + 10 + 0.5 - nut_thickness])
        hull ()
        mcad_linear_multiply (no = 2, separation = 100, axis = +Z)
        mcad_nut_hole (size = bowden_nut_size);
    }
}

module effector ()
{
    module base_ring ()
    {
        translate ([0, 0, -effector_h])
        difference () {
            cylinder (d = effector_d, h = effector_h);

            translate ([0, 0, -epsilon])
            cylinder (d = effector_d - 30, h = effector_h + epsilon * 2);
        }
    }

    module single_prong_shape ()
    {
        render ()
        translate ([0, 0, -epsilon])
        linear_extrude (height = hotend_whole_sink_h)
        difference () {
            round (5)
            intersection () {
                translate ([0, -hotend_cap_arm_width / 2])
                square ([50, hotend_cap_arm_width]);

                circle (d = effector_d);
            }
            circle (d = effector_d - 30);
        }
    }

    module single_prong ()
    {
        fillet (r = 5, steps = 10, include = false) {
            single_prong_shape ();

            mirror (Z)
            cylinder (d = effector_d, h = 10);
        }

        single_prong_shape ();
    }

    base_ring ();

    render ()
    difference () {
        place_effector_prong ()
        render ()
        single_prong ();

        translate ([0, 0, -10])
        cylinder (d = effector_d - 30, h = 15);
    }
}

render ()
difference () {
    // outer shape
    render ()
    union () {
        basic_fanduct_shape ();
        fanduct_screw_pillars ();
        hotend_cap ();

        effector ();
    }

    // air channel
    render ()
    hull () {
        place_fan ()
        cylinder (d = fan_diameter, h = fan_inset_depth + epsilon);

        chord_normal = 0.4 * hotend_sink_d/2;
        translate ([chord_normal, 0, 0])
        ccube (
            [epsilon,
             chord_length (hotend_sink_d/2, chord_normal),
             hotend_sink_h],
            center = X + Y
        );
    }

    // exit channel
    mirror (X)
    translate ([0, 0, -epsilon])
    ccube ([hotend_sink_d, exit_channel_width, hotend_sink_h], center = Y);

    // fan screwholes
    place_fan ()
    mcad_mirror_duplicate (Y)
    for (x = [1, -1] * 33 / 2)
        translate ([x, 33 / 2, 10])
        rotate (90, Z)
        mirror (Z)
        screwhole (size = 3, length = 30, nut_projection = "axial");

    // hotend cap screwholes
    place_hotend_cap ()
    place_effector_prong () {
        /* rotate (60, Z) */
        translate ([16/2 + 1 + 3/2, 0, hotend_cap_thickness])
        mirror (X)
        render ()
        intersection () {
            mirror (Z)
            screwhole (size = 3,
                       length = hotend_cap_thickness + 2,
                       nut_projection = "radial",
                       screw_extra_length = 5);

            cylinder (d = 16, h = 9999, center = true);
        }
    }

    // effector screwholes
    place_hotend_cap ()
    place_effector_prong () {
        translate (
            [effector_d / 2 - hotend_cap_arm_width / 2,
             0,
             hotend_cap_thickness]
        )
        mirror (Z)
        screwhole (size = 3,
                   length = (hotend_whole_sink_h + hotend_cap_thickness +
                             effector_h -
                             mcad_metric_nut_thickness (3) -
                             3),
                   nut_projection = "axial");
    }

    // hotend area
    stacked_cylinder (
        [
            [16, 5],
            [12, 5.4],
            [16, 9],
            [hotend_sink_d, hotend_sink_h]
        ]
    );
    cylinder (d = 16, h = hotend_sink_h + 9);

    // actual fan
    place_fan ()
    linear_extrude (height = fan_inset_depth + epsilon)
    rounded_square ([1, 1] * fan_width, fan_corner_radius);

    // show which side
    *mirror (X)
    ccube ([1000, 1000, 1000], center = Y + Z);
}
