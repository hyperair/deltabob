use <dict.scad>


function Probe (
    ball_thread_d,
    ring_h,
    ring_width
) = [
    ["ball_thread_d", ball_thread_d],
    ["ring_h", ring_h],
    ["ring_width", ring_width],
];

function probe_get_ball_thread_d (p) = dict_get (p, "ball_thread_d");
function probe_get_ring_h (p) = dict_get (p, "ring_h");
function probe_get_ring_width (p) = dict_get (p, "ring_width");
