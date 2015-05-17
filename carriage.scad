use <MCAD/array/along_curve.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/triangles.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
include <MCAD/units/metric.scad>
use <utils.scad>

min_wall_thickness = 5;
wheel_separation_perpendicular = 40 + 20;
wheel_separation_parallel = wheel_separation_perpendicular;

spacer_eccentricity = 1;

eccentric_spacer_id = 5;
eccentric_spacer_od = 8;

carriage_width = (wheel_separation_perpendicular + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_length = (wheel_separation_parallel + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_base_thickness = 5;

belt_clamp_tooth_count = 12;
belt_x_offset = 5.093;          // 16-tooth pulley
belt_width = 6;
belt_thickness = 1.38;

belt_clamp_length = belt_clamp_tooth_count * 2;
belt_clamp_height = belt_width + 10;
belt_clamp_width = belt_thickness + 3 * 2;

belt_y_offset = (belt_clamp_length - carriage_length) / 2;

belt_clearance = 0.1;

rod_separation = 50;
carriage_hinge_offset = 22;
arm_thickness = 10;

arms_y_offset = 10;

$fs = 0.4;
$fa = 1;

module carriage_base ()
{
    difference () {
        translate ([0, 0, carriage_base_thickness / 2])
        mcad_rounded_box (
            size = [
                carriage_width,
                carriage_length,
                carriage_base_thickness
            ],
            sidesonly = true,
            radius = min_wall_thickness,
            center = true
        );

        for (x = [0.5, -0.5] * wheel_separation_perpendicular)

        for (y = [0.5, -0.5] * wheel_separation_parallel)
        translate ([x, y, -epsilon])
        mcad_polyhole (d = eccentric_spacer_od,
            h = carriage_base_thickness + epsilon * 2);
    }
}


module gt2_belt_clamp ()
{
    translate ([0, 0, -epsilon]) {
        difference () {
            union () {
                ccube (
                    [belt_clamp_width, belt_clamp_length,
                        belt_clamp_height + epsilon],
                    center = [true, true, false]);

                // side fillets
                for (x = [1, -1])
                mirror_if (x < 1, X)
                translate ([belt_clamp_width / 2 - epsilon, 0, 0])
                rotate (90, X)
                linear_extrude (height = belt_clamp_length, center = true)
                rounded_fillet_shape (r = 5);

                // disabled buttress stiffener
                *for (i = [1, -1])
                mirror_if (i < 0, Y)
                translate ([0, -belt_clamp_length / 2])
                rotate (90, X)
                linear_extrude (height = 2)
                translate ([0, belt_clamp_height + epsilon])
                mirror (Y)
                trapezoid (bottom = belt_clamp_width,
                    height = belt_clamp_height + epsilon,
                    left_angle = -60, right_angle = -60);
            }

            gt2_belt (tooth_count = belt_clamp_tooth_count + 2,
                width = belt_clamp_height + 1);

            // chamfered entrance for easier installation
            translate ([0, 0, belt_clamp_height + epsilon * 2])
            rotate (90, X)
            linear_extrude (height = belt_clamp_length + epsilon * 2,
                center = true)
            polygon ([
                    [-2, 0],
                    [0, -5],
                    [2, 0]
                ]);

            // screwhole and nut trap
            translate ([
                    0,
                    0,
                    belt_clamp_height - 3 / 2 - 2
                ])
            rotate (90, Y)
            rotate (90, Z) {
                translate ([0, 0, -belt_clamp_width / 2 - 1])
                mcad_nut_hole (size = 3, tolerance = 0.1);
                mcad_polyhole (d = 3.3, h = belt_clamp_width + epsilon * 2,
                    center = true);
            }
        }
    }
}

module gt2_belt (tooth_count, width, $fs = 0.01, $fa = 1)
{
    linear_extrude (height = width)
    for (i = [0:tooth_count])
    rotate (-90, Z)
    translate ([(i - tooth_count / 2) * 2, 0])
    offset (r = belt_clearance)
    offset (r = -0.15)
    offset (r = 0.15)
    union () {
        offset (r = 0.555)
        offset (r = -0.555)
        intersection () {
            translate ([0.4, 0])
            circle (r = 1);

            translate ([-0.4, 0])
            circle (r = 1);

            translate ([-2, -0.75, 0])
            square ([4, 1.38]);
        }

        translate ([-1.25, 0])
        square ([2.5, belt_thickness - 0.75]);
    }

}

module parallel_joints (reinforced) {
    width = carriage_width;
    cutout = 13;
    offset = rod_separation / 2;
    middle = 2*offset - width/2;

    difference () {
        union () {
            // front of arms
            intersection () {
                cube ([width, 20, arm_thickness], center = true);

                rotate (90, Y)
                cylinder (d = arm_thickness + 2, h=width, center = true);
            }

            // longer arms
            ccube (
                [
                    width,
                    carriage_hinge_offset - carriage_base_thickness + epsilon,
                    arm_thickness
                ],
                center = X + Z
            );

            // reinforcement
            intersection () {
                translate ([0, 18, arm_thickness / 2])
                rotate (45, X)
                cube ([width, reinforced, reinforced], center=true);

                translate ([0, 0, 20])
                cube ([width, 35, 40], center=true);
            }
        }

        // screwholes
        rotate (90, Y)
        mcad_polyhole (d = 3.3, h = width + 2, center=true);

        for (x = [-offset, offset])
        translate ([x, 0, 0]) {
            // reliefs for u-joint movement
            translate ([0, 5.5, 0])
            hull ()
            mcad_linear_multiply (no = 2, separation = 20, axis = -Y)
            mcad_polyhole (d = cutout, h = 100, center = true);

            // nut hole
            rotate (90, Y)
            rotate (30, Z)
            linear_extrude (height = 17, center = true)
            mcad_nut_hole (size = 3, proj = 1, tolerance = 0.1);
        }

        // middle cutout
        translate ([0, 6, 0])
        hull ()
        mcad_linear_multiply (no = 2, separation = 20, axis = -Y)
        mcad_polyhole (d = middle * 2, h = 100, center = true);
    }
}

module rounded_fillet_shape (r)
{
    difference () {
        square ([r, r]);

        translate ([r, r])
        circle (r = r);
    }
}

module carriage ()
{
    carriage_base ();

    translate (
        [belt_x_offset, belt_y_offset, carriage_base_thickness - epsilon]
    )
    gt2_belt_clamp ();

    %for (i = [1, -1])
    mirror_if (i < 0, X)
    translate ([belt_x_offset, 0, carriage_base_thickness + 0.5])
    gt2_belt (carriage_length / 2, belt_width);

    translate ([0, arms_y_offset, carriage_hinge_offset - epsilon])
    rotate (180, Z)
    rotate (-90, X)
    parallel_joints (16);
}

carriage ();
