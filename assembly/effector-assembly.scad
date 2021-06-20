use <MCAD/shapes/3Dshapes.scad>

$fs = 0.4;
$fa = 1;

module effector_assembly()
{
    import ("../effector.stl");

    rotate ([0, 0, -30 + 180])
    translate ([0, 0, 5])
    union () {
        import ("groovemount-assembly.stl");

        /* fan */
        %translate ([25, 0, 21])
         rotate ([0, -90, 0])
         mcad_rounded_cube ([40, 40, 10], radius=3, sidesonly=true, center=true);

        %translate ([0, 0, -19])
         import ("../vitamins/e3dv5.stl");
    }
}

effector_assembly();
