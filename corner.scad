include <MCAD/units/metric.scad>
include <MCAD/motors/stepper.scad>
use <MCAD/shapes/boxes.scad>

tslot_profile = 20;
tslot_width = 40;
tslot_thickness = 20;

tslot_separation = 2;

min_wall_thickness = 5;

motor = Nema17;
motor_width = motorWidth (motor);

arm_length = 80;

base_inner_width = tslot_thickness + tslot_separation * 2;

$fs = 0.4;
$fa = 1;

module tslot_interface (slot_width, length, thickness = 1)
{
    translate ([-slot_width / 2, 0, 0])
    cube ([slot_width, length, thickness]);
}

module mirror_if (value, axis = X)
{
    if (value) {
        mirror (axis)
        children ();
    } else {
        children ();
    }
}

module trapezoid (u, d, h)
{
    polygon ([
            [-d/2, 0],
            [d/2, 0],
            [u/2, h],
            [-u/2, h]
        ]);
}

module equi_triangle (side, center = true)
{
    radius = side / 2 / sin (60);

    translate (center ? [0, 0, 0] : [-radius, 0, 0])
    circle (r = radius, $fn = 3);
}

module round (r)
{
    offset (r = r)
    offset (r = -r)
    children ();
}

module vertical_extrusion_shape ()
{
    // poke hole for vertical extrusion
    translate ([-tslot_thickness / 2, 0])
    mirror (Y)
    square ([tslot_thickness, tslot_width]);
}

module place_horizontal_extrusion ()
{
    for (direction = [1, -1])
    mirror_if (direction < 0, X)
    translate ([base_inner_width / 2, 0])
    rotate (-30, Z)
    children ();
}

module horizontal_extrusion_shape ()
{
    place_horizontal_extrusion ()
    square ([tslot_thickness, arm_length]);
}

module corner_shape ()
{
    chord_length = (tslot_thickness / cos (30) * 2 +
        tslot_separation * 2 + tslot_thickness);
    triangle_y_offset = chord_length / 2 / tan (30);

    difference () {
        round (-5)
        union () {
            // truncated triangle
            difference () {
                translate ([0, -triangle_y_offset, 0])
                rotate (-90, Z)
                round (r = 20)
                equi_triangle (side = 200, center = false);

                // truncate the triangle
                translate ([-500, 0])
                square ([1000, 1000]);
            }

            // protrusion for extra tslot width
            offset (r = min_wall_thickness)
            translate ([-tslot_thickness / 2, -tslot_width])
            square ([tslot_thickness, tslot_width]);

            // arm length
            for (direction = [1, -1])
            translate ([direction * base_inner_width / 2, 0])
            rotate (-direction * 30, Z)
            translate ([direction * tslot_thickness, 0])
            mirror_if (direction > 0, X)
            square ([tslot_thickness + min_wall_thickness,
                    arm_length]);
        }
    }
}

/* module corner_shape ()
{
    outer_edge_distance = (tslot_thickness / cos (30) * 2 +
        tslot_separation * 2 + tslot_thickness);

    triangle_y_offset = outer_edge_distance / 2 / tan (30);

    motor_width = motorWidth (Nema17);

    min_inner_width = tslot_thickness + tslot_separation * 2;

    motor_distance = max (
        (motor_width + min_wall_thickness * 6 - min_inner_width) / 2 * tan (60),
        lookup (NemaFrontAxleLength, Nema17) + 5
    );

    linear_extrude (height = motor_width)
    difference () {
        round (-10)
        union () {
            // truncated triangle
            difference () {
                translate ([0, -triangle_y_offset, 0])
                rotate (-90, Z)
                round (r = 20)
                equi_triangle (side = 200, center = false);

                translate ([-500, motor_distance])
                square ([1000, 1000]);
            }

            // protrusion for extra tslot width
            offset (r = min_wall_thickness)
            translate ([-tslot_thickness / 2, -tslot_width])
            square ([tslot_thickness, tslot_width]);

            for (direction = [1, -1])
            translate ([direction * min_inner_width / 2, 0])
            rotate (-direction * 30, Z)
            translate ([direction * tslot_thickness, 0])
            mirror_if (direction > 0, X)
            square ([tslot_thickness + min_wall_thickness,
                    motor_distance * 2.5]);
        }

        // gap for stepper motor
        round (r = 5)
        offset (r = -min_wall_thickness)
        trapezoid (
            d = min_inner_width,
            u = min_inner_width + motor_distance / tan (60) * 2,
            h = motor_distance
        );

        // hole for the 40mm extrusion
    }

    translate ([0,
            motor_distance - lookup (NemaRoundExtrusionHeight, Nema17),
            motor_width / 2])
    rotate (-90, X)
    motor (Nema17);
} */

module bottom_corner ()
{
    motor_plate_width = motor_width + min_wall_thickness * 6;
    motor_distance = max (
        (motor_plate_width - base_inner_width) / 2 * tan (60),
        lookup (NemaFrontAxleLength, Nema17) + 5
    );

    difference () {
        linear_extrude (height = tslot_width)
        difference () {
            round (-5)
            union () {
                corner_shape ();

                translate ([-motor_plate_width / 2,
                        -min_wall_thickness + motor_distance])
                square ([motor_plate_width, min_wall_thickness]);
            }

            vertical_extrusion_shape ();
            horizontal_extrusion_shape ();
        }

        for (direction = [1, -1])
        translate ([direction * base_inner_width / 2, 0, -2])
        rotate (-direction * 30, Z)
        mirror_if (direction < 0, X)
        cube ([tslot_thickness + 1, arm_length * 2, tslot_width + 2]);
    }
}

module extrusions ()
{
    module single_bar ()
    cube ([tslot_thickness, 400, tslot_width]);

    place_horizontal_extrusion ()
    single_bar ();

    translate ([-10, 0, 0])
    rotate (90, X)
    single_bar ();
}

bottom_corner ();
*%extrusions ();
