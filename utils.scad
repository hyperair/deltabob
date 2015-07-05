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
