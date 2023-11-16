use <dict.scad>

function PrintFanMount (
    fan,
    base_thickness,
    jaw_angle,
    jaw_cutout_length,
    jaw_length,
    jaw_width,
    jaw_y_offset,
) =
[
    ["fan", fan],
    ["base_thickness", base_thickness],
    ["jaw_angle", jaw_angle],
    ["jaw_cutout_length", jaw_cutout_length],
    ["jaw_length", jaw_length],
    ["jaw_width", jaw_width],
    ["jaw_y_offset", jaw_y_offset],
];

function print_fan_mount_get_fan (c) = dict_get (c, "fan");
function print_fan_mount_get_base_thickness (c) = dict_get (c, "base_thickness");
function print_fan_mount_get_jaw_angle (c) = dict_get (c, "jaw_angle");
function print_fan_mount_get_jaw_length (c) = dict_get (c, "jaw_length");
function print_fan_mount_get_jaw_cutout_length (c) = dict_get (c, "jaw_cutout_length");
function print_fan_mount_get_jaw_width (c) = dict_get (c, "jaw_width");
function print_fan_mount_get_jaw_y_offset (c) = dict_get (c, "jaw_y_offset");
