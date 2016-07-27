use <../lib/aluex.scad>

tslot2040 = AluminiumExtrusionProfile (
    size = [20, 40],
    slots = [[10], [10, 30]],
    slot_width = 5,
    slot_profile = "t"
);

vslot2040 = AluminiumExtrusionProfile (
    size = [20, 40],
    slots = [[10], [10, 30]],
    slot_width = 6,
    slot_profile = "v"
);

tslot2020 = AluminiumExtrusionProfile (
    size = [20, 20],
    slots = [[10], [10]],
    slot_width = 5,
    slot_profile = "t"
);
