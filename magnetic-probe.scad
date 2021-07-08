use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/triangles_pyramids.scad>

use <lib/delta.scad>
use <lib/probe.scad>
include <configuration/delta.scad>
include <configuration/resolution.scad>

use <effector.scad>
use <utils.scad>

function probe_ring_ir (probe, effector) = (
    let (magnet_orbit_r = effector_get_magnet_offset (effector),
         ring_width = probe_get_ring_width (probe))

    magnet_orbit_r - ring_width / 2
);

module probe (probe, effector)
{
    ball_thread_d = probe_get_ball_thread_d (probe);

    difference () {
        union () {
            probe_ring (probe, effector);
            probe_centreline (probe, effector);
            probe_foot (probe);
        }

        effector_place_magnets (effector)
        screwhole (ball_thread_d, 10, align_with = "above_head");
    }
}

module probe_centreline (probe, effector)
{
    probe_ring_ir = probe_ring_ir (probe, effector);
    probe_ring_width = probe_get_ring_width (probe);
    probe_ring_h = probe_get_ring_h (probe);

    ccube (
        [(probe_ring_ir + epsilon) * 2, probe_ring_width, probe_ring_h],
        center = X + Y
    );
}

module probe_ring (probe, effector)
{
    magnet_orbit_r = effector_get_magnet_offset (effector);
    probe_ring_h = probe_get_ring_h (probe);
    probe_ring_width = probe_get_ring_width (probe);

    linear_extrude (height = probe_ring_h)
    difference () {
        circle (r = magnet_orbit_r + probe_ring_width / 2);
        circle (r = magnet_orbit_r - probe_ring_width / 2);
    }
}

module probe_foot (probe)
{
    switch = probe_get_switch (probe);
    switch_width = microswitch_get_width (switch);
    switch_height = microswitch_get_height (switch);
    switch_length = microswitch_get_length (switch);
    switch_screwhole_positions = microswitch_get_screwhole_positions (switch);
    switch_screwhole_zoffset = microswitch_get_screwhole_zoffset (switch);
    switch_knob_position = microswitch_get_knob_position (switch);

    switch_yoffset = switch_length / 2 - switch_knob_position;

    switchplate_thickness = 2;

    foot_length = probe_get_ring_width (probe);
    foot_width = switch_width + switchplate_thickness;
    foot_depth = switch_height + 10;

    module place_switch ()
    {
        translate ([0, switch_yoffset, -foot_depth])
        children ();
    }

    render ()
    difference () {
        union () {
            translate ([-switchplate_thickness / 2, 0, epsilon])
            mirror (Z)
            ccube ([foot_width, foot_length, foot_depth], center = X + Y);

            /* switch extra plate */
            place_switch ()
            translate ([-foot_width / 2 - switchplate_thickness / 2, 0, epsilon])
            ccube ([switchplate_thickness, switch_length, switch_height],
                   center = Y);

            /* overhang support */
            overhang_length = (switch_length - foot_length) / 2 + switch_yoffset;
            translate ([-foot_width / 2 - switchplate_thickness / 2,
                        foot_length / 2 - epsilon,
                        -foot_depth + switch_height - epsilon])
            mirror (X)
            rotate (-90, Y)
            triangle (o_len = overhang_length + epsilon * 2,
                      a_len = overhang_length + epsilon,
                      depth = switchplate_thickness);
        }

        /* switch cutout */
        translate ([0, 0,-foot_depth])
        ccube ([switch_width, switch_length, switch_height + 5],
               center = X + Y);

        /* microswitch screwholes */
        place_switch ()
        translate ([0, 0, switch_screwhole_zoffset])
        for (ypos = switch_screwhole_positions) {
            translate ([0, - switch_length / 2 + ypos, 0])
            rotate (90, Y)
            cylinder (d = 2, h = 100, center = true);
        }
    }
}

effector = delta_get_effector (deltabob);
probe = delta_get_probe (deltabob);
probe (probe, effector);
