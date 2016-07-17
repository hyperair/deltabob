function CornerBlank (
    v_aluex,
    h_aluex,
    h_aluex_num,
    h_aluex_separation,

    wall_thickness,
    cavity_width,
) =
[
    ["v_aluex", v_aluex],
    ["h_aluex", h_aluex],
    ["h_aluex_num", h_aluex_num],
    ["h_aluex_separation", h_aluex_separation],

    ["wall_thickness", wall_thickness],
    ["cavity_width", cavity_width]
];


function corner_get_v_aluex (c) = dict_get (c, "v_aluex");
function corner_get_h_aluex (c) = dict_get (c, "h_aluex");
function corner_get_h_aluex_num (c) = dict_get (c, "h_aluex_num");
function corner_get_h_aluex_separation (c) = dict_get (c, "h_aluex_separation");

function corner_get_wall_thickness (c) = dict_get (c, "wall_thickness");
function corner_get_cavity_width (c) = dict_get (c, "cavity_width");

function corner_get_h_aluex_width (c) =
(
    aluex_get_profile (corner_get_h_aluex (c))[0];
)

function corner_get_h_aluex_height (c) =
(
    aluex_get_profile (corner_get_h_aluex (c))[1];
)

function corner_get_height (c) =
(
    let (h_aluex_height = corner_get_h_aluex_height (c),
         h_aluex_separation = corner_get_h_aluex_separation (c))

    h_aluex_height * h_aluex_num +
    h_aluex_separation * (h_aluex_num - 1)
);

function CornerBottom () =
[
];

function corner_bottom_get_blank (c) = dict_get (c, "corner_blank");

function CornerTop () =
[
];

function corner_top_get_blank (c) = dict_get (c, "corner_bblank");
