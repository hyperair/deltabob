include <MCAD/units/metric.scad>
include <MCAD/motors/stepper.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>

tslot_profile = 20;
tslot_width = 40;
tslot_thickness = 20;
tslot_slot_width = 5;

min_wall_thickness = 5;
tslot_separation = min_wall_thickness;

motor = Nema17;
motor_width = motorWidth (motor);

arm_length = 60;

clearance = 0.1;

base_inner_width = tslot_width + tslot_separation * 2;
base_outer_width = base_inner_width + 2 * tslot_thickness / cos (30);

motor_plate_min_width = motor_width + min_wall_thickness * 6;
motor_distance = max (
    (motor_plate_min_width - base_inner_width) / 2 * tan (60),
    lookup (NemaFrontAxleLength, motor) + min_wall_thickness * 2,
    min_wall_thickness * 2 + 10 // estimated space for carriage
);

motor_plate_width = base_inner_width + motor_distance * tan (30) * 2;

corner_rounding_r = 20;


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

module vertical_extrusion_shape (with_clearance = false)
{
    h = with_clearance ? tslot_thickness + clearance : tslot_thickness;
    w = with_clearance ? tslot_width + clearance : tslot_width;

    // poke hole for vertical extrusion
    translate ([-w / 2, 0])
    mirror (Y)
    square ([w, h]);
}

module horizontal_extrusion_shape ()
{
    place_horizontal_extrusion ()
    square ([tslot_thickness, arm_length]);
}

module place_horizontal_extrusion ()
{
    for (direction = [1, -1])
    mirror_if (direction < 0, X)
    translate ([base_inner_width / 2, 0])
    rotate (-30, Z)
    children ();
}

module place_motor ()
{
    translate ([0, motor_distance, -motor_width / 2 + tslot_width])
    rotate (90, X)
    children ();
}

module corner_shape ()
{
    chord_length = (tslot_thickness / cos (30) * 2 + base_inner_width);
    triangle_y_offset = chord_length / 2 / tan (30);

    difference () {
        union () {
            // base corner shape
            difference () {
                h_above_x = corner_rounding_r;
                h_below_x = tslot_thickness + min_wall_thickness;
                trapezoid_h = h_above_x + h_below_x;

                round (r = corner_rounding_r)
                translate ([0, -h_below_x])
                trapezoid (
                    u = base_outer_width + 2 * h_above_x / tan (60),
                    d = base_outer_width - 2 * h_below_x / tan (60),
                    h = trapezoid_h
                );

                // truncate bits above x axis
                translate ([-500, 0])
                square ([1000, 1000]);
            }

            // protrusion for extra tslot width
            offset (r = min_wall_thickness)
            vertical_extrusion_shape ();

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

module place_extrusion_screwholes ()
{
    // vertical extrusion
    for (i = [1/4, 3/4] * tslot_width)
    translate ([0, 0, i])
    {
        // outside facing holes
        for (tslot_pos = [-10, 10])
        rotate (-90, X)
        translate ([tslot_pos, 0,
                -(tslot_thickness + min_wall_thickness + epsilon)])
        children ();
    }

    // horizontal extrusion
    function along_arm (length) = length / cos (30);

    place_horizontal_extrusion ()
    for (y = [
            along_arm (motor_distance * 0.4),
            along_arm (motor_distance + (arm_length - motor_distance) * 0.4)
        ])
    for (tslot_pos = [10, 30])
    translate ([min_wall_thickness + epsilon, y, tslot_pos])
    rotate (-90, Y)
    children ();
}

module motor_cutout ()
{
    screw_spacing = motorScrewSpacing (motor);

    for (x = [1, -1] * screw_spacing / 2)
    for (y = [1, -1] * screw_spacing / 2)
    translate ([x, y, -epsilon])
    mcad_polyhole (d = 3.3, h = min_wall_thickness + epsilon * 2);

    translate ([0, 0, -epsilon])
    mcad_polyhole (d = lookup (NemaRoundExtrusionDiameter, motor) + 0.3,
        h = min_wall_thickness + epsilon * 2);
}

module extrusion_cap_screw ()
{
    // screw hole
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = 5.3,
        h = min_wall_thickness + tslot_thickness / 2);

    // cap screw head
    mirror (Z)
    mcad_polyhole (d = 8.53, h = 100);
}

module bottom_corner ()
{
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

            vertical_extrusion_shape (with_clearance = true);
            horizontal_extrusion_shape ();
        }

        place_extrusion_screwholes ()
        extrusion_cap_screw ();

        place_motor ()
        motor_cutout ();
    }

    %place_motor ()
    mirror (Z)
    translate ([0, 0, -lookup (NemaRoundExtrusionHeight, motor)])
    motor (motor);
}

module top_corner ()
{
}

module extrusions ()
{
    module single_bar ()
    cube ([tslot_thickness, 400, tslot_width]);

    place_horizontal_extrusion ()
    single_bar ();

    translate ([tslot_width / 2, 0, 0])
    rotate (-90, Z)
    rotate (90, X)
    single_bar ();
}

bottom_corner ();
%extrusions ();
