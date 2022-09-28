use <MCAD/array/along_curve.scad>
use <MCAD/shapes/3Dshapes.scad>
use <lib/delta.scad>
use <lib/effector.scad>
use <lib/corner.scad>
include <configuration/delta.scad>

use <assembly/effector-assembly.scad>

frame_height = 800;
aluex_colour = "#333";

module bottom_corner (delta)
{
    color (delta_get_print_colour (delta))
    import ("corner-bottom.stl");
}

module top_corner (delta)
{
    color (delta_get_print_colour (delta))
    import ("corner-top.stl");
}

module place_corners (delta)
{
    corner_offset = delta_get_corner_offset (delta);

    mcad_rotate_multiply (3)
    translate ([0, -corner_offset])
    children ();
}

module top_triangle (delta)
{
    corner_top = delta_get_top_corner (delta);
    corner_blank = corner_top_get_blank (corner_top);
    corner_top_height = corner_get_height (corner_blank);

    translate ([0, 0, frame_height - corner_top_height]) {
        place_corners (delta)
        top_corner (delta);

        place_horizontal_struts (delta)
        top_struts (delta);
    }
}

module top_struts (delta)
{
    length = (triangle_radius (delta) * cos (30) - delta_get_base_short_edge (delta)) * 2;

    corner_top = delta_get_top_corner (delta);
    corner = corner_top_get_blank (corner_top);
    h_aluex_positions = corner_get_h_aluex_positions (corner);

    aluex_width = corner_get_h_aluex_width (corner);
    aluex_height = corner_get_h_aluex_height (corner);

    echo (str ("Horizontal strut length = ", length));

    color (aluex_colour)
    for (z = h_aluex_positions) {
        translate ([0, 0, z])
        ccube ([length, aluex_width, aluex_height], center = X + Z);
    }
}

function small_triangle_height (delta) = (
    let (short_edge = delta_get_base_short_edge (delta))

    sqrt (pow (short_edge, 2) - pow (short_edge / 2, 2))
);

function triangle_radius (delta) = (
    delta_get_corner_offset (delta) + small_triangle_height (delta)
);

module place_horizontal_struts (delta)
{
    /* main delta base triangle */
    triangle_radius = triangle_radius (delta);
    horizontal_strut_offset = sin (30) * triangle_radius;

    mcad_rotate_multiply (3)
    translate ([0, horizontal_strut_offset, 0])
    children ();
}

module bottom_struts (delta)
{
    triangle_radius = triangle_radius (delta);
    short_edge = delta_get_base_short_edge (delta);

    length = (triangle_radius * cos (30) - short_edge) * 2;

    corner_bottom = delta_get_bottom_corner (delta);
    corner = corner_bottom_get_blank (corner_bottom);
    h_aluex_positions = corner_get_h_aluex_positions (corner);

    aluex_width = corner_get_h_aluex_width (corner);
    aluex_height = corner_get_h_aluex_height (corner);

    echo (str ("Horizontal strut length = ", length));

    color (aluex_colour)
    for (z = h_aluex_positions) {
        translate ([0, 0, z])
        ccube ([length, aluex_width, aluex_height], center = X + Z);
    }
}

module place_vertical_struts (delta)
{
    place_corners (delta)
    children ();
}

module bottom_triangle (delta)
{
    place_corners (delta)
    bottom_corner (delta);

    place_horizontal_struts (delta)
    bottom_struts (delta);
}

module vertical_struts (delta)
{
    v_aluex = delta_get_v_aluex (delta);
    v_orientation = delta_get_v_aluex_orientation (delta);

    v_circ = delta_get_v_circumferential (delta);
    v_radial = delta_get_v_radial (delta);

    echo (str ("Vertical strut length = ", frame_height));

    place_vertical_struts (delta)
    mirror (Y)
    color (aluex_colour)
    ccube ([v_circ, v_radial, frame_height], center = X);
}

module place_plate (delta)
{
    corner = delta_get_bottom_corner (delta);
    corner_blank = corner_bottom_get_blank (corner);
    corner_height = corner_get_height (corner_blank);

    translate ([0, 0, corner_height + 5])
    children ();
}

module plate (delta)
{
    plate_thickness = delta_get_plate_thickness (delta);

    place_plate (delta)
    color ("lightgray", 0.25)
    cylinder (d = 240, h = plate_thickness);
}

module place_effector_assembly (delta)
{
    plate_thickness = delta_get_plate_thickness (delta);

    place_plate (delta)
    translate ([0, 0, plate_thickness])
    children ();
}

module deltabob (delta)
{
    bottom_triangle (delta);
    top_triangle (delta);
    vertical_struts (delta);

    plate (delta);

    place_effector_assembly (delta)
    effector_assembly (delta);

    /* carriages (); */
    /* rods (); */
}

deltabob (deltabob);

/* power supply */
translate ([40, 162, 0])
rotate (90, Z)
color ("#aaa")
ccube ([50, 215, 112], center=X+Y);
