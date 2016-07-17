use <dict.scad>
use <corner.scad>

function Delta (
    v_aluex,
    h_aluex,

    v_aluex_orientation,

    delta_radius,
    rod_length,
    hinge_spacing,
) =
[
    ["v_aluex", v_aluex],
    ["h_aluex", h_aluex],

    ["delta_radius", delta_radius],
    ["rod_length", rod_length],
    ["hinge_spacing", hinge_spacing],

    ["bottom_corner", CornerBottom (v_aluex = v_aluex,
                                    h_aluex = h_aluex,
                                    num_h_aluex = num_h_aluex)],
    ["top_corner", CornerTop (v_aluex = v_aluex,
                              h_aluex = h_aluex,
                              num_h_aluex = num_h_aluex)],
    ["carriage", carriage],
];

function delta_get_bottom_corner (d) = dict_get (d, "bottom_corner");
function delta_get_top_corner (d) = dict_get (d, "bottom_corner");
