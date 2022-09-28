include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

opi3lts_screwholes = [
    [0, 0],                     /* bottom left */
    [79, 0],                    /* bottom right */
    [0, 50],                    /* top left */
    [79, 50]                    /* top right */
];

skrpico_screwholes = [
    [0, 0],                     /* bottom left */
    [58, 0],                    /* bottom right */
    [0, 49],                    /* top left */
    [58, 49],                   /* top right */
];

screwhole_d = 3.3;
baseboard_thickness = 2;

opi3lts_elevation = 3;
skrpico_elevation = 25;


module place_screwholes(screwholes)
{
    for (pos = screwholes) {
        translate(pos) {
            children();
        }
    }
}

module opi3lts()
{
    /* centered on the bottom left hole, and placed on Z=0 plane */
    translate([0, 0, -10.3])
    translate([0, 56] - [3, 3])
    import("vitamins/orange-pi3-lts.stl");
}

module skrpico()
{
    translate([0, 0, -6.276])
    translate([-1, -1] * 3.5)
    import("vitamins/skr-pico-v1.stl");
}

module place_opi3lts()
{
    translate([0, 0, baseboard_thickness + opi3lts_elevation])
    children();
}

module place_skrpico()
{
    rotate(180, Z)
    translate(
        - skrpico_screwholes[3]
        + skrpico_screwholes[1]
        - opi3lts_screwholes[1]
    )
    translate([0, 0, baseboard_thickness + skrpico_elevation])
    children();
}


module stepped_standoff()
{
    cylinder(d=6.35, $fn=6);
}


module base_board()
{
    baseboard_corner_d = screwhole_d + 3;

    difference() {
        union() {
            /* base board */
            linear_extrude(height=baseboard_thickness)
            hull() {
                place_screwholes(opi3lts_screwholes)
                circle(d=baseboard_corner_d);
            }

            /* mounting screw posts for opi3lts */
            linear_extrude(height=baseboard_thickness + opi3lts_elevation)
            place_screwholes(opi3lts_screwholes)
            circle(d=baseboard_corner_d);
        }

        linear_extrude(height=100, center=true)
        place_screwholes(opi3lts_screwholes)
        circle(d=screwhole_d);
    }
}


/* orange pi 3 lts ghost */
%
place_opi3lts()
opi3lts();


%
place_skrpico()
skrpico();

base_board();
