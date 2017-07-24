use <dict.scad>

function Hotend (
    sink_d, sink_h, whole_sink_h,
    groove_profile,
) =
[
    ["sink_d", sink_d],
    ["sink_h", sink_h],
    ["whole_sink_h", whole_sink_h],
    ["groove_profile", groove_profile],
];


function hotend_get_sink_d (h) = dict_get (h, "sink_d");
function hotend_get_sink_h (h) = dict_get (h, "sink_h");
function hotend_get_whole_sink_h (h) = dict_get (h, "whole_sink_h");
function hotend_get_groove_profile (h) = dict_get (h, "groove_profile");
function hotend_get_sink_profile (h) = (
    let (groove = hotend_get_groove_profile (h),
         sink_d = hotend_get_sink_d (h),
         sink_h = hotend_get_sink_h (h))
    concat (groove, [sink_d, sink_h])
);
