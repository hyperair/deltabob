use <MCAD/array/along_curve.scad>
use <MCAD/array/mirror.scad>
use <MCAD/shapes/boxes.scad>

use <lib/fillet.scad>

include <MCAD/units/metric.scad>
include <e3dv5.scad>

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

%translate ([0, 0, -(e3dv6_heaterblock_h + e3dv5_transition_length + e3dv6_nozzle_outer_h)])
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


// render ()
difference () {
    // outer shape
    render ()
    union () {
        basic_fanduct_shape ();

        fanduct_screw_pillars ();
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

    place_fan ()
    mcad_mirror_duplicate (Y)
    for (x = [1, -1] * 33 / 2)
        translate ([x, 33 / 2, 10])
        rotate (90, Z)
        mirror (Z)
        screwhole (size = 3, length = 30, nut_projection = "axial");

    // hotend area
    cylinder (d = hotend_sink_d, h = hotend_sink_h);

    // exit channel
    mirror (X)
    translate ([0, 0, -epsilon])
    ccube ([hotend_sink_d, exit_channel_width, hotend_sink_h], center = Y);

    // actual fan
    place_fan ()
    linear_extrude (height = fan_inset_depth + epsilon)
    rounded_square ([1, 1] * fan_width, fan_corner_radius);

    // show which side
    *mirror (X)
    ccube ([1000, 1000, 1000], center = Y + Z);
}
