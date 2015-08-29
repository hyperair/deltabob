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

$fs = 0.4;
$fa = 1;

module effector ()
{
    module basic_shape ()
    {
        quadrant_angle = (2 * atan (
                hinge_separation / (2 * platform_hinge_offset)));
        hinge_distance_from_center = sqrt (
            pow (hinge_separation / 2, 2) +
            pow (platform_hinge_offset, 2));

        linear_extrude (height = platform_thickness)
        difference () {
            offset (r = 5)
            offset (r = -5)
            hull ()
            for (angle = [0:120:360]) {
                rotate (angle, Z)
                intersection () {
                    pieSlice (size = hinge_distance_from_center,
                        start_angle = -quadrant_angle / 2,
                        end_angle = +quadrant_angle / 2);

                    translate ([0, -hinge_separation])
                    square ([platform_hinge_offset, hinge_separation * 2]);
                }
            }
            circle (d = platform_ring_id);

            place_screwholes ()
            screwhole ();
        }
    }

    module screwhole ()
    {
        mcad_polyhole (d = hotend_mount_screw_d);
    }

    module place_screwholes ()
    {
        for (i = [0:hotend_screws])
        rotate (i / hotend_screws * 360, Z)
        translate ([(platform_ring_od + platform_ring_id) / 2 / 2, 0])
        children ();
    }

    basic_shape ();

    place_hinges ()
    hinge ();
}

module hinge ()
{
    difference () {
        translate ([0, 0, hinge_ball_r + hinge_ball_elevation])
        rotate (-hinge_angle, X)
        difference () {
            h = platform_thickness * 2;

            translate ([0, 0, - hinge_ball_r + hinge_ball_depth])
            mirror (Z)
            cylinder (d = hinge_chord_d + 2, h = h);

            #sphere (d = hinge_ball_d);
        }

        // cut off bottom
        mirror (Z)
        ccube ([2, 2, 2] * 100, center = X + Y);
    }
}

module place_hinges ()
{
    for (angle = [0:120:360])
    rotate (angle - 90, Z)
    translate ([0, hinge_offset])
    for (x = [1, -1] * hinge_separation / 2)
    translate ([x, 0])
    children ();
}

effector ();
