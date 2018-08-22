use <MCAD/shapes/polyhole.scad>

include <MCAD/motors/stepper.scad>
include <MCAD/units/metric.scad>

use <corner.scad>
use <utils.scad>

include <configuration/delta.scad>
include <configuration/resolution.scad>

module corner_bottom_place_motor (corner_bottom_options)
{
    motor = corner_bottom_get_motor (corner_bottom_options);
    width = motorWidth (motor);
    blank = corner_bottom_get_blank (corner_bottom_options);
    corner_height = corner_get_height (blank);

    wall_thickness = corner_get_wall_thickness (blank);
    motor_y = corner_get_cavity_width (blank) + wall_thickness * 2;

    translate ([0, motor_y, corner_height - width / 2])
    rotate (90, X)
    children ();
}

module corner_bottom (corner_bottom_options)
{
    corner_blank_options = corner_bottom_get_blank (corner_bottom_options);

    render ()
    difference () {
        corner_blank (corner_blank_options);

        /* motor holes */
        motor = corner_bottom_get_motor (corner_bottom_options);
        screw_spacing = motorScrewSpacing (motor);
        wall_thickness = corner_get_wall_thickness (corner_blank_options);

        corner_bottom_place_motor (corner_bottom_options)
        translate ([0, 0, -epsilon])
        linear_extrude (height = wall_thickness + epsilon * 2) {
            for (x = [-0.5, 0.5] * screw_spacing)
                for (y = [-0.5, 0.5] * screw_spacing)
                    translate ([x, y])
                    mcad_polyhole (d = 3.3);

            mcad_polyhole (d = lookup (NemaRoundExtrusionDiameter, motor));
        }
    }
}

corner_bottom (delta_get_bottom_corner (deltabob));
