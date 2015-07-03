use <MCAD/shapes/2Dshapes.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

equivalent_d = 21.8;
bore_d = 5.2;
min_wall_thickness = 2;
bushing_length = 10;
slot_width = 5;

$fs = 0.4;
$fa = 1;

module aluex_bushing (equivalent_d, bore_d, slot_width, length)
{
    bushing_width = slot_width + 2;

    module bushing_shape ()
    {
        intersection () {
            rotate (90, X)
            linear_extrude (height = length, center = true)
            translate ([-bushing_width / 2, -bore_d / 2 - min_wall_thickness])
            square ([bushing_width,
                    equivalent_d + bore_d / 2 + min_wall_thickness]);

            sphere (d = equivalent_d);
        }
    }

    difference () {
        bushing_shape ();

        rotate (90, Y)
        mcad_polyhole (d = bore_d, h = bushing_width * 2, center = true);
    }
}

rotate (90, Y)
aluex_bushing (equivalent_d = equivalent_d, bore_d = bore_d,
    slot_width = slot_width,
    length = bushing_length);
