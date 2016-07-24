use <aluex.scad>
use <dict.scad>

function CornerBlank (
    v_aluex,
    v_aluex_orientation,

    h_aluex,
    h_aluex_num,
    h_aluex_separation,

    v_screwhole_positions,
    h_screwholes_positions,

    wall_thickness,
    cavity_width,
    arm_length,
) =
[
    ["v_aluex", v_aluex],
    ["v_aluex_orientation", v_aluex_orientation],

    ["h_aluex", h_aluex],
    ["h_aluex_num", h_aluex_num],
    ["h_aluex_separation", h_aluex_separation],

    ["v_aluex_screwholes", v_aluex_screwholes],
    ["h_aluex_screwholes", h_aluex_screwholes],

    ["wall_thickness", wall_thickness],
    ["cavity_width", cavity_width],
    ["arm_length", arm_length]
];


function corner_get_v_aluex (c) = dict_get (c, "v_aluex");
function corner_get_v_aluex_orientation (c) =
(
    dict_get (c, "v_aluex_orientation")
);

function corner_get_h_aluex (c) = dict_get (c, "h_aluex");
function corner_get_h_aluex_num (c) = dict_get (c, "h_aluex_num");
function corner_get_h_aluex_separation (c) = dict_get (c, "h_aluex_separation");

function corner_get_v_aluex_screwholes (c) =
(
    dict_get (c, "v_aluex_screwholes")
);

function corner_get_h_aluex_screwholes (c) =
(
    dict_get (c, "h_aluex_screwholes")
);

function corner_get_wall_thickness (c) = dict_get (c, "wall_thickness");
function corner_get_cavity_width (c) = dict_get (c, "cavity_width");
function corner_get_arm_length (c) = dict_get (c, "arm_length");

function corner_get_h_aluex_width (c) =
(
    aluex_size (corner_get_h_aluex (c))[0]
);

function corner_get_h_aluex_height (c) =
(
    aluex_size (corner_get_h_aluex (c))[1]
);

function corner_get_v_aluex_circumferential (c) =
(
    let (orientation = corner_get_v_aluex_orientation (c),
         idx = (orientation == "circumferential" ? 1 : 0))

    aluex_size (corner_get_v_aluex (c))[idx]
);

function corner_get_v_aluex_radial (c) =
(
    let (orientation = corner_get_v_aluex_orientation (c),
         idx = (orientation == "circumferential" ? 0 : 1))

    aluex_size (corner_get_v_aluex (c))[idx]
);

function corner_get_height (c) =
(
    let (h_aluex_height = corner_get_h_aluex_height (c),
         h_aluex_num = corner_get_h_aluex_num (c),
         h_aluex_separation = corner_get_h_aluex_separation (c))

    h_aluex_height * h_aluex_num +
    h_aluex_separation * (h_aluex_num - 1)
);

function corner_get_h_corner_separation (c) =
(
    let (v_circ = corner_get_v_aluex_circumferential (c),
         wall_thickness = corner_get_wall_thickness (c))

    wall_thickness * 2 + v_circ
);

function corner_get_median_line_length (c) =
(
    corner_get_h_corner_separation (c) +
    2 * corner_get_h_aluex_width (c) / cos(30)
);

function corner_get_diagonal_wall_thickness (c) =
(
    corner_get_wall_thickness (c) / sin(60)
);

function corner_get_cavity_trapezoid_top (c) =
(
    corner_find_trapezoid_base (
        top = (
            corner_get_h_corner_separation (c) -
            2 * corner_get_diagonal_wall_thickness (c)
        ),
        h = corner_get_wall_thickness (c)
    )
);

function corner_find_trapezoid_base (top, h) = top + h / tan(60) * 2;
function corner_find_trapezoid_height (top, bottom) = (
    (bottom - top) / 2 * tan(60)
);


function CornerBottom (v_aluex,
                       v_aluex_orientation,

                       h_aluex,
                       h_aluex_num,
                       h_aluex_separation,

                       wall_thickness,
                       cavity_width,
                       arm_length,

                       motor) =
[
    ["corner_blank", CornerBlank (v_aluex = v_aluex,
                                  v_aluex_orientation = v_aluex_orientation,

                                  h_aluex = h_aluex,
                                  h_aluex_num = h_aluex_num,
                                  h_aluex_separation = h_aluex_separation,

                                  v_aluex_screwholes = v_aluex_screwholes,
                                  h_aluex_screwholes = h_aluex_screwholes,

                                  wall_thickness = wall_thickness,
                                  cavity_width = cavity_width,
                                  arm_length = arm_length)],
    ["motor", motor]
];

function corner_bottom_get_blank (c) = dict_get (c, "corner_blank");
function corner_bottom_get_motor (c) = dict_get (c, "motor");

function CornerTop (v_aluex,
                    v_aluex_orientation,

                    h_aluex,
                    h_aluex_num,
                    h_aluex_separation,

                    wall_thickness,
                    cavity_width,
                    arm_length) =
[
    ["corner_blank", CornerBlank (v_aluex = v_aluex,
                                  v_aluex_orientation = v_aluex_orientation,

                                  h_aluex = h_aluex,
                                  h_aluex_num = h_aluex_num,
                                  h_aluex_separation = h_aluex_separation,

                                  v_aluex_screwholes = v_aluex_screwholes,
                                  h_aluex_screwholes = h_aluex_screwholes,

                                  wall_thickness = wall_thickness,
                                  cavity_width = cavity_width,
                                  arm_length = arm_length)]
];

function corner_top_get_blank (c) = dict_get (c, "corner_blank");
