use <dict.scad>
use <corner.scad>

function Delta (
    v_aluex,
    h_aluex,

    v_aluex_orientation,

    top_corner,
    bottom_corner,

    carriage,
    effector,
    hotend,
    /*
    rod,
    effector,
    */

    delta_radius,
    rod_length,
    hinge_spacing,
) =
[
    ["v_aluex", v_aluex],
    ["h_aluex", h_aluex],
    ["v_aluex_orientation", v_aluex_orientation],

    ["bottom_corner", bottom_corner],
    ["top_corner", top_corner],

    ["carriage", carriage],
    ["effector", effector],
    ["hotend", hotend],

    ["delta_radius", delta_radius],
    ["rod_length", rod_length],
    ["hinge_spacing", hinge_spacing],
];

function delta_get_v_aluex (d) = dict_get (d, "v_aluex");
function delta_get_h_aluex (d) = dict_get (d, "h_aluex");

function delta_get_v_aluex_orientation (d) = dict_get (d, "v_aluex_orientation");

function delta_get_top_corner (d) = dict_get (d, "top_corner");
function delta_get_bottom_corner (d) = dict_get (d, "bottom_corner");

function delta_get_delta_radius (d) = dict_get (d, "delta_radius");
function delta_get_rod_length (d) = dict_get (d, "rod_length");
function delta_get_hinge_spacing (d) = dict_get (d, "hinge_spacing");

function delta_get_carriage (d) = dict_get (d, "carriage");
function delta_get_effector (d) = dict_get (d, "effector");
function delta_get_hotend (d) = dict_get (d, "hotend");

function delta_get_v_circumferential (d) =
(
    let (orientation = delta_get_v_aluex_orientation (d),
         v_profile = aluex_size (delta_get_v_aluex (d)),
         idx = (orientation == "circumferential" ? 1 : 0))

    v_profile[idx]
);
