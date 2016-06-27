include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

module ring_duct (
    duct_d = 8,
    ring_d = 60,
    wall_thickness = 1,

    exit_channel_width = 1,
    exit_angle = 45,
    round_top = false
)
{
    duct_od = duct_d + wall_thickness * 2;
    ring_r = ring_d / 2;

    translate ([0, 0, duct_od / 2])
        rotate_extrude ()
        translate ([ring_r, 0])
        difference () {
        // body
        if (round_top) {
            hull () {
                circle (d = duct_od);

                translate ([0, -duct_od / 4])
                    square ([duct_od, duct_od / 2], center = true);
            }
        } else {
            square (duct_od, center = true);
        }

        // main duct area
        circle (d = duct_d);

        // exit cutout
        translate ([-0.5, -0.5] * duct_od + [wall_thickness, 0])
            rotate (-exit_angle, Z)
            square ([exit_channel_width, duct_od * .75]);
    }
}

ring_duct ();
