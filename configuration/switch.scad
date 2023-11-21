use <../lib/microswitch.scad>

microswitch0606 = Microswitch (
    length = 13,
    width = 6,
    height = 6.5,
    screwhole_positions = [3, 10],
    screwhole_zoffset = 5,
    pin_positions = [1.5, 6.5, 11.5],
    knob_position = 13 - 15.2,
    knob_radius = 1,
    knob_height = 1,
    leaf_fulcrum_position = 1
);
