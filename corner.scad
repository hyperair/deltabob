use <MCAD/array/mirror.scad>
use <MCAD/shapes/2Dshapes.scad>
include <MCAD/units/metric.scad>

include <configuration/corner.scad>
include <configuration/delta.scad>
include <configuration/extrusions.scad>
include <configuration/resolution.scad>

use <utils.scad>

module corner_shape ()
{
    h_profile = extrusions_h_profile;
    v_profile = extrusions_v_profile;

    median_line_length = (
        (h_profile[0] / cos(30) + corner_wall_thickness) * 2 +
        v_profile[0]
    );

    median_radial_length_to_edge = v_profile[1] + corner_wall_thickness;

    trapezoid_base = _corner_find_trapezoid_base (median_line_length,
                                                  -median_radial_length_to_edge);
    trapezoid_h = (
        corner_wall_thickness +
        v_profile[1] +
        corner_wall_thickness +
        corner_cavity_axial_length +
        corner_wall_thickness
    );

    /* list of trapezoid y coords */
    y0 = -(v_profile[1] + corner_wall_thickness);  // outer surface
    y1 = -v_profile[1];                            // outer surface of v profile
    y2 = 0;                     // median line; aka inner surface of v profile
    y3 = corner_wall_thickness; // outer surface of trapezoidal cavity
    y4 = y3 + corner_cavity_axial_length;
    y5 = y4 + corner_wall_thickness;

    difference () {
        round (20)
        translate ([0, y0])
        trapezoid (
            bottom = _corner_find_trapezoid_base (
                top = median_line_length,
                h = -median_radial_length_to_edge
            ),
            height = (y5 - y0) * 2,
            left_angle = -60,
            right_angle = -60
        );

        /* v extrusion */
        translate ([0, -v_profile[1] / 2])
        square (v_profile, center = true);

        /* h extrusions */
        mcad_mirror_duplicate ()
        translate ([v_profile[0] / 2 + corner_wall_thickness, 0])
        rotate (-30)
        square ([h_profile[0] + epsilon, (y5 - y0) * 2]);

        /* cavity */
        round (5)
        translate ([0, y3])
        trapezoid (
            bottom = corner_cavity_trapezoid_top,
            height = corner_cavity_axial_length,
            left_angle = -60,
            right_angle = -60
        );

        /* back opening */
        round (5)
        translate ([0, y5])
        trapezoid (
            bottom = _corner_find_trapezoid_base (
                top = corner_cavity_trapezoid_top,
                h = y5 - y3
            ),
            height = 1000,
            left_angle = -60,
            right_angle = -60
        );

        /* crop the size of the arms */
        mcad_mirror_duplicate ()
        translate ([(v_profile[0] / 2 +
                     corner_wall_thickness -
                     corner_diagonal_wall_thickness -
                     epsilon),
                    0])
        rotate (-30)
        translate ([0, corner_arm_length])
        square ([corner_wall_thickness + h_profile[0] + epsilon * 2, 1000]);
    }
}

module corner_bottom ()
{
    linear_extrude (height = corner_bottom_height)
    corner_shape ();
}

corner_bottom ();
