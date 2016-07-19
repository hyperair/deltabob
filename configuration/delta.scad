use <../lib/aluex.scad>
use <../lib/corner.scad>
use <../lib/delta.scad>

include <carriage.scad>
include <extrusions.scad>

deltabob = (
    let (
        v_aluex = vslot2040,
        v_aluex_orientation = "circumferential",  // as opposed to radial
        h_aluex = tslot2040,

        corner_cavity_width = 30,
        arm_length = 80,
        wall_thickness = 5,

        corner_bottom = CornerBottom (
            v_aluex = v_aluex,
            v_aluex_orientation = v_aluex_orientation,

            h_aluex = h_aluex,
            h_aluex_num = 2,
            h_aluex_separation = 150 - 2 * aluex_size (v_aluex)[1],

            wall_thickness = wall_thickness,
            cavity_width = corner_cavity_width,
            arm_length = arm_length
        ),

        corner_top = CornerTop (
            v_aluex = v_aluex,
            v_aluex_orientation = v_aluex_orientation,

            h_aluex = h_aluex,
            h_aluex_num = 1,
            h_aluex_separation = 0,

            wall_thickness = wall_thickness,
            cavity_width = corner_cavity_width,
            arm_length = arm_length
        )
    )


    Delta (
        v_aluex = v_aluex,
        h_aluex = h_aluex,

        v_aluex_orientation = v_aluex_orientation,

        top_corner = corner_top,
        bottom_corner = corner_bottom,

        delta_radius = 240 / 2,
        rod_length = 138.5,
        hinge_spacing = 50
    )
);
