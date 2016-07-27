use <MCAD/array/mirror.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

include <configuration/delta.scad>
include <configuration/resolution.scad>
include <MCAD/motors/stepper.scad>

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

module place_slots (aluex, sides)
{
    size = aluex_size (aluex);
    slots = aluex_slots (aluex);

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
        aluex = aluex,
        sides = slot_sides
    )
    slot_interface_shape (type = aluex_slot_profile (aluex), h = h);
}

/**
 * Places children where the v aluex is on the corner. Only translates on the XY
 * plane. v aluex is expected to be centered.
 */
module corner_place_v_aluex (corner_blank)
{
    orientation = corner_get_v_aluex_orientation (corner_blank);
    rotation = (orientation == "radial") ? 90 : 0;

    translate ([0, -corner_get_v_aluex_radial (corner_blank) / 2])
    rotate (rotation, Z)
    children ();
}

/**
 * Places children where the v aluex is on the corner. Only translates on the XY
 * plane. v aluex is expected to be centered.
 */
module corner_place_h_aluex_xy (corner_blank)
{
    v_circumferential = corner_get_v_aluex_circumferential (corner_blank);
    wall_thickness = corner_get_wall_thickness (corner_blank);

    mcad_mirror_duplicate (X)
    translate ([v_circumferential / 2 + wall_thickness, 0])
    rotate (-30)
    children ();
}

module aluex_screwhole (aluex, h, h_capscrew)
{
    h_below = aluex_size (aluex)[0] / 2;

    /* aluex is at Z<0 */
    /* actual hole */
    translate ([0, 0, -h_below - epsilon])
    mcad_polyhole (d = 5.3, h = h + h_below + epsilon);

    /* capscrew head */
    if (h_capscrew)
        translate ([0, 0, h])
        mcad_polyhole (d = 8.8, h = h_capscrew);

    /* relief for tnut */
    mirror (Z)
    ccube ([20, 15, 5], center = X + Y);
}

module corner_place_h_aluex (corner_blank)
{
    height = corner_get_height (corner_blank);
    h_height = corner_get_h_aluex_height (corner_blank);
    num = corner_get_h_aluex_num (corner_blank);
    separation = corner_get_h_aluex_separation (corner_blank);
    h_aluex_positions = [
        for (i = [0:num-1])
            h_height / 2 + (separation + h_height) * i
    ];

    for (h_aluex_pos = h_aluex_positions)
        translate ([0, 0, h_aluex_pos])
        corner_place_h_aluex_xy (corner_blank)
        rotate (90, Z)
        translate ([0, -corner_get_h_aluex_width (corner_blank) / 2])
        rotate (90, Y)
        children ();
}

module corner_shape (corner_options)
{
    h_aluex = corner_get_h_aluex (corner_options);
    v_aluex = corner_get_v_aluex (corner_options);
    v_size = aluex_size (v_aluex);

    wall_thickness = corner_get_wall_thickness (corner_options);

    h_profile = aluex_size (h_aluex);
    v_profile = [v_size[1], v_size[0]];
    v_radial = corner_get_v_aluex_radial (corner_options);
    v_circumferential = corner_get_v_aluex_circumferential (corner_options);

    median_line_length = corner_get_median_line_length (corner_options);
    cavity_width = corner_get_cavity_width (corner_options);
    cavity_trapezoid_top = corner_get_cavity_trapezoid_top (corner_options);

    /* list of trapezoid y coords */
    y0 = -(v_radial + wall_thickness);  // outer surface
    y1 = -v_radial;                            // outer surface of v profile
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
        corner_place_v_aluex (corner_options)
        square (v_profile, center = true);

        /* h extrusions */
        corner_place_h_aluex_xy (corner_options)
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
        translate ([(v_circumferential / 2 + wall_thickness - epsilon), 0])
        rotate (-30)
        translate ([-corner_get_diagonal_wall_thickness (corner_options),
                    corner_get_arm_length (corner_options)])
        square ([wall_thickness + h_profile[0] + epsilon * 2, 1000]);
    }
}

module corner_blank (corner_blank_options)
{
    h_aluex = corner_get_h_aluex (corner_blank_options);
    v_aluex = corner_get_v_aluex (corner_blank_options);
    height = corner_get_height (corner_blank_options);

    v_circumferential = corner_get_v_aluex_circumferential (
        corner_blank_options
    );
    v_radial = corner_get_v_aluex_radial (
        corner_blank_options
    );


    wall_thickness = corner_get_wall_thickness (corner_blank_options);

    h_width = corner_get_h_aluex_width (corner_blank_options);
    h_height = corner_get_h_aluex_height (corner_blank_options);

    render ()
    difference () {
        union () {
            /* basic corner shape */
            linear_extrude (height = height)
            corner_shape (corner_blank_options);

            /* v slot interface */
            corner_place_v_aluex (corner_blank_options)
            aluex_slot_interface (corner_get_v_aluex (corner_blank_options),
                                  height);

            /* h slot interface */
            corner_place_h_aluex (corner_blank_options)
            translate ([0, 0, -epsilon])
            aluex_slot_interface (
                aluex = corner_get_h_aluex (corner_blank_options),
                h = corner_get_arm_length (corner_blank_options),
                slot_sides = "u"
            );
        }

        /* v screwholes */
        corner_place_v_aluex (corner_blank_options)
        for (pos = corner_get_v_aluex_screwholes (corner_blank_options))
            translate ([0, 0, pos])
            place_slots (
                aluex = corner_get_v_aluex (corner_blank_options),
                sides = "d"
            )
            rotate (90, X)
            aluex_screwhole (v_aluex, wall_thickness, 30);

        /* h screwholes */
        corner_place_h_aluex (corner_blank_options)
        for (pos = corner_get_h_aluex_screwholes (corner_blank_options))
            translate ([0, 0, pos])

            place_slots (
                aluex = corner_get_h_aluex (corner_blank_options),
                sides = "u"
            )
            rotate (90, X)
            aluex_screwhole (h_aluex, wall_thickness + epsilon);

        /* logo */
        translate ([0, -(v_radial + wall_thickness + epsilon), height / 2])
        rotate (90, X)
        mirror (Z)
        linear_extrude (height = 0.6)
        text (
            "δbob",
            font = "Ubuntu",
            halign = "center",
            valign = "center",
            size = 8
        );
    }
}

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

module corner_top (corner_top_options)
{
    blank = corner_top_get_blank (corner_top_options);
    height = corner_get_height (blank);
    idler_pos = height / 2;
    idler_axle_d = corner_top_get_idler_size (corner_top_options);
    cavity_width = corner_get_cavity_width (blank);
    wall_thickness = corner_get_wall_thickness (blank);

    render ()
    difference () {
        union () {
            corner_blank (blank);

            /* support for end of idler axle */
            h = 8;
            d = idler_axle_d + wall_thickness * 2;
            intersection () {
                translate ([0, wall_thickness - epsilon, idler_pos])
                rotate (-90, X)
                filleted_cylinder (
                    d1 = d + h * 2,
                    d2 = d,
                    h = h,
                    fillet_r = 3,
                    chamfer_r = 3
                );

                ccube ([1000, 1000, height], center = X + Y);
            }
        }

        translate ([0, 0, idler_pos])
        rotate (-90, X) {
            /* screwhole */
            echo (idler_axle_d);
            translate ([0, 0, 1])
            mcad_polyhole (
                d = idler_axle_d + 0.3,
                h = cavity_width + wall_thickness * 2 + epsilon
            );

            /* nut hole */
            translate ([0, 0, wall_thickness + cavity_width - epsilon])
            mcad_nut_hole (size = idler_axle_d);
        }
    }
}

corner_top (delta_get_top_corner (deltabob));
*corner_bottom (delta_get_bottom_corner (deltabob));
