use <MCAD/shapes/polyhole.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
include <MCAD/units/metric.scad>

mount_length = 10;

microswitch_width = 12.8;
microswitch_hole_separation = 6.5;
microswitch_hole_base_offset = 5.2;
extrusion_width = 40;

mount_thickness = 3;

module place_mount_holes ()
{
    translate ([0, mount_length / 2]) {
        translate ([10, 0])
        children ();

        translate ([30, 0])
        children ();
    }
}

module place_microswitch ()
{
    translate ([extrusion_width, 0])
    children ();
}

module place_microswitch_holes ()
{
    place_microswitch ()
    for (x = [1, -1] * microswitch_hole_separation / 2)
    translate ([microswitch_width / 2 + x, microswitch_hole_base_offset])
    children ();
}

module m2_nut ()
{
     cylinder ($fn = 6, d = 4.32, h = 1.6);
}

module endstop ()
{
    difference () {
        cube ([extrusion_width + microswitch_width + 1,
                mount_length, mount_thickness]);

        place_mount_holes ()
        mcad_polyhole (d = 5, h = 1000, center = true);

        place_microswitch_holes () {
            mcad_polyhole (d = 2, h = 1000, center = true);

            translate ([0, 0, -0.8])
            m2_nut ();
        }
    }
}

endstop ();
