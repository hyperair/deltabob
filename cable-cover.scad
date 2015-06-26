/* Originally from http://www.thingiverse.com/thing:134506/, licensed under
 * CC-BY-SA
 */

use <MCAD/array/mirror.scad>
include <MCAD/units/metric.scad>

cover_length = 20; // the length of the cover
cover_thickness = 1.6;

/* [Hidden] */
wing_width = 1;
slot_width = 5;
slot_depth = 2.75;

lip_thickness = 2.2;

cover_width = 20;

grip_r = 0.8;
clearance = 0.3;

$fs = 0.4;
$fa = 1;

module cover(cover_len)
{

    union() {
	translate([0, -lip_thickness/2 - .95, 0])
	intersection() {
	    cube([cover_width/2, cover_thickness, cover_len], center=true);

	    translate([0, 3.5, 0])
	    cylinder(r=6, h=cover_len, center=true);
	}

	translate([-slot_width/2 + wing_width/2,0,0])
	cube([wing_width, slot_depth, cover_len], center=true);

	translate([slot_width/2 - wing_width/2,0,0])
	cube([wing_width, slot_depth, cover_len], center=true);

        mcad_mirror_duplicate (X)
	translate([slot_width/2 - wing_width/2 + clearance/2, 2.2/2 + 0.35, 0])
	cylinder(r=grip_r, h=cover_len, center=true, $fn=60);
    }
}

rotate(90, X)
cover(cover_length);
