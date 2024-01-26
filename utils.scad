use <MCAD/array/rectangular.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/2Dshapes.scad>

include <MCAD/units/metric.scad>

module mirror_if (value, axis = X)
{
    if (value) {
        mirror (axis)
        children ();
    } else {
        children ();
    }
}

module stretch (direction, distance = 1)
{
    hull () {
        children ();

        translate (direction * distance)
        children ();
    }
}

function is_in (vector, value, start = 0) = (
    start >=  len (vector) ? false :
    vector[start] == value ? true :
    is_in (vector, value, start + 1)
);

module filleted_cube (size, center, fillet_sides, fillet_r)
{
    center = (len (center) == undef) ? [center, center, center] : center;
    size = (len (size) == undef) ? [size, size, size] : size;
    expanded_size = size + [2, 2, 0] * fillet_r;
    function get_offset (i) = center[i] ? 0 : size[i] / 2;
    offsets = [for (i = [0:2]) get_offset (i)];

    // fully expand this into an array (ranges have no len())
    fillet_sides = [for (x = fillet_sides) x];

    module fillet_cutout (side)
    {
        horizontal = (side % 2 > 0);
        length = (horizontal ? size[0] : size[1]) + fillet_r * 2;
        offset = (
            (side <= 1 ? 1 : -1) * 0.5 *
            (
                horizontal ?
                [0, expanded_size[1], 0] :
                [expanded_size[0], 0, 0]
            ) +
            [0, 0, -size[2] / 2 + fillet_r]
        );

        translate (offset - [0, 0, epsilon])
        rotate (90, horizontal ? Y : X)
        if (is_in (fillet_sides, side)) {
            cylinder (r = fillet_r, h = length, center = true);
        } else {
            cube ([fillet_r * 2, fillet_r * 2, length], center = true);
        }
    }

    module filletize ()
    {
        stretch (Z, size[2])
        children ();
    }


    translate (offsets)
    difference () {
        cube (expanded_size, center = true);

        for (side = [0:3])
        filletize ()
        fillet_cutout (side);
    }
}

module filleted_cylinder (
    h, r, center, d, d1, d2, r1, r2,
    fillet_r = 0, chamfer_r = 0
)
{
    r = (r == undef && d != undef) ? d / 2 : r;

    function get_r (_r, _d) =
    (
        (r != undef) ? r :
        (_r != undef) ? _r :
        _d / 2
    );

    r1 = get_r (r1, d1);
    r2 = get_r (r2, d2);

    d1 = r1 * 2;
    d2 = r2 * 2;

    translate (center ? [0, 0, -h /2] : [0, 0, 0])
    rotate_extrude () {
        intersection () {
            round (chamfer_r)
            round (-fillet_r)
            union () {
                intersection () {
                    trapezoid (bottom = d1, top = d2, height = h);

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

module round (r)
{
    offset (r = r)
    offset (r = -r)
    children ();
}

function slice (list, start = 0, length) = (
    (length <= 0) ? [] : [
        for (i = [start : max (0, min (len (list), start + length) - 1)])
            list[i]
    ]);

module stacked_cylinder (sizes)
{
    if (len (sizes) > 0) {
        size = sizes[len (sizes) - 1];
        d = size[0];
        h = size[1];

        next_size = (len (sizes) >= 2) ? sizes[len (sizes) - 2] : undef;
        next_d = (next_size != undef) ? next_size[0] : undef;
        next_h = (next_size != undef) ? next_size[1] : undef;

        if (next_size == undef) {
            cylinder (d = d, h = h);
        } else if (d <= next_d) {
            cylinder (d = d, h = h + epsilon);

            translate ([0, 0, h])
            stacked_cylinder (slice (sizes, length = len (sizes) - 1));
        } else {  // d > next_d
            cylinder (d = d, h = h);

            translate ([0, 0, h - epsilon])
            stacked_cylinder (
                concat (
                    slice (sizes, length = len (sizes) - 2),
                    [[next_d, next_h + epsilon]]
                )
            );
        }
    }
}

cap_screw_head_diameters = [
    [3, 5.5],
    [4, 7],
    [5, 8.5],
    [6, 10],
    [8, 13],
    [10, 16],
    [12, 18],
    [16, 24],
    [20, 30],
    [24, 36],
];

/**
 * screwhole - renders a cap screw hole
 *
 * @param size Diameter of screw
 * @param length Fastened length (distance between screw and nut)
 * @param nut_projection Direction to project nut in (axial, radial)
 * @param align_with Alignment of whole set (above_head, below_head, center,
 *                                           below_nut, above_nut)
 */
module screwhole (size, length, nut_projection = "axial",
                  align_with = "above_head",
                  screw_extra_length = 1000, head_extra_length = 1000,
                  nut_projection_length = 100)
{
    cap_head_d = lookup (size, cap_screw_head_diameters);
    cap_head_h = size;

    nut_thickness = mcad_metric_nut_thickness (size);

    elevation = (
        (align_with == "above_head") ? 0 :
        (align_with == "below_head") ? cap_head_h :
        (align_with == "center") ? cap_head_h + length / 2 :
        (align_with == "below_nut") ? cap_head_h + length :
        (align_with == "above_nut") ? cap_head_h + length + nut_thickness : 0
    );

    /* screw head */
    translate ([0, 0, -elevation]) {
        translate ([0, 0, cap_head_h])
        mirror (Z)
        cylinder (d = cap_head_d, h = cap_head_h + head_extra_length);

        /* screw body */
        translate ([0, 0, cap_head_h - epsilon])
        cylinder (d = size + 0.3, h = length + screw_extra_length + epsilon);

        /* nut */
        translate ([0, 0, cap_head_h + length - epsilon])
        hull () {
            axis = (nut_projection == "axial") ? +Z : +X;

            mcad_linear_multiply (no = 2, separation = nut_projection_length,
                                  axis = axis)
            mcad_nut_hole (size = size);
        }
    }
}

module rounded_square (size, r)
{
    hull ()
    for (x = [-1, 1] * (size[0]/2 - r))
        for (y = [-1, 1] * (size[1]/2 - r))
            translate ([x, y])
            circle (r = r);
}

function sq (x) = x * x;

function chord_length (radius, normal_length) = (
    sqrt (sq (radius) - sq (normal_length))
);
