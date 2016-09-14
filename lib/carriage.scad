use <dict.scad>

function Carriage (hinge_spacing, base_thickness, wheel_spacing,
                   carriage_length, eccentric_od, wall_thickness,
                   hinge_d, hinge_elevation) =
[
    ["hinge_spacing", hinge_spacing],
    ["base_thickness", base_thickness],
    ["wheel_spacing", wheel_spacing],
    ["carriage_length", carriage_length],
    ["eccentric_od", eccentric_od],
    ["wall_thickness", wall_thickness],
    ["hinge_d", hinge_d],
    ["hinge_elevation", hinge_elevation]
];

function carriage_get_hinge_spacing (c) = dict_get (c, "hinge_spacing");
function carriage_get_base_thickness (c) = dict_get (c, "base_thickness");
function carriage_get_wheel_spacing (c) = dict_get (c, "wheel_spacing");
function carriage_get_carriage_length (c) = dict_get (c, "carriage_length");
function carriage_get_eccentric_od (c) = dict_get (c, "eccentric_od");
function carriage_get_wall_thickness (c) = dict_get (c, "wall_thickness");
function carriage_get_hinge_d (c) = dict_get (c, "hinge_d");
function carriage_get_hinge_elevation (c) = dict_get (c, "hinge_elevation");

function carriage_get_base_width (c) = (
    let (wheel_spacing = carriage_get_wheel_spacing (c),
         eccentric_od = carriage_get_eccentric_od (c),
         wall_thickness = carriage_get_wall_thickness (c))

    wheel_spacing + eccentric_od + wall_thickness * 2
);
