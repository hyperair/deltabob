use <MCAD/array/along_curve.scad>
use <MCAD/array/mirror.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/triangles.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
include <MCAD/units/metric.scad>
use <gt2.scad>
use <utils.scad>

min_wall_thickness = 5;
wheel_separation_perpendicular = 40 + 18;
wheel_separation_parallel = 60;

spacer_eccentricity = 1;

eccentric_spacer_id = 5;
eccentric_spacer_od = 8;

carriage_width = (wheel_separation_perpendicular + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_length = (wheel_separation_parallel + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_base_thickness = 7;

belt_clamp_tooth_count = 8;
belt_x_offset = 5.093;          // 16-tooth pulley
belt_width = 6;
belt_thickness = 1.38;
belt_doubled_thickness = 2.5;

// static belt clamp dimensions
belt_clamp1_length = belt_clamp_tooth_count * 2;
belt_clamp1_height = belt_width + 10;
belt_clamp1_width = belt_thickness + 4 * 2;
belt_y_offset1 = -(belt_clamp1_length - carriage_length) / 2;

// adjustable belt clamp dimensions
belt_clamp2_stator_length = 10;
belt_clamp2_stator_height = belt_width + 8;
belt_clamp2_stator_width = belt_thickness + 7 * 2;
belt_clamp2_screw_distance = (belt_clamp2_stator_width +
    belt_doubled_thickness) / 2;
belt_y_offset2 = (belt_clamp2_stator_length - carriage_length) / 2;

belt_clearance = 0.1;

rod_separation = 50;
carriage_hinge_offset = 22;
arm_thickness = 10;

arms_y_offset = 0;

m3_nut_tolerance = 0.01;

mode = "plate";

$fs = 0.4;
$fa = 1;

module carriage_base ()
{
    difference () {
        translate ([0, 0, carriage_base_thickness / 2])
        mcad_rounded_cube (
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

        // eccentric spacer holes
        for (y = [0.5, -0.5] * wheel_separation_parallel)
        translate ([x, y, -epsilon])
        mcad_polyhole (d = eccentric_spacer_od,
            h = carriage_base_thickness + epsilon * 2);
    }
}

module m3_nut_hole (proj = -1)
{
    mcad_nut_hole (size = 3, proj = proj, tolerance = m3_nut_tolerance);
}

module gt2_belt_clamp_static ()
{
    translate ([0, 0, -epsilon]) {
        difference () {
            // maintain center position
            filleted_cube (
                [belt_clamp1_width, belt_clamp1_length, belt_clamp1_height],
                center = X + Y,
                fillet_sides = [0, 2, 3],
                fillet_r = 5
            );

            gt2_belt (tooth_count = belt_clamp_tooth_count + 2,
                      thickness = belt_thickness,
                      width = belt_clamp1_height + 1);

            // chamfered entrance for easier installation
            translate ([0, 0, belt_clamp1_height + epsilon * 2])
            rotate (90, X)
            linear_extrude (height = belt_clamp1_length + epsilon * 2,
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
                    belt_clamp1_height - 3 / 2 - 2
                ])
            rotate (90, Y)
            rotate (90, Z) {
                translate ([0, 0, -belt_clamp1_width / 2 - 1])

                m3_nut_hole ();
                mcad_polyhole (d = 3.3, h = belt_clamp1_width + epsilon * 2,
                    center = true);
            }
        }
    }
}

module gt2_belt_clamp_adjustable_stator ()
{
    difference () {
        filleted_cube (
            [
                belt_clamp2_stator_width,
                belt_clamp2_stator_length,
                belt_clamp2_stator_height
            ],
            center = X + Y,
            fillet_sides = [0, 1, 2],
            fillet_r = 5
        );


        // screwholes
        for (x = [1, -1] * belt_clamp2_screw_distance / 2)
        translate ([x, 0, belt_clamp2_stator_height / 2])
        rotate (-90, X) {
            mcad_polyhole (d = 3.3, h = 1000, center = true);

            nut_offset = (belt_clamp2_stator_length / 2 -
                mcad_metric_nut_thickness (3));
            translate ([0, 0, nut_offset])
            stretch (Z, 2)
            rotate (90, Z)
            m3_nut_hole ();
        }

        // slot for belt to pass through
        *ccube ([belt_thickness + 1, 1000, 1000], center = X + Y);
    }
}

module gt2_belt_clamp_adjustable_movingpart ()
{
    difference () {
        ccube ([belt_clamp2_stator_width, belt_clamp2_stator_height, 8],
            center = X + Y);

        // belt slot
        mcad_rounded_cube (
            [belt_doubled_thickness, belt_width + 2, 1000],
            radius = 1,
            sidesonly = true,
            center = true
        );

        for (x = [1, -1] * belt_clamp2_screw_distance / 2)
        translate ([x, 0, 0])
        mcad_polyhole (d = 3.3, h = 1000, center = true);
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
                cylinder (d = arm_thickness + 2, h = width, center = true);
            }

            // longer arms
            arm_extra_len = (carriage_hinge_offset - carriage_base_thickness +
                epsilon);
            rotate (90, X)
            translate ([0, 0, -arm_extra_len])
            filleted_cube (
                [
                    width,
                    arm_thickness,
                    arm_extra_len
                ],
                center = X + Y,
                fillet_sides = [1, 3],
                fillet_r = reinforced
            );
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
            m3_nut_hole (proj = 1);
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
        [belt_x_offset, belt_y_offset1, carriage_base_thickness - epsilon]
    )
    gt2_belt_clamp_static ();

    translate ([
            belt_x_offset,
            belt_y_offset2,
            carriage_base_thickness - epsilon
        ]) {

        gt2_belt_clamp_adjustable_stator ();

        if (mode == "preview")
        translate ([0, -20, belt_clamp2_stator_height / 2])
        rotate (90, X)
        gt2_belt_clamp_adjustable_movingpart ();
    }

    %mcad_mirror_duplicate (X)
    translate ([belt_x_offset, 0, carriage_base_thickness + 3])
    gt2_belt (carriage_length / 2, belt_thickness, belt_width);

    translate ([0, arms_y_offset, carriage_hinge_offset - epsilon])
    rotate (180, Z)
    rotate (-90, X)
    parallel_joints (16);
}

carriage ();

if (mode == "plate")
translate ([carriage_width, 0, 0])
!gt2_belt_clamp_adjustable_movingpart ();
