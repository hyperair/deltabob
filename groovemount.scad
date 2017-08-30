use <MCAD/array/along_curve.scad>
use <MCAD/array/mirror.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/boxes.scad>
include <MCAD/units/metric.scad>

use <lib/fillet.scad>
use <lib/delta.scad>
use <lib/groovemount.scad>
include <configuration/delta.scad>

use <utils.scad>

$fs = 0.4;
$fa = 1;


module place_fan (options)
{
    hotend = groovemount_get_hotend (options);
    hotend_sink_d = hotend_get_sink_d (hotend);

    fan_outer_width = groovemount_get_fan_outer_width (options);
    fan_offset = groovemount_get_fan_offset (options);

    translate ([hotend_sink_d / 2 + fan_offset, 0, fan_outer_width / 2])
    rotate (90, Y)
    children ();
}

module basic_fanduct_shape (options)
{
    fan_inset_depth = groovemount_get_fan_inset_depth (options);
    wall_thickness = groovemount_get_wall_thickness (options);
    fan_outer_width = groovemount_get_fan_outer_width (options);

    fan = groovemount_get_fan (options);
    fan_corner_radius = axial_fan_get_corner_radius (fan);

    hotend = groovemount_get_hotend (options);
    hotend_sink_d = hotend_get_sink_d (hotend);
    hotend_whole_sink_h = hotend_get_whole_sink_h (hotend);

    render ()
    hull () {
        // basic fan shape
        place_fan (options)
        linear_extrude (height = fan_inset_depth)
        rounded_square ([1, 1] * fan_outer_width,
                        fan_corner_radius + wall_thickness);

        // encompass the fan
        cylinder (d = hotend_sink_d + wall_thickness * 2,
                  h = hotend_whole_sink_h);
    }
}

module hotend (options)
{
    sink_d = hotend_get_sink_d (options);
    sink_h = hotend_get_sink_h (options);
    groove_profile = hotend_get_groove_profile (options);

    translate ([0, 0, -epsilon])
    stacked_cylinder (concat (groove_profile, [[sink_d, sink_h]]));
    // cylinder (d = 16, h = sink_h + 9);
}

module groovemount_screw_pillars (options)
{
    fan = groovemount_get_fan (options);
    fan_screw_distance = axial_fan_get_screw_distance (fan);

    screw_offset = fan_screw_distance / 2;

    module single_pillar ()
    {
        place_fan (options)
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
            basic_fanduct_shape (options);

            translate ([0, 0, z])
            single_pillar ();
        }

        translate ([0, 0, z])
        single_pillar ();
    }
}

module groovemount_fan_screwholes (options)
{
    fan = groovemount_get_fan (options);
    fan_screw_distance = axial_fan_get_screw_distance (fan);
    screw_offset = fan_screw_distance / 2;

    place_fan (options)
    mcad_mirror_duplicate (Y)
    for (x = [1, -1] * screw_offset)
        translate ([x, screw_offset, 10])
        rotate (90, Z)
        mirror (Z)
        screwhole (size = 3, length = 30, nut_projection = "axial");
}

module groovemount_air_channel (options)
{
    fan = groovemount_get_fan (options);
    fan_inset_depth = groovemount_get_fan_inset_depth (options);
    fan_d = axial_fan_get_d (fan);

    hotend = groovemount_get_hotend (options);
    hotend_sink_d = hotend_get_sink_d (hotend);
    hotend_sink_h = hotend_get_sink_h (hotend);

    exit_channel_width = groovemount_get_exit_channel_width (options);

    // air channel
    render ()
    hull () {
        place_fan (options)
        cylinder (d = fan_d, h = fan_inset_depth + epsilon);

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
}

module groovemount_fan_inset (options)
{
    fan = groovemount_get_fan (options);
    width = axial_fan_get_width (fan);
    thickness = axial_fan_get_thickness (fan);
    radius = axial_fan_get_corner_radius (fan);

    place_fan (options)
    translate ([0, 0, thickness / 2])
    mcad_rounded_box ([width, width, thickness], radius = radius,
                      sidesonly = true, center = true);
}

module groovemount_base_shape (options)
{
    hotend = groovemount_get_hotend (options);

    render ()
    difference () {
        union () {
            basic_fanduct_shape (options);
            groovemount_screw_pillars (options);
        }

        hotend (hotend);

        groovemount_fan_inset (options);
        groovemount_air_channel (options);
        groovemount_fan_screwholes (options);
    }
}


groovemount_base_shape (delta_get_groovemount (deltabob));
