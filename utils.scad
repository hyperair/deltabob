include <MCAD/units/metric.scad>

module mirror_if (value, axis = X)
{
    if (value) {
        mirror (axis)
        children ();
    } else {
        children ();
    }
}
