use <dict.scad>

function AxialFan (width, thickness, corner_radius, screw_distance) = [
    ["width", width],
    ["thickness", thickness],
    ["corner_radius", corner_radius],
    ["screw_distance", screw_distance]
];

function axial_fan_get_width (d) = dict_get (d, "width");
function axial_fan_get_thickness (d) = dict_get (d, "thickness");
function axial_fan_get_corner_radius (d) = dict_get (d, "corner_radius");
function axial_fan_get_screw_distance (d) = dict_get (d, "screw_distance");

module axial_fan (options)
{
    width = axial_fan_get_width (options);
    thickness = axial_fan_get_thickness (options);
    corner_radius = axial_fan_get_corner_radius (options);
    diameter = axial_fan_get_diameter (options);

    difference () {
        mcad_rounded_box (
            [width, width, thickness],
            rounding_r = corner_radius,
            sidesonly = true
        );

        cylinder (d = diameter, h = thickness * 2, center = true);
    }
}
