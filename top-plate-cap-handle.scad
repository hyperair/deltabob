use <groovemount.scad>

translate ([0, 0, 10])
rotate (180, [0, 1, 0])
difference () {
    translate ([0, 0, 5])
    cube ([20, 80, 10], center = true);

    translate ([0, 0, -0.001]) {
        linear_extrude (height = 5)
        offset (r = 0.3)
        projection (cut = true)
        top_plate_cap ();

        cylinder (d = 5, h = 5);
    }
}
