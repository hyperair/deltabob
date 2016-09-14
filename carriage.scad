use <MCAD/array/mirror.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>
use <lib/fillet.scad>


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
        mcad_rounded_box ([width, length, thickness],
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

module carriage (options)
{
    /* base platform */
    carriage_base (options);

    /* hinges */
    hinge_spacing = carriage_get_hinge_spacing (options);
    hinge_elevation = carriage_get_hinge_elevation (options);
    thickness = carriage_get_base_thickness (options);

    mcad_mirror_duplicate (X)
    translate ([hinge_spacing / 2, 0, thickness + hinge_elevation])
    carriage_hinge (options);

    /* middle block for hinge tether */
    carriage_hinge_tether_block ();

    /* belt clamp */
    carriage_belt_clamp (options);
    carriage_tensioner_block (options);
}

module carriage_proto (options)
{
    wall_thickness = carriage_get_wall_thickness (options);
    wheel_spacing = carriage_get_wheel_spacing (options);

    eccentric_od = carriage_get_eccentric_od (options);

    length = carriage_get_carriage_length (options);
    width = wheel_spacing + eccentric_od + wall_thickness * 2;
    thickness = carriage_get_base_thickness (options);

    hinge_spacing = carriage_get_hinge_spacing (options);

    /* base shape */
    difference () {
        translate ([0, 0, thickness / 2])
        mcad_rounded_box ([width, length, thickness],
                          radius = eccentric_od / 2 + wall_thickness,
                          sidesonly = true,
                          center = true);

        for (x = [-1, 1] * wheel_spacing / 2)
        for (y = [-1, 1] * ((length - eccentric_od) / 2 - wall_thickness))
        translate ([x, y, 0])
        mcad_polyhole (d = eccentric_od + clearance,
                       h = (thickness + epsilon) * 2,
                       center = true);
    }

    /* hinge block */
    difference () {
        block_width = 15;
        hinge_d = 10;
        belt_offset = 10.55 / 2;

        translate ([width / 2, 0, thickness])
        rotate (-90, Y)
        rotate (45, Z)
        difference () {
            translate ([-0.5, -0.5] * block_width)
            cube ([block_width, block_width, width]);

            for (z = [1, -1])
            translate ([0,
                        - block_width * 0.5 - hinge_d * 0.1,
                        length / 2 + z * hinge_spacing / 2])
            sphere (d = hinge_d);
        }

        /* flatten the bottom */
        mirror (Z)
        ccube ([width + epsilon * 2, length, thickness * 2], center = X + Y);

        /* open up belt channels */
        translate ([-belt_offset, 0])
        ccube ([5, length, thickness * 3], center = X + Y);

        translate ([0, 0, thickness + 5])
        rotate (90, X)
        cylinder (d = 2, h = length, center = true);
    }
}

carriage (delta_get_carriage (deltabob));
