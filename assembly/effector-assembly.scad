include <../configuration/delta.scad>
use <../lib/delta.scad>
use <../lib/hotend.scad>
use <MCAD/shapes/3Dshapes.scad>

$fs = 0.4;
$fa = 1;

module effector_assembly(delta)
{
    hotend = delta_get_hotend (deltabob);
    hotend_whole_sink_h = hotend_get_whole_sink_h (hotend);

    effector = delta_get_effector (deltabob);
    effector_prong_height = effector_get_prong_height (effector);

    print_colour = delta_get_print_colour (delta);

    translate ([0, 0, 14.1]) {
        color (print_colour)
        import ("../effector.stl");

        rotate ([0, 0, -30 + 180])
        translate ([0, 0, -hotend_whole_sink_h + effector_prong_height])
        union () {
            color (print_colour)
            import ("groovemount-assembly.stl");

            /* fan */
            %translate ([25, 0, 21])
             rotate ([0, -90, 0])
             mcad_rounded_cube ([40, 40, 10], radius=3, sidesonly=true, center=true);

            %translate ([0, 0, -19])
             import ("../vitamins/e3dv5.stl");
        }
    }
}

effector_assembly (delta);
