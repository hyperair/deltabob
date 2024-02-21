use <MCAD/array/along_curve.scad>
use <MCAD/shapes/3Dshapes.scad>
include <MCAD/units/metric.scad>

include <../configuration/delta.scad>

use <../lib/delta.scad>
use <../lib/print-fan-mount.scad>
use <../lib/hotend.scad>
use <../fan-mount.scad>
use <../effector.scad>
use <../groovemount.scad>

$fs = 0.4;
$fa = 1;

module effector_assembly(delta)
{
    hotend = delta_get_hotend (delta);
    hotend_whole_sink_h = hotend_get_whole_sink_h (hotend);

    effector = delta_get_effector (delta);
    effector_prong_height = effector_get_prong_height (effector);

    groovemount = delta_get_groovemount (delta);

    print_colour = delta_get_effector_print_colour (delta);

    translate ([0, 0, 14.1]) {
        color (print_colour)
        // import ("../effector.stl");
        effector (effector);

        rotate ([0, 0, -30 + 180])
        translate ([0, 0, -hotend_whole_sink_h + effector_prong_height])
        union () {
            color (print_colour) {
                // import ("groovemount-assembly.stl");
                groovemount_base_shape (groovemount);
                groovemount_hotend_cap (groovemount, effector);
            }

            /* fan */
            %translate ([24, 0, 21])
             rotate ([0, -90, 0])
             color("#333")
             mcad_rounded_cube ([40, 40, 10], radius=3, sidesonly=true, center=true);

            %translate ([0, 0, -19])
             import ("../vitamins/e3dv5.stl");
        }
    }

    fan_mount_opts = delta_get_print_fan_mount (delta);
    fan_mount_jaw_length = print_fan_mount_get_jaw_length (fan_mount_opts);
    fan_mount_jaw_angle = print_fan_mount_get_jaw_angle (fan_mount_opts);
    fan_mount_jaw_y_offset = print_fan_mount_get_jaw_y_offset (fan_mount_opts);
    fan_mount_base_thickness = print_fan_mount_get_base_thickness (fan_mount_opts);

    mcad_rotate_multiply (3, axis = Z)
    translate ([2, 50 + fan_mount_jaw_y_offset, 28])
    rotate (130, X)
    translate ([0, 0, -fan_mount_jaw_length])
    rotate (90 - fan_mount_jaw_angle, X)
    translate ([0, -20]) {
        color (print_colour)
        // import ("../fan-mount.stl");
        render()
        fan_mount (fan_mount_opts);

        translate ([0, 0, 4])
        color("#333")
        mcad_rounded_cube ([40, 40, 10], radius=3, sidesonly=true, center=X + Y);
    }
}

effector_assembly (deltabob);
