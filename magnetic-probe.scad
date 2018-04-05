use <lib/delta.scad>
use <lib/probe.scad>
include <configuration/delta.scad>
include <configuration/resolution.scad>

use <effector.scad>
use <utils.scad>


module probe (probe, effector)
{
    ball_thread_d = probe_get_ball_thread_d (probe);

    difference () {
        union () {
            probe_ring (probe, effector);
        }

        effector_place_magnets (effector)
        screwhole (ball_thread_d, 10, align_with = "above_head");
    }
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

effector = delta_get_effector (deltabob);
probe = delta_get_probe (deltabob);
probe (probe, effector);
