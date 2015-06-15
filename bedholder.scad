use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/fasteners/metric_fastners.scad>
include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

bed_d = 240;
bolt_d = 5.3;

holder_size = 24;

bolt_offset = -holder_size / 4;

base_thickness = 5;
bed_thickness = 12;

difference () {
    ccube ([holder_size, holder_size, base_thickness + bed_thickness],
        center = X + Y);

    translate ([bed_d / 2, 0, base_thickness]) cylinder(d = bed_d, h = 1000);

    translate ([bolt_offset, 0, 0]) {
        mcad_polyhole (d = 5.3, h = 1000, center = true);

        translate ([0, 0, base_thickness])
        mcad_polyhole (d = 9, h = 1000);
    }
}
