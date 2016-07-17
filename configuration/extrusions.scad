use <../lib/aluex.scad>

extrusions_h_profile = [20, 40]; // 20mm wide, 40mm high
extrusions_v_profile = [40, 20]; // 40mm circumferential, 20mm radial

extrusions_h_number = 2;
extrusions_h_gap = 10;

extrusions_h = AluminiumExtrusionProfile (
    size = [20, 40],
    slots = [[10], [10, 30]],
    slot_width = 5,
    slot_profile = "t"
);

extrusions_v = AluminiumExtrusionProfile (
    size = [20, 40],
    slots = [[10], [10, 30]],
    slot_width = 6,
    slot_profile = "v"
);

extrusions_h_orientation = "vertical";
extrusions_v_orientation = "circumferential";

extrusion_v_circumferential = (
    let (size = aluex_size (extrusions_v))
    (extrusions_v_orientation == "circumferential") ? max (size) : min (size)
);
extrusions_v = (
    let (size = aluex_size (extrusions_v))
    (extrusions_v_orientation == "circumferential") ? max (size) : min (size)
);

extrusions_h = (
    let (size = aluex_size (extrusions_h))
    (extrusions_h_orientation == "hertical") ? max (size) : min (size)
);
