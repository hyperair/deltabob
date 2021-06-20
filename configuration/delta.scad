include <MCAD/motors/stepper.scad>

use <../lib/aluex.scad>
use <../lib/carriage.scad>
use <../lib/corner.scad>
use <../lib/delta.scad>
use <../lib/effector.scad>
use <../lib/hotend.scad>
use <../lib/groovemount.scad>
use <../lib/probe.scad>

include <carriage.scad>
include <extrusions.scad>
include <fans.scad>
include <switch.scad>

deltabob = (
    let (
        v_aluex = vslot2040,
        v_aluex_clearance = 0.2,
        v_aluex_orientation = "circumferential",  // as opposed to radial
        h_aluex = tslot2040,

        h_aluex_screwholes = [15, 60],

        corner_cavity_width = 30,
        arm_length = 80,
        wall_thickness = 5,

        bottom_height = 100,
        corner_bottom = CornerBottom (
            v_aluex = v_aluex,
            v_aluex_clearance = v_aluex_clearance,
            v_aluex_orientation = v_aluex_orientation,

            v_aluex_screwholes = [
                10, 30,
                bottom_height - 30, bottom_height - 10
            ],
            h_aluex_screwholes = h_aluex_screwholes,

            h_aluex = h_aluex,
            h_aluex_num = 2,
            h_aluex_separation = bottom_height - 2 * aluex_size (v_aluex)[1],

            wall_thickness = wall_thickness,
            cavity_width = corner_cavity_width,
            arm_length = arm_length,
            motor = Nema17
        ),

        corner_top = CornerTop (
            v_aluex = v_aluex,
            v_aluex_clearance = v_aluex_clearance,
            v_aluex_orientation = v_aluex_orientation,

            v_aluex_screwholes = [10, 30],
            h_aluex_screwholes = h_aluex_screwholes,

            h_aluex = h_aluex,
            h_aluex_num = 1,
            h_aluex_separation = 0,

            wall_thickness = wall_thickness,
            cavity_width = corner_cavity_width,
            arm_length = arm_length,
            idler_size = 3
        ),

        belt_width = 6,
        belt_thickness = 1.38,

        hinge_spacing = 50,
        hinge_d = 10,

        carriage = Carriage (
            base_thickness = 7,
            carriage_length = 80,
            wheel_spacing = 40 + 18,
            eccentric_od = 8,
            wall_thickness = 5,

            hinge_d = hinge_d,
            hinge_elevation = 8,
            hinge_spacing = hinge_spacing,

            belt_clamp_tooth_count = 8,
            belt_clamp_height = belt_width + 10,
            belt_clamp_width = belt_thickness + 4 * 2,

            belt_tensioner_block_width = belt_thickness + 7 * 2,
            belt_tensioner_block_height = belt_width + 7,
            belt_tensioner_block_length = 10,

            belt_offset = 5.093,
            belt_width = belt_width,
            belt_thickness = belt_thickness,
            belt_doubled_thickness = 2
        ),

        effector = Effector (
            hinge_d = hinge_d,
            hinge_spacing = hinge_spacing,
            hinge_elevation = 8,
            hinge_offset = 40,

            cavity_d = 65,
            wall_thickness = 2,
            thickness = 5,

            prong_width = 15,
            prong_height = 55,

            magnet_d = 8.3,
            magnet_h = 4
        ),

        probe = Probe (
            ball_thread_d = 4,
            ring_h = 10,
            ring_width = 10,
            switch = microswitch0606
        ),

        e3dv5 = Hotend (
            sink_d = 25,
            sink_h = 31.8,
            whole_sink_h = 50.1,
            groove_profile = [
                [16.9, 5],
                [12.9, 5.4],
                [16.9, 9]
            ]
        ),

        groovemount = Groovemount (
            hotend = e3dv5,
            fan = fan4010,
            fan_inset_depth = 1,
            fan_offset = 7,
            wall_thickness = 1,
            bowden_coupler_thread_d = 16,
            bowden_nut_size = 4,
            bowden_tube_d = 4,
            hotend_cap_arm_width = 15,
            hotend_cap_thickness = 10
        )
    )

    Delta (
        v_aluex = v_aluex,
        h_aluex = h_aluex,

        v_aluex_orientation = v_aluex_orientation,

        top_corner = corner_top,
        bottom_corner = corner_bottom,
        carriage = carriage,
        effector = effector,
        probe = probe,
        hotend = e3dv5,
        groovemount = groovemount,

        delta_radius = 240 / 2,
        rod_length = 138.5,
        hinge_spacing = 50
    )
);
