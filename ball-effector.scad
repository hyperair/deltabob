include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/2Dshapes.scad>
use <utils.scad>

hinge_separation = 50;
hinge_ball_d = 10;
hinge_ball_r = hinge_ball_d / 2;
hinge_ball_depth = 0.4 * hinge_ball_d;
hinge_chord_d = 2 * sqrt (pow (hinge_ball_r, 2) -
    pow ((hinge_ball_r - hinge_ball_depth), 2));
hinge_cylinder_d = hinge_chord_d + 2;
hinge_angle = 45;
hinge_offset = 30;
hinge_ball_elevation = 3;

platform_thickness = 8;
platform_hinge_offset = 33;
platform_ring_od = 60;
platform_ring_id = 40;

hotend_mount_screw_d = 4;
hotend_screws = 6;
clearance = 0.3;

string_hole_d = 2;

$fs = 0.4;
$fa = 15;

module effector ()
{
    module basic_shape ()
    {
        intersection () {
            hull ()
            place_hinges ()
            hinge ();

            ccube ([1000, 1000, platform_thickness], center = X + Y);
        }
    }

    module screwhole ()
    {
        mcad_polyhole (d = hotend_mount_screw_d, h = platform_thickness * 2.5,
            center = true);
    }

    module place_screwholes ()
    {
        for (i = [0:hotend_screws])
        rotate (i / hotend_screws * 360, Z)
        translate ([(platform_ring_od + platform_ring_id) / 2 / 2, 0])
        children ();
    }

    difference () {
        render ()
        union () {
            basic_shape ();

            place_hinges ()
            hinge ();
        }

        translate ([0, 0, hinge_ball_r + hinge_ball_elevation])
        place_hinges ()
        hinge_ball ();

        // center hole
        mcad_polyhole (d = platform_ring_id, h = platform_thickness * 2.5,
            center = true);

        place_screwholes ()
        screwhole ();

        place_hinge_pair ()
            translate ([0, 0, hinge_ball_r + hinge_ball_elevation])
            mcad_polyhole (d = string_hole_d, h = 1000, center = true);
    }
}

module hinge (subtract_ball = false)
{
    difference () {
        translate ([0, 0, hinge_ball_r + hinge_ball_elevation])
        rotate (-hinge_angle, X)
        difference () {
            h = platform_thickness * 2;

            translate ([0, 0, - hinge_ball_r + hinge_ball_depth])
            mirror (Z)
            cylinder (d = hinge_cylinder_d, h = h);

            if (subtract_ball)
            hinge_ball ();
        }

        // cut off bottom
        mirror (Z)
        ccube ([2, 2, 2] * 100, center = X + Y);
    }
}

module hinge_ball ()
{
    sphere (d = hinge_ball_d);
}

module place_hinge_pair ()
{
    for (angle = [0:120:360])
    rotate (angle - 90, Z)
    translate ([0, hinge_offset])
    children ();
}

module place_hinges ()
{
    place_hinge_pair ()
    for (x = [1, -1] * hinge_separation / 2)
    translate ([x, 0])
    children ();
}

effector ();
