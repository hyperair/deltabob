use <dict.scad>

function Microswitch (
    length, width, height,
    pin_positions,
    screwhole_positions,
    knob_position, knob_radius, knob_height,
    leaf_fulcrum_position
) = [
    ["length", length],
    ["width", width],
    ["height", height],
    ["screwhole_positions", screwhole_positions],
    ["pin_positions", pin_positions],
    ["knob_position", knob_position],
    ["knob_radius", knob_radius],
    ["knob_height", knob_height],
    ["leaf_fulcrum_position", leaf_fulcrum_position]
];

function microswitch_get_length (m) = dict_get (m, "length");
function microswitch_get_width (m) = dict_get (m, "width");
function microswitch_get_height (m) = dict_get (m, "height");
function microswitch_get_screwhole_positions (m) = dict_get (m, "screwhole_positions");
function microswitch_get_pin_positions (m) = dict_get (m, "pin_positions");
function microswitch_get_knob_position (m) = dict_get (m, "knob_position");
function microswitch_get_knob_radius (m) = dict_get (m, "knob_radius");
function microswitch_get_knob_height (m) = dict_get (m, "knob_height");
function microswitch_get_leaf_fulcrum_position (m) = dict_get (m, "leaf_fulcrum_position");
