include <MCAD/units/metric.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/fillets/primitives.scad>
use <MCAD/array/mirror.scad>

include <configuration/delta.scad>
use <lib/fan.scad>
use <utils.scad>

$fs = 0.4;
$fa = 1;

module fan (fan_opts)
{
    width = axial_fan_get_width (fan_opts);
    thickness = axial_fan_get_thickness (fan_opts);
    corner_radius = axial_fan_get_corner_radius (fan_opts);

    color ("#222")
    mcad_rounded_cube (
        [width, width, thickness],
        radius=corner_radius,
        sidesonly=true,
        center=X + Y
    );
}

module fan_place_screwholes (fan_opts)
{
    screw_distance = axial_fan_get_screw_distance (fan_opts);

    mcad_place_at ([
        [-width / 2, -width/2],
        [-width / 2, width/2],
        [width / 2, -width/2],
        [width / 2, width/2],
    ])
    children();
}

module fan_plate (opts)
{
    fan_opts = print_fan_mount_get_fan (opts);
    thickness = print_fan_mount_get_base_thickness (opts);

    fan_width = axial_fan_get_width (fan_opts);
    fan_d = axial_fan_get_d (fan_opts);
    corner_radius = axial_fan_get_corner_radius (fan_opts);
    screw_distance = axial_fan_get_screw_distance (fan_opts);

    difference() {
        mcad_rounded_cube (
            [fan_width, fan_width, thickness],
            radius = corner_radius,
            sidesonly = true,
            center = X + Y
        );

        // fan air hole
        cylinder (d = fan_d, h = thickness * 2 + 1, center = true);

        // screw holes
        mirror(Z)
        for (x = [1, -1] * (screw_distance / 2))
        for (y = [1, -1] * (screw_distance / 2))
        translate ([x, y])
        screwhole (3, thickness, align_with = "above_nut");
    }
}

module mount (opts) {
    fan_opts = print_fan_mount_get_fan (opts);
    plate_thickness = print_fan_mount_get_base_thickness (opts);

    fan_width = axial_fan_get_width (fan_opts);
    fan_d = axial_fan_get_d (fan_opts);

    jaw_thickness = 1.5;
    gap_thickness = 2.5;

    thickness = jaw_thickness * 2 + gap_thickness;
    width = 10;
    length = 15;
    angle = 45;

    cutout_length = 8;

    difference() {
        // arm
        translate ([0, fan_width / 2]) {
            rotate (angle, X)
            translate ([0, length])
            rotate (90, Y)
            difference() {
                // basic shape
                linear_extrude (height=thickness, center=true)
                difference() {
                    hull() {
                        circle (d=width);

                        translate ([0, -length * 2])
                        square(width, center=true);
                    };

                    circle (d=3.3);
                }

                // center cutout
                translate ([0, -cutout_length])
                rotate (90, Y)
                mcad_rounded_cube (
                    [gap_thickness, cutout_length * 2, width * 2],
                    radius = gap_thickness / 2 - epsilon,
                    sidesonly = true,
                    center = X + Z
                );
            }

            mcad_mirror_duplicate (X)
            translate ([thickness / 2, -epsilon, -epsilon])
            linear_extrude (height = plate_thickness)
            mcad_fillet_primitive (angle = 90, radius = 3);
        }

        // bottom cutout
        mirror (Z)
        ccube ([100, 100, 100], center = X + Y);

        // top cutout
        translate ([0, 0, plate_thickness])
        ccube ([fan_width + 0.3, fan_width + 0.3, 100], center = X + Y);

        // air hole cutout
        translate ([0, 0, -epsilon])
        cylinder (d = fan_d, h = plate_thickness * 2);
    }
}

*% axial_fan (
    print_fan_mount_get_fan (
        delta_get_print_fan_mount (deltabob)
    )
);

fan_plate (
    delta_get_print_fan_mount (deltabob)
);

mount (delta_get_print_fan_mount (deltabob));
