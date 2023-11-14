include <MCAD/units/metric.scad>
use <MCAD/shapes/3Dshapes.scad>

include <configuration/delta.scad>
use <lib/fan.scad>

$fs = 0.4;
$fa = 1;

module fan (fan_opts)
{
    width = axial_fan_get_width (fan_opts);
    thickness = axial_fan_get_thickness (fan_opts);
    corner_radius = axial_fan_get_corner_radius (fan_opts);

    color ("#222")
    mcad_rounded_cube (
        [width, width, thickness],
        radius=corner_radius,
        sidesonly=true,
        center=X + Y
    );
}

module fan_place_screwholes (fan_opts)
{
    screw_distance = axial_fan_get_screw_distance (fan_opts);

    mcad_place_at ([
        [-width / 2, -width/2],
        [-width / 2, width/2],
        [width / 2, -width/2],
        [width / 2, width/2],
    ])
    children();
}

module fan_plate (opts)
{
    fan_opts = print_fan_mount_get_fan (opts);

    fan_width = axial_fan_get_width (fan_opts);
    thickness = axial_fan_get_thickness (fan_opts);
    corner_radius = axial_fan_get_corner_radius (fan_opts);

    mcad_rounded_cube ();
}

% axial_fan (
    print_fan_mount_get_fan (
        delta_get_print_fan_mount (deltabob)
    )
);
