include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>

$fs = 0.4;
$fa = 1;

spacer_id = M3 + 0.8 * length_mm;
spacer_od = length_mm (5);
spacer_length = 2;

rotate_extrude () {
    translate ([spacer_id / 2, 0])
    square ([(spacer_od - spacer_id) / 2, spacer_length]);
}
