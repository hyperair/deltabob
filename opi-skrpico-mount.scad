use <MCAD/fasteners/nuts_and_bolts.scad>
use <MCAD/general/utilities.scad>
use <MCAD/shapes/3Dshapes.scad>
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

baseboard_mounting_screwholes = [
    [-10, 3],
    [opi3lts_screwholes[3][0] + 10, 3]
];

screw_size = 3;
screw_minor_d = 2.5;
screwhole_d = 3.3;
screwhead_d = mcad_metric_bolt_cap_diameter(screw_size);
screwhead_h = mcad_metric_bolt_cap_height(screw_size);

baseboard_thickness = 2;
baseboard_corner_d = screwhole_d + 4;
baseboard_mounting_screw_size = 5;
baseboard_mounting_screwhole_d = 5.3;
baseboard_mounting_arm_width = 10;

opi3lts_pcb_thickness = 1;
opi3lts_elevation = 3;
skrpico_elevation = 25;
skrpico_pcb_thickness = 1;

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
    difference() {
        union() {
            /* base board */
            linear_extrude(height=baseboard_thickness) {
                offset(r=-5)
                offset(r=5)
                union() {
                    /* base board base shape */
                    hull() {
                        place_screwholes(opi3lts_screwholes)
                        circle(d=baseboard_corner_d);
                    }

                    /* mounting arms */
                    hull() {
                        place_screwholes(baseboard_mounting_screwholes)
                        circle(d=baseboard_mounting_arm_width);
                    }
                }
            }

            /* mounting screw posts for opi3lts */
            linear_extrude(height=baseboard_thickness + opi3lts_elevation)
            place_screwholes(opi3lts_screwholes)
            circle(d=baseboard_corner_d);
        }

        /* opi3lts screwholes */
        linear_extrude(height=100, center=true)
        place_screwholes(opi3lts_screwholes)
        circle(d=screwhole_d);

        /* opi3lts cap screw head holes */
        translate([0, 0, -epsilon])
        linear_extrude(height=screwhead_h)
        place_screwholes(opi3lts_screwholes)
        circle(d=screwhead_d);

        /* mounting screwholes */
        linear_extrude(height=100, center=true)
        place_screwholes(baseboard_mounting_screwholes)
        circle(d=screwhole_d);
    }
}


module offset_standoff(point1, point2, height)
{
    normalized_point2 = point2 - point1;
    point2_polar = conv2D_cartesian2polar(normalized_point2);

    distance = point2_polar[0];
    angle = point2_polar[1];

    nut_af_size = mcad_metric_nut_af_width(screw_size);
    nut_height = mcad_metric_nut_thickness(screw_size) * 2;

    translate(point1)
    rotate(angle, Z)
    difference() {
        union() {
            /* bottom nut */
            hexagon_prism(height=nut_height, across_flats=nut_af_size);

            /* top nut */
            translate([distance, 0, height])
            mirror(Z)
            hexagon_prism(height=nut_height, across_flats=nut_af_size);

            /* joining section */
            hull() {
                translate([0, 0, nut_height - epsilon])
                hexagon_prism(height=epsilon, across_flats=nut_af_size);

                translate([distance, 0, height - nut_height + epsilon])
                mirror(Z)
                hexagon_prism(height=epsilon, across_flats=nut_af_size);
            }
        }

        /* bottom screwhole */
        translate([0, 0, -epsilon])
        cylinder(d=screw_minor_d, h=nut_height * 2);

        /* top screwhole */
        translate([distance, 0, height + epsilon])
        mirror(Z)
        cylinder(d=screw_minor_d, h=nut_height * 2);
    }
}


module all_offset_standoffs()
{
    standoff_elevation = opi3lts_elevation + opi3lts_pcb_thickness;
    standoff_height = skrpico_elevation - standoff_elevation;

    /* align bottom right holes */
    skrpico_offset = skrpico_screwholes[1] - opi3lts_screwholes[1];

    module offset_standoff_for_idx(idx)
    {
        offset_standoff(
            opi3lts_screwholes[idx],
            skrpico_screwholes[idx] - skrpico_offset,
            standoff_height
        );
    }

    translate([0, 0, baseboard_thickness + standoff_elevation]) {
        for (idx = [0:3])
            offset_standoff_for_idx(idx);
    }
}


/* orange pi 3 lts ghost */
%
place_opi3lts()
opi3lts();


/* skr pico ghost */
%
place_skrpico()
skrpico();

base_board();

all_offset_standoffs();
