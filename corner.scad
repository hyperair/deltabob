use <MCAD/array/mirror.scad>
use <MCAD/shapes/2Dshapes.scad>
include <MCAD/units/metric.scad>

/* include <configuration/corner.scad> */
include <configuration/delta.scad>
/* include <configuration/extrusions.scad> */
include <configuration/resolution.scad>

use <utils.scad>

module slot_interface_shape (type, h)
{
    linear_extrude (height = h)
    translate ([0, -epsilon])
    if (type == "v")
        trapezoid (
            bottom = 9,
            top = 6,
            height= 1.75
        );
    else
        translate ([0, 1.75 / 2])
        square (size = [5, 1.75], center = true);
}

module place_slots (slots, size, sides)
{
    xlen = size[1];
    ylen = size[0];

    xslots = slots[1];
    yslots = slots[0];

    up = len (search ("u", sides)) > 0;
    down = len (search ("d", sides)) > 0;
    left = len (search ("l", sides)) > 0;
    right = len (search ("r", sides)) > 0;

    translate ([xlen, ylen] / -2) {
        for (xslot = xslots) {
            /* bottom slots */
            if (down)
            translate ([xslot, 0])
            children ();

            /* top slots */
            if (up)
            translate ([0, ylen])
            mirror (Y)
            translate ([xslot, 0])
            children ();
        }

        for (yslot = yslots) {
            if (left)
            translate ([0, yslot])
            rotate (-90, Z)
            children ();

            if (right)
            translate ([xlen, 0])
            mirror (X)
            translate ([0, yslot])
            rotate (-90, Z)
            children ();
        }
    }
}

module aluex_slot_interface (aluex, h, slot_sides = "udlr")
{
    place_slots (
        slots = aluex_slots (aluex),
        size = aluex_size (aluex),
        sides = slot_sides
    )
    slot_interface_shape (type = aluex_slot_profile (aluex),
                          h = h);
}

module corner_shape (corner_options)
{
    h_aluex = corner_get_h_aluex (corner_options);
    v_aluex = corner_get_v_aluex (corner_options);
    wall_thickness = corner_get_wall_thickness (corner_options);

    h_profile = aluex_size (h_aluex);
    v_profile = [
        corner_get_v_aluex_circumferential (corner_options),
        corner_get_v_aluex_radial (corner_options)
    ];

    median_line_length = corner_get_median_line_length (corner_options);
    cavity_width = corner_get_cavity_width (corner_options);
    cavity_trapezoid_top = corner_get_cavity_trapezoid_top (corner_options);

    /* list of trapezoid y coords */
    y0 = -(v_profile[1] + wall_thickness);  // outer surface
    y1 = -v_profile[1];                            // outer surface of v profile
    y2 = 0;                     // median line; aka inner surface of v profile
    y3 = wall_thickness; // outer surface of trapezoidal cavity
    y4 = y3 + cavity_width;
    y5 = y4 + wall_thickness;

    difference () {
        round (20)
        translate ([0, y0])
        trapezoid (
            bottom = corner_find_trapezoid_base (
                top = median_line_length,
                h = y0
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
        translate ([v_profile[0] / 2 + wall_thickness, 0])
        rotate (-30)
        square ([h_profile[0] + epsilon, (y5 - y0) * 2]);

        /* cavity */
        round (5)
        translate ([0, y3])
        trapezoid (
            bottom = cavity_trapezoid_top,
            height = cavity_width,
            left_angle = -60,
            right_angle = -60
        );

        /* back opening */
        round (5)
        translate ([0, y5])
        trapezoid (
            bottom = corner_find_trapezoid_base (
                top = cavity_trapezoid_top,
                h = y5 - y3
            ),
            height = 1000,
            left_angle = -60,
            right_angle = -60
        );

        /* crop the size of the arms */
        mcad_mirror_duplicate ()
        translate ([(v_profile[0] / 2 +
                     wall_thickness -
                     epsilon),
                    0])
        rotate (-30)
        translate ([-corner_get_diagonal_wall_thickness (corner_options),
                    corner_get_arm_length (corner_options)])
        square ([wall_thickness + h_profile[0] + epsilon * 2, 1000]);
    }
}

module corner_blank (corner_blank_options)
{
    height = corner_get_height (corner_blank_options);
    v_circumferential = corner_get_v_aluex_circumferential (
        corner_blank_options
    );
    wall_thickness = corner_get_wall_thickness (corner_blank_options);

    h_height = corner_get_h_aluex_height (corner_blank_options);
    h_aluex_positions = [
        h_height / 2,
        height - h_height / 2
    ];

    /* basic corner shape */
    linear_extrude (height = height)
    corner_shape (corner_blank_options);

    /* v slot interface */
    translate ([0, -corner_get_v_aluex_radial (corner_blank_options) / 2])
    aluex_slot_interface (corner_get_v_aluex (corner_blank_options), height);

    /* h slot interface */
    mcad_mirror_duplicate (X)
    for (h_aluex_pos = h_aluex_positions)
        translate ([0, 0, h_aluex_pos])
        translate ([(v_circumferential / 2 + wall_thickness - epsilon), 0])
        rotate (-30, Z)
        rotate (90, Z)
        translate ([0, -corner_get_h_aluex_width (corner_blank_options) / 2])
        rotate (90, Y)
        translate ([0, 0, -epsilon])
        aluex_slot_interface (
            aluex = corner_get_h_aluex (corner_blank_options),
            h = corner_get_arm_length (corner_blank_options),
            slot_sides = "u"
        );

    /* screwholes */
}

module corner_bottom (corner_bottom_options)
{
    corner_blank (corner_bottom_get_blank (corner_bottom_options));

    /* motor holes */
}

corner_bottom (delta_get_bottom_corner (deltabob));
