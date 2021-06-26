use <dict.scad>
use <corner.scad>
use <aluex.scad>
use <carriage.scad>
use <effector.scad>

function Delta (
    v_aluex,
    h_aluex,

    v_aluex_orientation,

    top_corner,
    bottom_corner,

    carriage,
    effector,
    probe,
    hotend,
    groovemount,
    /*
    rod,
    effector,
    */

    delta_radius,
    rod_length,
    hinge_spacing,

    plate_thickness,
    print_colour
) =
[
    ["v_aluex", v_aluex],
    ["h_aluex", h_aluex],
    ["v_aluex_orientation", v_aluex_orientation],

    ["bottom_corner", bottom_corner],
    ["top_corner", top_corner],

    ["carriage", carriage],
    ["effector", effector],
    ["probe", probe],
    ["hotend", hotend],
    ["groovemount", groovemount],

    ["delta_radius", delta_radius],
    ["rod_length", rod_length],
    ["hinge_spacing", hinge_spacing],

    ["plate_thickness", plate_thickness],
    ["print_colour", print_colour]
];

function delta_get_v_aluex (d) = dict_get (d, "v_aluex");
function delta_get_h_aluex (d) = dict_get (d, "h_aluex");

function delta_get_v_aluex_orientation (d) = dict_get (d, "v_aluex_orientation");

function delta_get_top_corner (d) = dict_get (d, "top_corner");
function delta_get_bottom_corner (d) = dict_get (d, "bottom_corner");

function delta_get_carriage (d) = dict_get (d, "carriage");
function delta_get_effector (d) = dict_get (d, "effector");
function delta_get_probe (d) = dict_get (d, "probe");
function delta_get_hotend (d) = dict_get (d, "hotend");
function delta_get_groovemount (g) = dict_get (g, "groovemount");

function delta_get_delta_radius (d) = dict_get (d, "delta_radius");
function delta_get_rod_length (d) = dict_get (d, "rod_length");
function delta_get_hinge_spacing (d) = dict_get (d, "hinge_spacing");

function delta_get_plate_thickness (d) = dict_get (d, "plate_thickness");
function delta_get_print_colour (d) = dict_get (d, "print_colour");

function delta_get_v_circumferential (d) =
(
    let (orientation = delta_get_v_aluex_orientation (d),
         v_profile = aluex_size (delta_get_v_aluex (d)),
         idx = (orientation == "circumferential" ? 1 : 0))

    v_profile[idx]
);

function delta_get_v_radial (d) =
(
    let (orientation = delta_get_v_aluex_orientation (d),
         v_profile = aluex_size (delta_get_v_aluex (d)),
         idx = (orientation == "circumferential" ? 0 : 1))

    v_profile[idx]
);

function delta_get_corner_offset (d) =
(
    let (delta_radius = delta_get_delta_radius (d),
         effector_radius = effector_get_hinge_offset (
             delta_get_effector (d)
         ),

         carriage = delta_get_carriage (d),
         carriage_hinge_offset = (
             carriage_get_base_thickness (carriage) +
             carriage_get_hinge_elevation (carriage) +
             1
         )
    )

    effector_radius + delta_radius + carriage_hinge_offset
);

/* this is the edge that forms from truncating the base triangle */
function delta_get_base_short_edge (d) = (
    let (corner_bottom = delta_get_bottom_corner (d),
         corner_blank = corner_bottom_get_blank (corner_bottom),

         v_circ = delta_get_v_circumferential (d),
         wall_thickness = corner_get_wall_thickness (corner_blank)
    )

    v_circ + wall_thickness * 2
);
