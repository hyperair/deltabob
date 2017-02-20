use <MCAD/array/along_curve.scad>
use <MCAD/shapes/2Dshapes.scad>
include <MCAD/units/metric.scad>

include <configuration/delta.scad>
use <lib/delta.scad>
use <lib/effector.scad>

$fs = 0.4;
$fa = 1;

module effector_place_hinge (opts)
{
    hinge_elevation = effector_get_hinge_elevation (opts);

    translate ([0, 0, hinge_elevation])
    rotate (-45, X)
    children ();
}

module effector_single_hinge (opts, mode = "full")
{
    hinge_d = effector_get_hinge_d (opts);
    wall_thickness = effector_get_wall_thickness (opts);
    hinge_elevation = effector_get_hinge_elevation (opts);

    hinge_od = hinge_d + wall_thickness * 2;

    module hinge_ball ()
    {
        sphere (d = hinge_d);
    }

    module hinge_peg ()
    {
        translate ([0, 0, -hinge_d * 0.1])
        mirror (Z)
        cylinder (d = hinge_od, h = 30);
    }

    effector_place_hinge (opts)
    if (mode == "full") {
        difference () {
            hinge_peg ();
            hinge_ball ();
        }
    } else if (mode == "peg") {
        hinge_peg ();
    } else if (mode == "ball") {
        hinge_ball ();
    }
}

module effector_hinge_pair (opts, mode = "full")
{
    hinge_spacing = effector_get_hinge_spacing (opts);

    translate ([-hinge_spacing / 2, 0])
    mcad_linear_multiply (
        no = 2, separation = hinge_spacing, axis = X)
    effector_single_hinge (opts, mode = mode);
}

module effector_place_hinge_pairs (opts)
{
    hinge_offset = effector_get_hinge_offset (opts);

    mcad_rotate_multiply (no = 3, angle = 120)
    translate ([0, hinge_offset])
    children ();
}

module effector_all_hinges (opts, mode = "full")
{
    effector_place_hinge_pairs (opts)
    effector_hinge_pair (opts, mode = mode);
}

module effector_tether_block (opts)
{
    wall_thickness = effector_get_wall_thickness (opts);

    effector_place_hinge (opts)
    mirror (Z)
    cylinder (d = 2 + wall_thickness * 2, h = 100);
}

module effector_probe_ears (opts);

module effector (opts)
{
    thickness = effector_get_thickness (opts);
    cavity_d = effector_get_cavity_d (opts);

    render ()
    difference () {
        union () {
            /* basic solid shape */
            intersection () {
                hull ()
                effector_all_hinges (opts, mode = "peg");

                ccube ([1000, 1000, thickness], center = X + Y);
            }

            difference () {
                union () {
                    /* full hinge pegs */
                    effector_all_hinges (opts, mode = "peg");

                    /* tether block */
                    effector_place_hinge_pairs (opts)
                    effector_tether_block (opts);
                }

                mirror (Z)
                ccube ([1000, 1000, 100], center = X + Y);
            }
            effector_probe_ears (opts);
        }

        /* center cavity */
        translate ([0, 0, -epsilon])
        cylinder (d = cavity_d, h = thickness + epsilon * 2);

        /* hinge balls */
        effector_all_hinges (opts, mode = "ball");

        /* tether holes */
        effector_place_hinge_pairs (opts)
        cylinder (d = 2, h = 30, center = true);
    }
}

effector (delta_get_effector (deltabob));
