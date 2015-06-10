use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/boxes.scad>
use <utils.scad>

include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

tslot_interface_depth = 5;
foot_height = 5;
foot_round_r = 2;

foot_dimensions_2 = [40, 20];

module base_shape ()
{
    difference () {
        mcad_rounded_box (
            concat (foot_dimensions_2, [foot_round_r + foot_height]),
            radius = 2);

        translate ([0, 0, 5])
        cube ([1000, 1000, 1000], center = X + Y);
    }
}


module tslot_interface ()
{
    lip_thickness = 1;
    length = 15;

    inner_width = 5;
    outer_width = 11;
    trapezoid_h = (outer_width - inner_width) / 2;

    rounding_r = 0.5;

    center_width = 7.6;

    module place_slot_interfaces ()
    {
        // centralize this breadthwise
        translate ([0, 10])
        for (i = [0, 1])
        translate ([10 + i * 20, 0])

        // slot interface for one 2020 unit
        for (angle = [0, 90])
        rotate (angle, Z)
        for (y = [1, -1])
        mirror_if (y < 0, Y)
        translate ([0, -trapezoid_h - center_width / 2])
        children ();
    }

    linear_extrude (height = tslot_interface_depth)
    place_slot_interfaces ()
    offset (r = rounding_r)
    offset (r = -rounding_r)
    trapezoid (top = inner_width, bottom = outer_width,
        height = trapezoid_h);
}

base_shape ();

translate ([0, 0, 5 - epsilon])
tslot_interface ();
