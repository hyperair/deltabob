use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/3Dshapes.scad>
use <MCAD/shapes/polyhole.scad>

include <MCAD/units/metric.scad>

use <corner.scad>
use <utils.scad>

include <configuration/delta.scad>
include <configuration/resolution.scad>


module corner_top (corner_top_options)
{
    blank = corner_top_get_blank (corner_top_options);
    height = corner_get_height (blank);
    idler_pos = height / 2;
    idler_axle_d = corner_top_get_idler_size (corner_top_options);
    cavity_width = corner_get_cavity_width (blank);
    wall_thickness = corner_get_wall_thickness (blank);

    render ()
    difference () {
        union () {
            corner_blank (blank);

            /* support for end of idler axle */
            h = 8;
            d = idler_axle_d + wall_thickness * 2;
            intersection () {
                translate ([0, wall_thickness - epsilon, idler_pos])
                rotate (-90, X)
                filleted_cylinder (
                    d1 = d + h * 2,
                    d2 = d,
                    h = h,
                    fillet_r = 3,
                    chamfer_r = 3
                );

                ccube ([1000, 1000, height], center = X + Y);
            }
        }

        translate ([0, 0, idler_pos])
        rotate (-90, X) {
            /* screwhole */
            translate ([0, 0, 1])
            mcad_polyhole (
                d = idler_axle_d + 0.3,
                h = cavity_width + wall_thickness * 2 + epsilon
            );

            /* nut hole */
            translate ([0, 0, wall_thickness + cavity_width - epsilon])
            mcad_nut_hole (size = idler_axle_d);
        }
    }
}

corner_top (delta_get_top_corner (deltabob));
