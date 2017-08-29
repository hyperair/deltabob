use <dict.scad>
use <fan.scad>
use <hotend.scad>

function Groovemount (
    hotend, fan, fan_inset_depth, fan_offset, wall_thickness) = [
    ["hotend", hotend],
    ["fan", fan],
    ["fan_inset_depth", fan_inset_depth],
    ["fan_offset", fan_offset],
    ["wall_thickness", wall_thickness]
];

function groovemount_get_hotend (g) = dict_get (g, "hotend");
function groovemount_get_fan (g) = dict_get (g, "fan");
function groovemount_get_fan_inset_depth (g) = dict_get (g, "fan_inset_depth");
function groovemount_get_fan_offset (g) = dict_get (g, "fan_offset");
function groovemount_get_wall_thickness (g) = dict_get(g, "wall_thickness");
function groovemount_get_exit_channel_width (g) = (
    let (hotend = groovemount_get_hotend (g),
         hotend_sink_d = hotend_get_sink_d (hotend))
    0.6 * hotend_sink_d
);

function groovemount_get_fan_outer_width (g) = (
    let (fan = groovemount_get_fan (g),
         fan_width = axial_fan_get_width (fan),
         wall_thickness = groovemount_get_wall_thickness (g))
    fan_width + wall_thickness * 2
);
