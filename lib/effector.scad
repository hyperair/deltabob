use <dict.scad>

function Effector (
    hinge_d, hinge_spacing, hinge_elevation, hinge_offset,
    cavity_d,
    wall_thickness,
    thickness,
    prong_width,
    prong_height,
    magnet_d
) =
[
    ["hinge_d", hinge_d],
    ["hinge_spacing", hinge_spacing],
    ["hinge_elevation", hinge_elevation],
    ["hinge_offset", hinge_offset],

    ["cavity_d", cavity_d],

    ["wall_thickness", wall_thickness],
    ["thickness", thickness],

    ["prong_width", prong_width],
    ["prong_height", prong_height],

    ["magnet_d", magnet_d]
];

function effector_get_hinge_d (e) = dict_get (e, "hinge_d");
function effector_get_hinge_r (e) = effector_get_hinge_d (e) / 2;
function effector_get_hinge_spacing (e) = dict_get (e, "hinge_spacing");
function effector_get_hinge_elevation (e) = dict_get (e, "hinge_elevation");
function effector_get_hinge_offset (e) = dict_get (e, "hinge_offset");

function effector_get_cavity_d (e) = dict_get (e, "cavity_d");
function effector_get_wall_thickness (e) = dict_get (e, "wall_thickness");

function effector_get_hinge_od (e) = (
    let (hinge_d = effector_get_hinge_d (e),
         wall_thickness = effector_get_wall_thickness (e))

    hinge_d + wall_thickness * 2
);

function effector_get_thickness (e) = dict_get (e, "thickness");

function effector_get_prong_width (e) = dict_get (e, "prong_width");
function effector_get_prong_height (e) = dict_get (e, "prong_height");
function effector_get_prong_orbit_r (e) = dict_get (e, "cavity_d") / 2 + 5;

function effector_get_magnet_d (e) = dict_get (e, "magnet_d");
