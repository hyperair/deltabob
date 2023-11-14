use <dict.scad>

function PrintFanMount (
    fan,
    base_thickness,
) =
[
    ["fan", fan],
    ["base_thickness", base_thickness]
];

function print_fan_mount_get_fan (c) = dict_get (c, "fan");
function print_fan_mount_get_base_thickness (c) = dict_get (c, "base_thickness");
