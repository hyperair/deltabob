use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/2Dshapes.scad>
include <MCAD/units/metric.scad>
use <utils.scad>

min_wall_thickness = 5;
wheel_separation_perpendicular = 40 + 20;
wheel_separation_parallel = wheel_separation_perpendicular;

spacer_eccentricity = 1;

eccentric_spacer_id = 5;
eccentric_spacer_od = 7;

carriage_width = (wheel_separation_perpendicular + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_length = (wheel_separation_parallel + eccentric_spacer_od / 2 +
    min_wall_thickness * 2);
carriage_base_thickness = 5;

belt_clamp_tooth_count = 12;
belt_x_offset = 2.546;          // 16-tooth pulley
belt_width = 6;
belt_thickness = 1.38;

belt_clamp_length = belt_clamp_tooth_count * 2;
belt_clamp_height = belt_width + 2;
belt_clamp_width = belt_thickness + 3 * 2;

belt_clearance = 0.1;

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

                for (i = [1, -1])
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

            gt2_belt (belt_clamp_tooth_count + 2);
        }
    }
}

module gt2_belt (tooth_count, $fs = 0.01, $fa = 1)
{
    linear_extrude (height = belt_clamp_height + 1)
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

module carriage ()
{
    carriage_base ();

    translate ([belt_x_offset, 0, carriage_base_thickness - epsilon])
    gt2_belt_clamp ();
}

carriage ();
