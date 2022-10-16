use <MCAD/array/mirror.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>
use <utils.scad>
include <MCAD/units/metric.scad>

mounting_screwsize = 5;
pcb_mounting_screwsize = 3;
tslot_screwsize = 5;
clearance = 0.3;

pcb_holes = [
    [-77.42, -44.5],
    [-77.42, 44.5],
    [77.42, -44.5],
    [77.42, 44.5]
];

pcb_size = [161.5, 101, 2];
lip_thickness = 2;
lip_width = 2;
lip_base_width = 1.5;

wall_thickness = 3;

standoff_od = pcb_mounting_screwsize + wall_thickness * 2;
standoff_length = 4;
base_thickness = 4;

round_r = 2;

mounting_tab_od = mounting_screwsize + wall_thickness * 2;
mounting_screwhole_distance = 4;

pcb_plate_size = pcb_size + [1, 1, 0] * lip_width * 2;
split_overlap = 40;

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
    for (x = [1, -1] * (pcb_size[0] / 2 + mounting_tab_od / 2 +
            mounting_screwhole_distance))
    translate ([x, pcb_size[1] / 2 - mounting_tab_od / 2, 0])
    children ();
}

module round (r)
{
    offset (r)
    offset (-r)
    children ();
}

module pcb_shape ()
{
    square ([pcb_size[0], pcb_size[1]], center = true);
}

module pcb_plate_shape ()
{
    offset (r = lip_width)
    pcb_shape ();
}

module mounting_tabs_shape ()
{
    hull ()
    place_mounting_screwholes ()
    circle (d = mounting_tab_od);
}

module pcb_mount ()
{
    difference () {
        union () {
            difference () {
                union () {
                    linear_extrude (height = standoff_length + base_thickness +
                                    pcb_size[2])
                    pcb_plate_shape ();

                    linear_extrude (height = base_thickness)
                    round (-3)
                    union () {
                        pcb_plate_shape ();
                        mounting_tabs_shape ();
                    }
                }

                /* remove base area except lip */
                translate ([0, 0, base_thickness])
                linear_extrude (height = 100)
                offset (r = -lip_base_width)
                pcb_shape ();

                /* pcb area */
                translate ([0, 0, base_thickness + standoff_length])
                linear_extrude (height = 100)
                pcb_shape ();

                translate ([0, 0, base_thickness]) {
                    /* y-axis cutout */
                    ccube ([pcb_size[0] - 15, pcb_size[1] + 10, 100],
                           center = X + Y);

                    /* x-axis cutout */
                    ccube ([pcb_size[0] + 10, pcb_size[1] - 15, 100],
                           center = X + Y);
                }

                /* mounting screwholes */
                place_mounting_screwholes ()
                mcad_polyhole (d = mounting_screwsize + clearance, h = 10000,
                               center = true);
            }

            /* screwholes pegs */
            place_pcb_screwholes ()
            translate ([0, 0, epsilon])
            cylinder (d = pcb_mounting_screwsize + wall_thickness * 2,
                      h = standoff_length + base_thickness - epsilon);
        }

        place_pcb_screwholes ()
        mcad_polyhole (d = pcb_mounting_screwsize + clearance, h = 10000,
            center = true);

        place_pcb_screwholes ()
        translate ([0, 0, -epsilon])
        scale ([1, 1, 1.1])
        mcad_nut_hole (size = pcb_mounting_screwsize, tolerance = 0.05);
    }
}

module pcb_mount_cutout (side = "left")
{
    difference () {
        pcb_mount ();

        mirror_if (side != "left")
        translate ([-split_overlap / 2, 0, -epsilon])
        ccube ([500, 500, 100], center = Y);
    }

}

module pcb_mount_left ()
{
    third_width = pcb_plate_size[1] / 3;

    pcb_mount_cutout ("left");

    translate ([-split_overlap / 2 - epsilon, 0, 0])
    ccube ([split_overlap, third_width, base_thickness / 2 - clearance],
           center = Y);

    mcad_mirror_duplicate (Y)
    translate ([-split_overlap / 2 - epsilon, -pcb_plate_size[1] / 2,
                base_thickness / 2 + clearance])
    ccube ([split_overlap, third_width, base_thickness / 2 - clearance]);
}

module pcb_mount_right ()
{
    third_width = pcb_plate_size[1] / 3;

    pcb_mount_cutout ("right");

    translate ([-split_overlap / 2 + epsilon, 0,
                base_thickness / 2 + clearance])
    ccube ([split_overlap, third_width, base_thickness / 2 - clearance],
           center = Y);

    mcad_mirror_duplicate (Y)
    translate ([-split_overlap / 2 + epsilon, -pcb_plate_size[1] / 2, 0])
    ccube ([split_overlap, third_width, base_thickness / 2 - clearance]);
}

*pcb_mount_left ();

*translate ([split_overlap + clearance, 0, 0])
pcb_mount_right ();

pcb_mount ();
