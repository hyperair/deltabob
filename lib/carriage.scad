use <dict.scad>

function Carriage (
    base_thickness, carriage_length, wheel_spacing, eccentric_od,
    wall_thickness,
    hinge_d, hinge_elevation, hinge_spacing,
    belt_clamp_tooth_count, belt_clamp_width, belt_clamp_height,
    belt_tensioner_block_width, belt_tensioner_block_height,
    belt_tensioner_block_length, belt_tensioner_block_hole_elevation,
    belt_tensioner_screw_distance,
    belt_offset, belt_width, belt_thickness,
    belt_doubled_thickness
) =
[
    ["base_thickness", base_thickness],
    ["carriage_length", carriage_length],
    ["wheel_spacing", wheel_spacing],
    ["eccentric_od", eccentric_od],
    ["wall_thickness", wall_thickness],

    ["hinge_d", hinge_d],
    ["hinge_elevation", hinge_elevation],
    ["hinge_spacing", hinge_spacing],

    ["belt_clamp_tooth_count", belt_clamp_tooth_count],
    ["belt_clamp_width", belt_clamp_width],
    ["belt_clamp_height", belt_clamp_height],

    ["belt_tensioner_block_width", belt_tensioner_block_width],
    ["belt_tensioner_block_height", belt_tensioner_block_height],
    ["belt_tensioner_block_length", belt_tensioner_block_length],
    ["belt_tensioner_block_hole_elevation", belt_tensioner_block_hole_elevation],

    ["belt_offset", belt_offset],
    ["belt_width", belt_width],
    ["belt_thickness", belt_thickness],
    ["belt_doubled_thickness", belt_doubled_thickness]
];

function carriage_get_hinge_spacing (c) = dict_get (c, "hinge_spacing");
function carriage_get_base_thickness (c) = dict_get (c, "base_thickness");
function carriage_get_base_width (c) = (
    let (wheel_spacing = carriage_get_wheel_spacing (c),
         eccentric_od = carriage_get_eccentric_od (c),
         wall_thickness = carriage_get_wall_thickness (c))

    wheel_spacing + eccentric_od + wall_thickness * 2
);
function carriage_get_wheel_spacing (c) = dict_get (c, "wheel_spacing");
function carriage_get_carriage_length (c) = dict_get (c, "carriage_length");
function carriage_get_eccentric_od (c) = dict_get (c, "eccentric_od");
function carriage_get_wall_thickness (c) = dict_get (c, "wall_thickness");

function carriage_get_hinge_d (c) = dict_get (c, "hinge_d");
function carriage_get_hinge_elevation (c) = dict_get (c, "hinge_elevation");

function carriage_get_belt_clamp_tooth_count (c) = (
    dict_get (c, "belt_clamp_tooth_count")
);
function carriage_get_belt_clamp_width (c) = dict_get (c, "belt_clamp_width");
function carriage_get_belt_clamp_height (c) = dict_get (c, "belt_clamp_height");
function carriage_get_belt_clamp_length (c) = (
    let (belt_clamp_tooth_count = carriage_get_belt_clamp_tooth_count (c))

    belt_clamp_tooth_count * 2
);

function carriage_get_belt_tensioner_block_width (c) = (
    dict_get (c, "belt_tensioner_block_width")
);
function carriage_get_belt_tensioner_block_height (c) = (
    dict_get (c, "belt_tensioner_block_height")
);
function carriage_get_belt_tensioner_block_length (c) = (
    dict_get (c, "belt_tensioner_block_length")
);
function carriage_get_belt_tensioner_block_hole_elevation (c) = (
    dict_get (c, "belt_tensioner_block_hole_elevation")
);
function carriage_get_belt_tensioner_screw_distance (c) = (
    let (belt_tensioner_block_width = carriage_get_belt_tensioner_block_width (
             c),
         belt_doubled_thickness = carriage_get_belt_doubled_thickness (c))

    (belt_tensioner_block_width + belt_doubled_thickness) / 2
);

function carriage_get_belt_offset (c) = dict_get (c, "belt_offset");
function carriage_get_belt_width (c) = dict_get (c, "belt_width");
function carriage_get_belt_thickness (c) = dict_get (c, "belt_thickness");
function carriage_get_belt_doubled_thickness (c) = (
    dict_get (c, "belt_doubled_thickness")
);
