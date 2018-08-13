use <MCAD/shapes/2Dshapes.scad>
include <MCAD/units/metric.scad>
use <utils.scad>

$fs = 0.4;
$fa = 1;

e3dv6_heaterblock_h = 11.5;
e3dv5_transition_length = 2.1;
e3dv6_nozzle_hex_h = 3;
e3dv6_nozzle_cone_h = 2;
e3dv6_nozzle_outer_h = e3dv6_nozzle_cone_h + e3dv6_nozzle_hex_h;

module e3dv5_sink ()
{
    sink_d = 25;
    sink_h = 31.8;
    whole_sink_h = 50.1;

    fin_gap_h = 2.2;
    fin_pair_h = 3.4;
    fin_h = fin_pair_h - fin_gap_h;

    small_fin_d = 16;

    sink_to_top_h = 18.3;
    thinner_h = 14.6 + (sink_to_top_h - fin_gap_h);

    module slice_out (h)
        ccube ([40, 40, h], center = X + Y);

    difference () {
        /* sink basic shape */
        cylinder (d = 25, h = 31.8);

        /* sink fins */
        for (i = [0:9])
            translate ([0, 0, fin_h + i * fin_pair_h])
                slice_out (fin_gap_h);
    }

    difference () {
        /* smaller fins + groove mount */
        translate ([0, 0, sink_h + fin_gap_h])
            cylinder (d = small_fin_d, h = sink_to_top_h);

        translate ([0, 0, whole_sink_h - 14.6])
            slice_out (14.6 - 12.3);

        translate ([0, 0, whole_sink_h - 9.3])
            slice_out (9.3 - 3.7);
    }

    /* sink center bore */
    stacked_cylinder ([
                          [9, 3 * fin_pair_h + sink_to_top_h],
                          [13, fin_pair_h],
                          [15, 5 * fin_pair_h + fin_h]
                      ]);

    /* groovemount groove d */
    translate ([0, 0, whole_sink_h - 12.3])
        cylinder (d = 12, h = 12.3);
}

module e3dv6_heaterblock ()
{
    translate ([-4.5, 0, 0])
    ccube ([20, 20, e3dv6_heaterblock_h], center = Y);
}

module e3dv5_break ()
{
    cylinder (d = 2.8, h = 40);
}

module e3dv6_nozzle ()
{
    translate ([0, 0, e3dv6_nozzle_cone_h])
        cylinder (d = 7 / sin (60), h = e3dv6_nozzle_hex_h, $fn = 6);

    cylinder (d1 = 1, d2 = 1 + e3dv6_nozzle_cone_h / tan (55) * 2,
              h = e3dv6_nozzle_cone_h);
}

module e3dv5 ()
{
    translate ([0, 0, e3dv6_nozzle_outer_h]) {
        e3dv6_heaterblock ();
        e3dv5_break ();

        translate ([0, 0, e3dv6_heaterblock_h + e3dv5_transition_length])
            e3dv5_sink ();
    }

    e3dv6_nozzle ();
}

e3dv5 ();
