use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
include <MCAD/units/metric.scad>

mounting_screwsize = 5;
pcb_mounting_screwsize = 3;
tslot_screwsize = 5;
clearance = 0.3;

pcb_holes = [
    [-94/2, -43/2],
    [-94/2, 43/2],
    [94/2, 43/2],
    [94/2, -43/2]
];

wall_thickness = 5;

standoff_od = pcb_mounting_screwsize + wall_thickness * 2;
standoff_length = 3;
base_thickness = 3;

pcb_size = [102, 51, 2];

round_r = 2;

mounting_tab_od = mounting_screwsize + wall_thickness;


$fs = 0.4;
$fa = 1;


module place_pcb_screwholes ()
{
    for (pos = pcb_holes)
    translate (pos)
    children ();
}

module place_mounting_screwholes ()
{
    for (x = [1, -1] * (pcb_size[0] / 2 + mounting_tab_od / 2 + 2))
    translate ([x, pcb_size[1] / 2 - mounting_tab_od / 2, 0])
    children ();
}

module round (r)
{
    offset (r)
    offset (-r)
    children ();
}

module sanguino_shape ()
{
    round (4)
    square ([pcb_size[0], pcb_size[1]], center = true);
}

module mounting_tabs_shape ()
{
    hull ()
    place_mounting_screwholes ()
    circle (d = mounting_tab_od);
}

module sanguino_mount ()
{
    difference () {
        union () {
            linear_extrude (height = standoff_length + base_thickness)
            sanguino_shape ();

            linear_extrude (height = base_thickness)
            round (-3)
            union () {
                sanguino_shape ();
                mounting_tabs_shape ();
            }
        }

        translate ([0, 0, base_thickness])
        ccube ([pcb_size[0] - 15, pcb_size[1] + epsilon * 4,
                standoff_length + epsilon], center = X + Y);

        translate ([0, 0, base_thickness])
        ccube ([pcb_size[0] + epsilon * 4, pcb_size[1] - 15,
                standoff_length + epsilon], center = X + Y);

        place_pcb_screwholes ()
        mcad_polyhole (d = pcb_mounting_screwsize + clearance, h = 10000,
            center = true);

        place_pcb_screwholes ()
        translate ([0, 0, -epsilon])
        mcad_nut_hole (size = pcb_mounting_screwsize, tolerance = 0.05);

        place_mounting_screwholes ()
        mcad_polyhole (d = mounting_screwsize + clearance, h = 10000,
            center = true);
    }
}

sanguino_mount ();
