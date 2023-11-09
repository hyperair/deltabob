use <MCAD/array/mirror.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>
use <lib/fillet.scad>
use <gt2.scad>
use <utils.scad>

use <lib/carriage.scad>
include <configuration/delta.scad>

$fs = 0.4;
$fa = 1;

clearance = 0.3;

module carriage_base (options)
{
    thickness = carriage_get_base_thickness (options);
    width = carriage_get_base_width (options);
    length = carriage_get_carriage_length (options);

    eccentric_od = carriage_get_eccentric_od (options);
    wall_thickness = carriage_get_wall_thickness (options);
    wheel_spacing = carriage_get_wheel_spacing (options);

    difference () {
        translate ([0, 0, thickness / 2])
        mcad_rounded_cube ([width, length, thickness],
                          radius = eccentric_od + wall_thickness,
                          sidesonly = true,
                          center = true);

        for (x = [-1, 1] * wheel_spacing / 2)
        for (y = [-1, 1] * ((length - eccentric_od) / 2 - wall_thickness))
        translate ([x, y, 0])
        mcad_polyhole (d = eccentric_od + clearance,
                       h = (thickness + epsilon) * 2,
                       center = true);
    }
}

module carriage_hinge (options)
{
    hinge_d = carriage_get_hinge_d (options);
    wall_thickness = carriage_get_wall_thickness (options);
    thickness = carriage_get_base_thickness (options);
    elevation = carriage_get_hinge_elevation (options);

    hinge_od = hinge_d + wall_thickness;

    module hinge_shape ()
    {
        render ()
        difference () {
            rotate (45, X)
            difference () {
                translate ([0, 0, -0.1 * hinge_d])
                mirror (Z)
                cylinder (d = hinge_od, h = elevation + thickness * 2);

                sphere (d = hinge_d);
            }

            translate ([0, 0, -elevation - epsilon])
            mirror (Z)
            ccube ([100, 100, 100], center = X + Y);
        }
    }

    hinge_shape ();

    fillet (r = 3, steps = 10, include = false) {
        hinge_shape ();

        translate ([0, 0, -elevation])
        mirror (Z)
        ccube ([100, 100, epsilon], center = X + Y);
    }
}

module carriage_belt_clamp (options)
{
    belt_clamp_tooth_count = carriage_get_belt_clamp_tooth_count (options);
    belt_clamp_width = carriage_get_belt_clamp_width (options);
    belt_clamp_height = carriage_get_belt_clamp_height (options);
    belt_clamp_length = carriage_get_belt_clamp_length (options);
    belt_thickness = carriage_get_belt_thickness (options);

    translate ([0, 0, -epsilon]) {
        difference () {
            // maintain center position
            filleted_cube (
                [belt_clamp_width, belt_clamp_length, belt_clamp_height],
                center = X + Y,
                fillet_sides = [0, 2, 3],
                fillet_r = 5
            );

            gt2_belt (tooth_count = belt_clamp_tooth_count + 2,
                      thickness = belt_thickness,
                      width = belt_clamp_height + 1);

            // chamfered entrance for easier installation
            translate ([0, 0, belt_clamp_height + epsilon * 2])
            rotate (90, X)
            linear_extrude (height = belt_clamp_length + epsilon * 2,
                center = true)
            polygon ([[-2, 0],
                      [0, -5],
                      [2, 0]]);

            // screwhole and nut trap
            translate ([0,
                        0,
                        belt_clamp_height - 3 / 2 - 2])
            rotate (90, Y)
            rotate (90, Z) {
                translate ([0, 0, -belt_clamp_width / 2 - 1])

                mcad_nut_hole (size = 3, proj = -1, tolerance = 0.01);
                mcad_polyhole (d = 3.3, h = belt_clamp_width + epsilon * 2,
                    center = true);
            }
        }
    }
}

module carriage_tensioner_block (options)
{
    belt_tensioner_block_width = carriage_get_belt_tensioner_block_width (
        options);
    belt_tensioner_block_length = carriage_get_belt_tensioner_block_length (
        options);
    belt_tensioner_block_height = carriage_get_belt_tensioner_block_height (
        options);
    belt_tensioner_block_elevation = (
        carriage_get_belt_tensioner_block_hole_elevation (options)
    );

    belt_tensioner_screw_distance = carriage_get_belt_tensioner_screw_distance (
        options);

    belt_thickness = carriage_get_belt_thickness (options);

    difference () {
        filleted_cube (
            [
                belt_tensioner_block_width,
                belt_tensioner_block_length,
                belt_tensioner_block_height
            ],
            center = X + Y,
            fillet_sides = [0, 1, 2],
            fillet_r = 5
        );


        // screwholes
        for (x = [1, -1] * belt_tensioner_screw_distance / 2)
        translate ([x, 0, belt_tensioner_block_elevation])
        rotate (-90, X) {
            mcad_polyhole (d = 3.3, h = 1000, center = true);

            nut_offset = (belt_tensioner_block_length / 2 -
                          mcad_metric_nut_thickness (3));
            translate ([0, 0, nut_offset])
            stretch (Z, 2)
            rotate (90, Z)
            mcad_nut_hole (size = 3, proj = -1, tolerance = 0.01);
        }
    }
}

module carriage_hinge_tether_block (options)
{
    hinge_elevation = carriage_get_hinge_elevation (options);
    base_thickness = carriage_get_base_thickness (options);
    extra_h = 2;
    height = hinge_elevation + extra_h;
    width = 10;
    length = 15;

    /* offset to avoid intersecting with belt */
    x_offset = 2;

    difference () {
        translate ([x_offset, width / 2 - extra_h, 0])
        filleted_cube (
            [width, length, height],
            center = X + Y,
            fillet_sides = [0, 1, 2, 3],
            fillet_r = 3
        );

        /* 45° cutout */
        translate ([0, 0, hinge_elevation])
        rotate (45, X)
        ccube ([width * 1.5, length * 1.5, 10], center = X + Y);

        /* hole for string */
        translate ([0, 0, hinge_elevation])
        rotate (70, X)
        cylinder (d = 1.5, h = 100, center = true);
    }
}

module carriage (options)
{
    thickness = carriage_get_base_thickness (options);
    length = carriage_get_carriage_length (options);

    /* base platform */
    carriage_base (options);

    /* hinges */
    hinge_spacing = carriage_get_hinge_spacing (options);
    hinge_elevation = carriage_get_hinge_elevation (options);

    translate ([0, -hinge_elevation / 2, 0]) {
        mcad_mirror_duplicate (X)
        translate ([hinge_spacing / 2, 0, thickness + hinge_elevation])
        carriage_hinge (options);

        /* middle block for hinge tether */
        translate ([0, 0, thickness - epsilon])
        carriage_hinge_tether_block (options);
    }

    /* belt clamp */
    belt_clamp_length = carriage_get_belt_clamp_length (options);
    belt_offset = carriage_get_belt_offset (options);
    translate ([belt_offset, (length - belt_clamp_length) / 2, thickness])
    carriage_belt_clamp (options);

    /* tensioner blocks */
    belt_tensioner_block_length = carriage_get_belt_tensioner_block_length (
        options);
    translate ([belt_offset,
                -(length - belt_tensioner_block_length) / 2,
                thickness])
    carriage_tensioner_block (options);

    /* belt */
    belt_width = carriage_get_belt_width (options);
    belt_thickness = carriage_get_belt_thickness (options);
    %difference () {
        mcad_mirror_duplicate (X)
        translate ([belt_offset, 0, thickness + 1])
        gt2_belt (tooth_count = round (length / 2),
                  thickness = belt_thickness,
                  width = belt_width);

        translate ([belt_offset, 0, thickness + 1])
        ccube ([belt_thickness * 2,
                (length
                 - belt_tensioner_block_length
                 - belt_clamp_length),
                100],
               center = X + Y);
    }
}

carriage (delta_get_carriage (deltabob));
