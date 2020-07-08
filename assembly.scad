use <MCAD/array/along_curve.scad>
use <MCAD/shapes/3Dshapes.scad>
use <lib/delta.scad>
use <lib/effector.scad>
use <lib/corner.scad>
include <configuration/delta.scad>

frame_height = 1000;

module bottom_corner ()
{
    color ("gray")
    import ("corner-bottom.stl");
}

module top_corner ()
{
    color ("gray")
    import ("corner-top.stl");
}

module place_corners (delta)
{
    delta_radius = delta_get_delta_radius (delta);
    effector_radius = effector_get_hinge_offset (delta_get_effector (delta));

    carriage = delta_get_carriage (delta);
    carriage_hinge_offset = (
        carriage_get_base_thickness (carriage) +
        carriage_get_hinge_elevation (carriage) +
        1
    );

    corner_offset = effector_radius + delta_radius + carriage_hinge_offset;

    mcad_rotate_multiply (3)
    translate ([0, -corner_offset])
    children ();
}

module top_triangle (delta)
{
    corner_top = delta_get_top_corner (delta);
    corner_blank = corner_top_get_blank (corner_top);
    corner_top_height = corner_get_height (corner_blank);

    translate ([0, 0, frame_height - corner_top_height])
    place_corners (delta)
    top_corner ();
}

module place_horizontal_struts (delta)
{
}

module place_vertical_struts (delta)
{
    place_corners (delta)
    children ();
}

module bottom_triangle (delta)
{
    place_corners (delta)
    bottom_corner ();

    place_horizontal_struts ()
    bottom_struts ();
}

module vertical_struts (delta)
{
    v_aluex = delta_get_v_aluex (delta);
    v_orientation = delta_get_v_aluex_orientation (delta);

    v_profile = (
        let (size = aluex_size (v_aluex))

        (v_orientation == "circumferential") ?
        [size[1], size[0]] : [size[0], size[1]]
    );

    place_vertical_struts (delta)
    mirror (Y)
    color ("black")
    ccube ([v_profile[0], v_profile[1], frame_height], center = X);
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
    place_plate (delta)
    color ("lightgray", 0.25)
    cylinder (d = 240, h = 5);
}

module deltabob (delta)
{
    bottom_triangle (delta);
    top_triangle (delta);
    vertical_struts (delta);

    plate (delta);
    /* effector (); */
    /* carriages (); */
    /* rods (); */
}

deltabob (deltabob);
