include <MCAD/units/metric.scad>
include <MCAD/motors/stepper.scad>
include <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>
use <utils.scad>

hextrusion_length = 270;
vextrusion_length = 600;

tslot_profile = 20;
tslot_width = 40;
tslot_thickness = 20;
tslot_slot_width = 5;

min_wall_thickness = 5;
tslot_separation = min_wall_thickness;

motor = Nema17;
motor_width = motorWidth (motor);

arm_length = 60;

clearance = 0.2;

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

triangle_offset = base_outer_width / 2 / tan (30);

echo ("distance along normal from base_inner_width to tip of triangle: ",
    triangle_offset);


$fs = 0.4;
$fa = 1;

module tslot_interface (slot_width, length, thickness = 1)
{
    translate ([-slot_width / 2, 0, 0])
    cube ([slot_width, length, thickness]);
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
        round (-5)
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

            translate ([-motor_plate_width / 2,
                    -min_wall_thickness + motor_distance])
            square ([motor_plate_width, min_wall_thickness]);
        }

        // extrusion cutouts
        vertical_extrusion_shape (with_clearance = true);
        horizontal_extrusion_shape ();
    }
}

module generic_corner ()
{
    difference () {
        linear_extrude (height = tslot_width)
        corner_shape ();

        place_extrusion_screwholes ()
        extrusion_cap_screw ();
    }
}

module place_extrusion_screwholes ()
{
    // vertical extrusion
    for (i = [1/4, 3/4] * tslot_width)
    translate ([0, 0, i])
    {
        // outside facing holes
        for (tslot_pos = [-0.5, 0.5] * tslot_profile)
        rotate (-90, X)
        translate ([tslot_pos, 0,
                -(tslot_thickness + min_wall_thickness + epsilon)])
        children ();
    }

    // horizontal extrusion
    function along_arm (length) = length / cos (30);

    place_horizontal_extrusion ()
    for (y = [
            along_arm (motor_distance * 0.3),
            along_arm (motor_distance + (arm_length - motor_distance) * 0.4)
        ])
    for (tslot_pos = [0.5, 1.5] * tslot_profile)
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
        generic_corner ();

        place_motor ()
        motor_cutout ();
    }

    %place_motor ()
    mirror (Z)
    translate ([0, 0, -lookup (NemaRoundExtrusionHeight, motor)])
    motor (motor);
}

module filleted_cylinder (d1, d2, h, fillet_r, chamfer_r)
{
    rotate_extrude () {
        intersection () {
            round (chamfer_r)
            round (-fillet_r)
            union () {
                intersection () {
                    trapezoid (d = d1, u = d2, h = h);

                    translate ([0, 500])
                    square ([1000, 1000], center = true);
                }

                mirror (Y)
                square ([1000, 1000]);
            }

            square ([1000, 1000]);
        }
    }
}

module top_corner ()
{
    idler_hub_d = base_inner_width * 0.5;
    idler_hub_h = min_wall_thickness * 0.8;

    // idler hub
    difference () {
        union () {
            generic_corner ();

            place_motor ()
            translate ([0, 0, motor_distance + epsilon - min_wall_thickness])
            mirror (Z)
            filleted_cylinder (
                d1 = idler_hub_d, d2 = idler_hub_d - idler_hub_h * 2,
                h = idler_hub_h,
                fillet_r = 5,
                chamfer_r = 2
            );
        }

        // screwhole
        place_motor () {
            translate ([0, 0, -epsilon])
            mcad_polyhole (d = 3.3, h = motor_distance + epsilon * 2);

            rotate (90, Z)
            translate ([0, 0,
                    min_wall_thickness - METRIC_NUT_THICKNESS[3] + epsilon])
            mcad_nut_hole (3);
        }
    }
}

module extrusions ()
{
    module single_bar (length)
    cube ([tslot_thickness, length, tslot_width]);

    for (z = [0, vextrusion_length - tslot_width])
    translate ([0, 0, z])
    place_horizontal_extrusion ()
    single_bar (hextrusion_length);

    translate ([tslot_width / 2, 0, 0])
    rotate (-90, Z)
    rotate (90, X)
    single_bar (vextrusion_length);
}

triangle_base_length = hextrusion_length + 2 * (
    triangle_offset / cos (30) - tslot_thickness * cos (30));
triangle_h = triangle_base_length * cos (30);
centroid_offset = triangle_h / 3 * 2;

for (i = [0, 120, 240])
rotate (i, Z)
translate ([0, triangle_offset - centroid_offset, 0])
{
    bottom_corner ();

    translate ([0, 0, vextrusion_length - tslot_width])
    top_corner ();

    %extrusions ();
}

actual_build_diameter = triangle_base_length / tan (60);
rounded_build_diameter = floor (actual_build_diameter / 10) * 10;
echo ("Build diameter: ", rounded_build_diameter);
echo ("DELTA_SMOOTH_ROD_OFFSET", -(centroid_offset - triangle_offset + min_wall_thickness + tslot_thickness / 4));

// plate
%translate ([0, 0, tslot_width + 10])
cylinder (d = rounded_build_diameter, h = 3);
