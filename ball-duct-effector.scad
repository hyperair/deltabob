use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>
include <e3dv5.scad>

effector_duct_d = 8;
effector_ring_d = 60;
effector_wall_thickness = 1;
effector_duct_od = effector_duct_d + effector_wall_thickness * 2;

effector_duct_exit_channnel_width = 1;
effector_duct_exit_angle = 45;
effector_duct_round_top = false;

$fs = 0.4;
$fa = 1;

module ring_duct ()
{
    duct_d = effector_duct_d;
    ring_d = effector_ring_d;
    wall_thickness = effector_wall_thickness;

    exit_channel_width = effector_duct_exit_channnel_width;
    exit_angle = effector_duct_exit_angle;
    round_top = effector_duct_round_top;

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

module effector ()
{
    screwhole_d = 3;
    screwhole_od = screwhole_d + effector_wall_thickness * 2;

    module place_screwholes ()
    {
        for (i = [0:5])
            rotate (360 / 6 * i, Z)
                translate ([effector_ring_d / 2, 0, 0])
                children ();
    }

    module screwhole_pillar ()
    {
        cylinder (d = screwhole_od, h = effector_duct_od);
    }

    module screwhole ()
    {
        translate ([0, 0, -epsilon])
        mcad_polyhole (d = screwhole_d, h = effector_duct_od + epsilon * 2);
    }

    difference () {
        union () {
            ring_duct ();

            place_screwholes ()
                screwhole_pillar ();
        }

        place_screwholes ()
            screwhole ();
    }
}

%translate ([0, 0, -e3dv6_nozzle_outer_h])
e3dv5 ();

effector ();
