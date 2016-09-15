include <MCAD/units/metric.scad>

module gt2_belt (tooth_count, thickness, width, $fs = 0.01, $fa = 1)
{
    belt_clearance = 0.1;

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
        square ([2.5, thickness - 0.75]);
    }
}
