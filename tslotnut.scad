use <MCAD/fasteners/nuts_and_bolts.scad>
include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

module trapezoid (top, bottom, h)
{
    polygon ([
            [-bottom / 2, 0],
            [-top / 2, h],
            [top / 2, h],
            [bottom / 2, 0]
        ]);
}

module tslotnut ()
{
    flat_height = 1;
    length = 15;

    inner_width = 5;
    outer_width = 11;

    rounding_r = 0.5;

    difference () {
        rotate (90, X)
        linear_extrude (height = length, center = true)
        offset (r = rounding_r)
        offset (r = -rounding_r)
        union () {
            translate ([0, flat_height - epsilon])
            trapezoid (top = inner_width, bottom = outer_width,
                h = (outer_width - inner_width) / 2);

            translate ([0, flat_height / 2])
            square ([outer_width, flat_height], center = true);
        }

        rotate (90, Z)
        translate ([0, 0, -epsilon])
        scale ([1, 1, 10])
        mcad_nut_hole (size = 5, clearance = 0.05);
    }
}

tslotnut ();
