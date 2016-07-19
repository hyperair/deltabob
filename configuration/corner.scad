include <MCAD/motors/stepper.scad>
include <delta.scad>
include <extrusions.scad>

corner_wall_thickness = 5;
corner_diagonal_wall_thickness = corner_wall_thickness / sin(60);

nema17_axle_length = lookup (NemaFrontAxleLength, Nema17);
nema17_width = motorWidth (Nema17);
gt2_pulley_length = 10;

// assumes that top < base. use -h for base > top
function _corner_find_trapezoid_base (top, h) = top + h / tan(60) * 2;
function _corner_find_trapezoid_height (top, bottom) = (
    (bottom - top) / 2 * tan(60)
);

corner_hext_corner_distance = (
    extrusions_v_profile[0] + 2 *
    corner_wall_thickness
);

corner_median_line_length = (
    corner_hext_corner_distance +
    extrusions_h_profile[0] / cos(30) * 2
);

corner_cavity_trapezoid_top = _corner_find_trapezoid_base (
    top = corner_hext_corner_distance - 2 * corner_diagonal_wall_thickness,
    h = corner_wall_thickness
);

corner_cavity_axial_length = max (
    nema17_axle_length - corner_wall_thickness + gt2_pulley_length,
    _corner_find_trapezoid_height (
        bottom = nema17_width + 2 * corner_diagonal_wall_thickness,
        top = corner_cavity_trapezoid_top
    )
);

corner_arm_length = (corner_cavity_axial_length + corner_wall_thickness) * 2 / cos(30);

corner_bottom_height = (
    extrusions_h_profile[1] * extrusions_h_number +
    extrusions_h_gap * (extrusions_h_number - 1)
);
