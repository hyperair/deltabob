/**
 * AluminiumExtrusionProfile
 *
 * Constructor for this class.
 * @param size Size of profile (e.g. [20, 40] for 2040)
 * @param slots Coordinates of slot centers (e.g. [[10], [10, 30]] for 2040)
 * @param slot_width Width of the slot
 */

use <dict.scad>

function AluminiumExtrusionProfile (size = [20, 20],
                                    slots = [[10], [10]],
                                    slot_width = 5,
                                    slot_profile = "t") =
    [
        ["size", size],
        ["slots", slots],
        ["slot_width", slot_width],
        ["slot_profile", slot_profile]
    ];

function aluex_get_value (profile, key) = dict_get (profile, key);
function aluex_size (profile) = aluex_get_value (profile, "size");
function aluex_slots (profile) = aluex_get_value (profile, "slots");
function aluex_slot_width (profile) = aluex_get_value (profile, "slot_width");
function aluex_slot_profile (profile) = aluex_get_value (profile,
                                                         "slot_profile");

module aluex_echo (profile)
{
    echo (
        str (
            "AluminiumExtrusionProfile (",
            "size = ", aluex_size (profile),
            ", slots = ", aluex_slots (profile),
            ", slot_width = ", aluex_slot_width (profile),
            ")"
        )
    );
}

aluex_echo (AluminiumExtrusionProfile());
