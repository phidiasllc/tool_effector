/************************************************************************************

simple_delta_tool_effector.scad - tool effector for use on the simple delta
Copyright 2015 Jerry Anzalone
Author: Jerry Anzalone <info@phidiasllc.com.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

************************************************************************************/

// to use this library, either call the required modules below or run simple_delta_tool_effector_renderer.scad

include<athena.scad>

h_effector_magnet_mount = 10;

d_ball_bearing = 3 * 25.4 / 8;
tol_ball_bearing = 1; // add some tolerance to the bearing pockets to account for the hand-made aspect of the machine
id_magnet = 15 * 25.4 / 64;
od_magnet = 3 * 25.4 / 8;
h_magnet = 25.4 / 8;

// the end effector is primarily designed for a hot end tool, so many dimensions are based on getting that part to fit properly
l_effector = 60; // this needs to be played with to keep the fan from hitting the tie rods
h_effector = equilateral_height_from_base(l_effector);
r_pad_effector_magnet_mount = 2;
r_effector = l_effector * tan(30) / 2 + 11;
h_triangle_inner = h_effector + 12;

// for the small tool end effector:
d_small_effector_tool_mount = 30; // diameter of the opening in the end effector that the tool will pass through
d_small_effector_tool_magnet_mount = 1 + d_small_effector_tool_mount + od_magnet + 2 * r_pad_effector_magnet_mount; // ring diameter of the effector tool magnet mounts

// for the large tool end effector:
d_large_effector_tool_mount = 50;
d_large_effector_tool_magnet_mount = h_triangle_inner;
echo(d_small_effector_tool_magnet_mount);

/********************************************************

tool holders

********************************************************/

// the most basic tool mount - holds a cylindrical tool and is the foundation for most that follows
module circular_tool_holder(
	h_effector_tool_mount,
	bearing_cage = true,
	d1_circular_tool = 13.9,
	d2_circular_tool = 	0,
	clamping_screw = 0,
	nut_pocket = false,
	mirror_clamps = false,
	d_effector_tool_magnet_mount,
	rotate_clamping_screw = 0
) {

	d_screw = (nut_pocket) ? d_M3_screw : d_M3_screw - 0.5;
	d2_circular_tool = (d2_circular_tool == 0) ? d1_circular_tool : d2_circular_tool;

	difference() {
		tool_mount_body(
			h_effector_tool_mount = h_effector_tool_mount,
			d_effector_tool_magnet_mount = d_effector_tool_magnet_mount
		);

		cylinder(r1 = d1_circular_tool / 2, r2 = (d2_circular_tool > 0) ? d2_circular_tool / 2 : d1_circular_tool, h = h_effector_tool_mount + 10, center = true);

		// clamping screws
		if (clamping_screw > 0) {
			for (i = [0, (mirror_clamps) ? 1 : 0])
				mirror([0, 0, i]) {
					translate([0, 0, (h_effector_tool_mount - d_M3_nut) / 2])
						rotate([0, 0, rotate_clamping_screw]) {
							for (i = [0:clamping_screw - 1])
								rotate([0, 0, i * 360 / clamping_screw + 120]) { // add 120 to get a single screw off the index
									translate([0, d1_circular_tool / 2 - 1, 0])
										rotate([270, 0, 0])
											cylinder(r = d_screw / 2, h = r_effector - d1_circular_tool / 2 + 2); // M3 screw

									// nut pockets
									if (nut_pocket)
										translate([0, d1_circular_tool / 2 + 1.5 + h_M3_nut / 2, 0])
											rotate([90, 0, 0])
												hull()
													for (j = [0, 1])
														translate([0, j * h_effector_tool_mount, 0])
															rotate([0, 0, 30])
																cylinder(r = d_M3_nut / 2, h = h_M3_nut, center = true, $fn = 6); // nut pocket
								}
						}
				}
		}

		if (bearing_cage)
			translate([0, 0, -h_effector_tool_mount / 2 - 2])
				bearing_relief(
					d_effector_tool_magnet_mount = d_effector_tool_magnet_mount
				);
	}
}

// for holding a Jandel 4-point probe - untested
module Jandel_4pt_probe_holder(
	render_base = false,
	render_bottom_ring = false,
	render_top_ring = false
	) {

	h_mount = 7;
	// dimensions for the Jandel cylindrical probe:
	d_body = 25.4; // diameter of the main body of the probe
	h_body = 34.92;
	d_taper = 21.78; // diameter of the taper just below the main body
	h_taper = 2.36; // height of the above taper
	d_nose = 10; // diameter of the nose piece
	h_nose = 10.44; // overall height of the nose piece
	d_nose_taper = 6; // diameter of the taper on the nose
	h_nose_taper = 2.76; // height of the nose taper
	// dimensions for the probe rings:
	d_ring = d_body + 8;
	h_ring = 3;
	d_bolt_circle = d_body + 10;
	y_offset_limit_switch = ((d_large_effector_tool_magnet_mount + d_ball_bearing) / 2 + 5) * sin(30);

	// mount base
	if (render_base)
		difference() {
			circular_tool_holder(
				h_effector_tool_mount = h_mount,
				bearing_cage = true,
				d1_circular_tool = 27,
				clamping_screw = true,
				d_effector_tool_magnet_mount = d_large_effector_tool_magnet_mount);

			// holes for the probe guides and spring cage mount
			for (i = [0:2])
				rotate([0, 0, i * 120])
					translate([0, d_bolt_circle / 2, 0])
						cylinder(r = d_M3_screw / 2, h = h_mount+ 1, center = true);

			// pocket for limit switch
			rotate([0, 0, 120])
			translate([14, y_offset_limit_switch, 0]) {
				cube([20, 6.5, h_mount + 1], center = true);

				for (i = [-1, 1])
					translate([i * 5, 0, 0])
						rotate([90, 0, 0])
							cylinder(r = 0.8, h = 20, center = true);
			}
		}

	// bottom probe ring
	if (render_bottom_ring)
		difference() {
			union() {
				cylinder(r = d_ring / 2, h = h_ring, center = true);

				for (i = [0:2])
					rotate([0, 0, i * 120 + 60])
						translate([0, d_bolt_circle / 2, 0])
							cylinder(r = 4, h = h_ring, center = true);
			}

			cylinder(r = d_taper / 2, h = h_ring + 1, center = true);

			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d_bolt_circle / 2, 0])
						cylinder(r = d_M3_screw / 2, h = h_ring + 1, center = true);
		}

	// top probe ring
	if (render_top_ring)
		difference() {
			union() {
				cylinder(r = d_ring / 2, h = h_ring, center = true);

				for (i = [0:2])
					rotate([0, 0, i * 120 + 60])
						translate([0, d_bolt_circle / 2, 0])
							cylinder(r = 4, h = h_ring, center = true);

				// boss for switch adjustment screw
				rotate([0, 0, 60])
					translate([0, y_offset_limit_switch, 1.5])
						hull() {
							cylinder(r = 4, h = 6, center = true);

							translate([0, (- d_bolt_circle) / 2, -3])
								cylinder(r = 8, h = 0.1, center = true);
						}
			}

			cylinder(r = d_taper / 2, h = h_ring + 1, center = true);

			// pocket the body diameter
			cylinder(r = d_body / 2, h = 2 * h_ring);

			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d_bolt_circle / 2, 0])
						cylinder(r = d_M3_screw / 2, h = h_ring + 1, center = true);

			rotate([0, 0, 60])
				translate([0, y_offset_limit_switch, 1.5])
					cylinder(r = d_M3_screw / 2 - 0.25, h = 7, center = true);

		}
}

// a cylindrical tool holder with swing out clamp
module clamp_mount() {
	render_mount = true;
	render_clamp = true;
	d_clamp = 13;
	h_mount = 6;
	d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount;
	cc_pivots = 30;

	if (render_mount)
		difference() {
			effector_tool_mount(
				h_effector_tool_mount = h_mount,
				bearing_cage = true,
				d_effector_tool_magnet_mount = d_effector_tool_magnet_mount);

			translate([cc_pivots, 0, 0])
				intersection() {
					rotate_extrude(convexity = 10, center = true)
						translate([cc_pivots, 0, 0])
							square([d_clamp, h_mount + 1], center = true);

						translate([0, d_effector_tool_magnet_mount / 2, 0])
							cube([2 * d_effector_tool_magnet_mount, d_effector_tool_magnet_mount, h_mount + 1], center = true);
				}

			rotate([0, 0, -60])
				for (i = [-1, 1])
					translate([i * cc_pivots / 2, 0, 0]) {
						cylinder(r = d_M3_screw / 2, h = h_mount + 1, center = true);

						translate([0, 0, h_mount / 2])
							cylinder(r = d_M3_nut / 2, h = 2* h_M3_nut + 0.5, center = true, $fn = 6);
					}

			cylinder(r = d_clamp / 2, h = h_mount + 1, center = true);
		}

	if (render_clamp)
		translate([35, -d_effector_tool_magnet_mount * cos(60) / 2, 0])
			rotate ([0, 0, 180])
				difference() {
					tool_mount_body(
						h_effector_tool_mount = h_mount,
						d_effector_tool_magnet_mount = d_effector_tool_magnet_mount);

				for (i = [-1, 1])
					translate([i * cc_pivots / 2, 0, 0])
						cylinder(r = d_M3_screw / 2 + 0.1, h = h_mount + 1, center = true);

				translate([-cc_pivots / 2, 0, 0])
					intersection() {
						union() {
							rotate_extrude(convexity = 10, center = true)
								translate([cc_pivots / 2, 0, 0])
									square([d_clamp + 0.2, h_mount + 1], center = true);

							rotate_extrude(convexity = 10, center = true)
								translate([cc_pivots, 0, 0])
									square([d_M3_screw + 0.2, h_mount + 1], center = true);
						}

						translate([0, d_effector_tool_magnet_mount / 2, 0])
							cube([2 * d_effector_tool_magnet_mount, d_effector_tool_magnet_mount, h_mount + 1], center = true);
					}

				cylinder(r = d_clamp / 2 + 0.1, h = h_mount + 1, center = true);
				}
}

// couldn't be more obviously named
module cupcake_holder() {
	// cupcake holder
	d1_cupcake = 57;
	d2_cupcake = 70;
	h_cupcake = 33;
	h_effector_tool_mount = 8;

	difference() {
		union() {
			cylinder(d1 = d1_cupcake + 4, d2 = d2_cupcake + 4, h = h_cupcake + 2, center = true);

			translate([0, 0, -(h_cupcake + 2) / 2 - h_effector_tool_mount / 2])
				tool_mount_body(
				h_effector_tool_mount = h_effector_tool_mount,
				d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
			);

			translate([0, 0, h_cupcake / 2])
				difference() {
					cylinder(d = d2_cupcake + 35, h = 2, center = true);

					cylinder(d = d2_cupcake, h = 3, center = true);
				}
		}

		translate([0, 0, 2])
			difference() {
				cylinder(d1 = d1_cupcake, d2 = d2_cupcake, h = h_cupcake, center = true);

				intersection() {
					cylinder(d1 = d1_cupcake, d2 = d2_cupcake, h = h_cupcake, center = true);

					for (i = [0:5])
						rotate([0, 0, i * 60])
							translate([0, d1_cupcake - 2 - 1, -6])
								rotate([0, 90, 0])
									cylinder(d = d1_cupcake, h = 1, center = true);
				}
			}

		translate([0, 0, -(h_cupcake + 2) / 2 - h_effector_tool_mount / 2])
			bearing_relief(
				d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
			);
	}
}

module hotend_tool(
	dalekify = false,
	quickrelease = true,
	vented = false,
	headless = false
) {
	h_effector_tool_mount = 6.8;
	difference() {
		union() {
			translate([0, 0, (t_effector - h_effector_tool_mount) / 2])
				hotend_mount(dalekify = dalekify, quickrelease = quickrelease, vented = vented, headless = headless);

			// can't use the circular tool holder becuase the hot end cage occludes bearing pockets
			tool_mount_body(
				h_effector_tool_mount = h_effector_tool_mount,
				d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
			);
		}

		// bearing relief - keep the tool as close to the effector as possible
		translate([0, 0, -h_effector_tool_mount + 1.5])
			bearing_relief(
				d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
			);

		// opening for hot end
		translate([0, 0, -0.4])
			cylinder(r1 = r1_opening, r2 = r2_opening, h = h_effector_tool_mount + 1, center = true);
	}
}

// microscope holder - change the dimensions to match the 'scope to be held
module microscope_holder() {
	d_gooseneck = 3.65; // diameter of the gooseneck
	d_wire = 2; // diameter of the gooseneck wire relief
	d1_microscope = 35; // Aven Mightyscope 5MP= 33.55
	d2_microscope = 34.2; // Aven Mightyscope 5MP= 33 @ 40mm from top of clear ring
//	d1_microscope = 30.55; // Dinolite = 29.55 at base
//	d2_microscope = 33; // Dinolite = 32 @ 40mm from top of clear ring
//	d1_microscope = 31.2; // cheapo = 31.2 at base
//	d2_microscope = 33.2; // cheapo = 32 @ 40mm from top of clear ring
	offset_gooseneck = sin(30) * d_large_effector_tool_magnet_mount / 2 + d_ball_bearing / 2 + 1.5;
	h_effector_tool_mount = 40; // measure diameters at this distance

	difference() {
		circular_tool_holder(
			h_effector_tool_mount = h_effector_tool_mount,
			bearing_cage = true,
			d1_circular_tool = d1_microscope,
			d2_circular_tool = d2_microscope,
			clamping_screw = 3,
			nut_pocket = true,
			mirror_clamps = true,
			d_effector_tool_magnet_mount = d_large_effector_tool_magnet_mount,
			rotate_clamping_screw = 30);

			// clamp relief for LEDs
			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d2_microscope / 2 + 8, h_effector_tool_mount / 2]) {
							rotate([-140, 0, 0])
								union() {
										translate([0, 0, 6])
											cylinder(r = d_gooseneck / 2, h = 30);

										translate([0, 0, -1])
											cylinder(r1 = 1, r2 = d_gooseneck / 2, h = 8);
								}
					}
			// reduce plastic use
			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, -15, 0])
						cube([30, 30, h_effector_tool_mount - 15], center = true);
		}

		translate([0, 0, (h_effector_tool_mount - 15) / 2])
			cylinder(r = d2_microscope / 2 + 1, h = layer_height);
}

// for mounting a 96 well microtitre plate to the end effector
module 96well_plate_holder() {
	w_well_plate_base = 85.3; // y-dim
	l_well_plate_base = 127.5; // x-dim
	h_well_plate_base = 2.5; // z-dim
	h_well_plate_holder = 4 + h_well_plate_base;
	h_well_plate_base_relief = h_well_plate_holder - 1; // the bottom of the holder will be 2mm thick
	r_corners = h_well_plate_base_relief + 2;
	w_supt = 0.8;
	h_effector_tool_mount = 6.8;

	union() {
		difference () {
			union() {
				hull()
					for (i = [-1, 1])
						for (j = [-1, 1])
							translate([i * l_well_plate_base / 2, j * w_well_plate_base / 2, 0])
								cylinder(r = r_corners, h = h_well_plate_holder, center = true);

				translate([0, 0, (h_well_plate_holder + h_effector_tool_mount) / 2])
					mirror([0, 0, 1])
							tool_mount_body(
							h_effector_tool_mount = h_effector_tool_mount,
							d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
						);
			}

			translate([0, 0, (h_well_plate_holder + h_effector_tool_mount) / 2])
				mirror([0, 0, 1])
					bearing_relief(
						d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
					);

			// difference an angled relief for holding the well plate
			hull()
				for (i = [-1, 1])
					for (j = [-1, 1])
						translate([i * (l_well_plate_base / 2 - (h_well_plate_base_relief - h_well_plate_base)), j * (w_well_plate_base / 2 - (h_well_plate_base_relief - h_well_plate_base)), -1])
							cylinder(r1 = 0, r2 = h_well_plate_base_relief, h = h_well_plate_base_relief, center = true);

			translate([8, 0, -2])
				cube([l_well_plate_base + 2, w_well_plate_base + 2, h_well_plate_base_relief + 2], center = true);

		}

		// tab for holding the well plate in place
		translate([1.5 + l_well_plate_base / 2, 0, 0])
			cube([3, 10, h_well_plate_holder], center = true);
/*
		// some support
		cube([w_supt, w_well_plate_base, h_well_plate_holder], center = true);

		translate([r_corners + l_well_plate_base / 2 - 0.35, 0, 0])
			cube([w_supt, w_well_plate_base, h_well_plate_holder], center = true);

		cube([l_well_plate_base, w_supt, h_well_plate_holder], center = true);
*/
	}

//	color([1, 0, 0])
//		cube([l_well_plate_base, w_well_plate_base, h_well_plate_base], center = true);
}

module well_plate_holder_cutout(h_well_plate_holder) {
	width = 30;
	hull() {
		cylinder(r = 4, h = h_well_plate_holder + 1, center = true);

		translate([-width, 0, 0])
			cylinder(r = 4, h = h_well_plate_holder + 1, center = true);

		translate([-width, -width, 0])
			cylinder(r = 4, h = h_well_plate_holder + 1, center = true);
	}
}

// for holding a cylindrical holder in a sprung mount - good for pens and tangent knives
module sprung_tool_holder(
	bearing_cage = true,
	render_tool_mount = true,
	render_holder = true,
	d_max_tool,
	d_springs,
	h_springs) {
	h_effector_tool_mount = 6.2;
	d_guides = 2.95; // use M3 screws, but drill the holes to improve tolerance
	t_tool_cage = 3; // thickness of walls and guide mount points
	d_keyholes = d_springs + 2;
	d_guide_ring = d_small_effector_tool_mount - d_keyholes + 0.5;
	d_tool_cage = d_max_tool + t_tool_cage;
	h_keys = h_effector_tool_mount + 2 * t_tool_cage + h_springs;
	h_tool_cage = h_keys + 5;

	// tool mount
	if (render_tool_mount)
		translate([0, 0, h_effector_tool_mount / 2])
			difference() {
				circular_tool_holder(
					h_effector_tool_mount = 6.2,
					bearing_cage = bearing_cage,
					d1_circular_tool = d_tool_cage + 2,
					clamping_screw = false,
					d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount);

					// 3mm holes for guides
					for (i = [0:2])
						rotate([0, 0, i * 120])
							translate([0, d_guide_ring / 2, 0])
								cylinder(r = d_guides / 2, h = h_effector_tool_mount + 1, center = true);

					// key holes for tool cage
					for (i = [0:2])
						rotate([0, 0, i * 120 + 60])
							hull()
								for (i = [0, 1])
									translate([0, i * d_guide_ring / 2, 0])
										cylinder(r = d_keyholes / 2, h = h_effector_tool_mount + 1, center = true);
			}

	// tool cage
	if (render_holder)
		rotate([0, 0, -30])
			translate([d_small_effector_tool_magnet_mount / 2 + 7, 0, 0])
			difference() {
				union() {
					// cage body
					cylinder(r = d_tool_cage / 2, h = h_tool_cage);

					// keys
					for (i = [0:2])
						rotate([0, 0, i * 120 + 30]) {
							hull()
								for (j = [0, 1])
									translate([0, j * d_guide_ring / 2, 0])
										cylinder(r = d_keyholes / 2 - 0.5, h = t_tool_cage);

							hull()
								for (j = [0, 1])
									translate([0, j * d_guide_ring / 2, h_keys - t_tool_cage])
										cylinder(r = d_keyholes / 2 - 0.5, h = t_tool_cage);

							translate([0, d_guide_ring / 2, 0])
								difference() {
									cylinder(r = d_keyholes / 2 - 0.5, h = h_keys);

									translate([0, 0, -1])
										cylinder(r = d_keyholes / 2 - 0.5 - 0.75, h = h_keys + 2);

									translate([-d_keyholes / 2, -d_keyholes, -1])
										cube([d_keyholes, d_keyholes, h_keys + 2]);
								}
						}

					// mount for tool retainer
					for (i = [0:2])
						rotate([0, 0, i * 120 + 90])
							translate([0, 0, h_keys])
								translate([0, d_tool_cage / 2 + 1, 0])
									rotate([90, 0, 0])
										cylinder(r1 = d_M3_screw / 2 + 0.5, r2 = d_M3_nut / 2 + 2, h = 4, center = true);
				}

			// opening for tool
			translate([0, 0, -1])
				cylinder(r = d_max_tool / 2, h = h_tool_cage + 2);

			// 3mm holes for guides
			for (i = [0:2])
				rotate([0, 0, i * 120 + 30])
					translate([0, d_guide_ring / 2, 0]) {
						translate([0, 0, -1])
							cylinder(r = d_guides / 2, h = h_keys - t_tool_cage + 1);

						translate([0, 0, h_keys - t_tool_cage + 0.25])
							cylinder(r = d_guides / 2, h = h_keys);
					}

			// tool retainers
			for (i = [0:2])
				rotate([0, 0, i * 120 + 90])
					translate([0, d_tool_cage / 2, 0]) {
						translate([0, 0, h_keys])
							rotate([90, 0, 0]) {
								cylinder(r = d_M3_screw / 2, h = d_tool_cage / 2 + 1, center = true);

								translate([0, 0, (d_tool_cage - d_max_tool - h_M3_nut + 1) / 2]) {
									translate([0, 0, 0.5])
									cylinder(r1 = d_M3_nut / 2, r2 = d_M3_nut / 2 + 0.5, h = h_M3_nut , center = true, $fn = 6);

									cylinder(r = d_M3_nut / 2, h = h_M3_nut + 0.5 , center = true, $fn = 6);
								}

							}

						// plastiform threads in these - may add a little extra support to the tool
						translate([0, 0, d_M3_screw / 2 + 2])
							rotate([90, 0, 0])
								cylinder(r = d_M3_screw / 2 - 0.5, h = d_tool_cage / 2 + 1, center = true);
					}

			// chop off the top
			translate([0, 0, h_tool_cage])
				cylinder(r = d_tool_cage / 2, h = 5);
		}
}

/********************************************************

end effectors and supporting modules

********************************************************/

module tool_effector(
	large = false
) {
	d_effector_tool_magnet_mount = (large) ? d_large_effector_tool_magnet_mount : d_small_effector_tool_magnet_mount;
	d_tool_mount = (large) ? d_large_effector_tool_mount : d_small_effector_tool_mount;
	rotation = (large) ? 0 : 60;

	difference() {
		effector_base(large = large);

		cylinder(r = d_tool_mount / 2, h = h_effector + 1, center = true);

		for (i = [0:2])
			rotate([0, 0, i * 120 + rotation]) {
				translate([0, d_effector_tool_magnet_mount / 2, layer_height - (t_effector / 2 + layer_height - h_magnet / 1.5)])
						cylinder(r = d_M3_screw / 2, h = t_effector + 10);

				for (j = [-1, 1])
					translate([0, d_effector_tool_magnet_mount / 2, j * (t_effector / 2 + layer_height - h_magnet / 3)])
						cylinder(r1 = od_magnet / 2 + 0.25, r2 = od_magnet / 2, h = h_magnet / 1.5, center = true);
			}
	}
}

// effector for stage-mode operation
// this has largely been replaced by the tool effector
module stage_effector(
	magnet_mounts = false) {

	difference() {
		effector_base(magnet_mounts = magnet_mounts);

		stage_effector_relief();
	}
}

// cutout in the interior of the stage effector, 1) lighten part, 2) provide a lock for attachments
module stage_effector_relief() {
	hull()
		for (i = [0:2])
			rotate([0, 0, i * 120])
				translate([0, -r_effector + 12, 0])
					cylinder(r = 3, h = t_effector + 1, center = true);

	for (i = [0:2])
		rotate([0, 0, i * 120])
			translate([0, -r_effector, 0])
				rotate([0, 0, 30]) {
					translate([0, 0, -t_effector / 2 - 0.25])
						cylinder(r = d_M3_nut / 2, h = t_effector / 2, $fn = 6);

					cylinder(r = d_M3_screw / 2, h = t_effector);

				}
}


/********************************************************

tool holder modules

********************************************************/

// the pockets that bearings fit into show bearings is for testing, set to true to see position of bearings
module bearing_relief(
	d_effector_tool_magnet_mount,
	show_bearings = false
) {
		for (i = [0:2])
		rotate([0, 0, i * 120 + 60])
			translate([0, d_effector_tool_magnet_mount / 2, 0]) {
				hull()
					for (j = [-d_ball_bearing / 2, d_ball_bearing / 2])
						translate([0, 0, j])
							rotate_extrude(convexity = 10)
								translate([tol_ball_bearing, 0, 0])
									difference() {
										circle(r = d_ball_bearing / 2);

										translate([-(d_ball_bearing + 1) / 2, 0, 0])
											square([d_ball_bearing + 1, d_ball_bearing + 1], center = true);
									}

				if (show_bearings)
					translate([0, 0, d_ball_bearing / 2])
						#sphere(r = d_ball_bearing / 2);
			}
}

// the basic shape of the tool mount forms the foundation for most parts
module tool_mount_body(
	h_effector_tool_mount,
	d_effector_tool_magnet_mount
) {
	union() {
			hull()
				for (i = [0:2])
					rotate([0, 0, i * 120 + 60])
						translate([0, d_effector_tool_magnet_mount / 2, 0])
							cylinder(r = d_ball_bearing / 2 + tol_ball_bearing + 1.5, h = h_effector_tool_mount, center = true);

			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d_effector_tool_magnet_mount / 2, -1])
						difference() {
							sphere(r = d_ball_bearing / 2 + tol_ball_bearing + 1.5);

							translate([0, 0, -d_ball_bearing / 2])
								cylinder(r = d_ball_bearing + 2 * tol_ball_bearing, h = d_ball_bearing, center = true);
						}

		// put an index on the edge normal the y-axis
		translate([5 * tan(30), d_effector_tool_magnet_mount * sin(30) / 2 + 5 * 2 * tan(30), (h_effector_tool_mount > 8) ? -h_effector_tool_mount / 2 + 4 : 0])
			rotate([0, 0, 60])
				linear_extrude(height = (h_effector_tool_mount > 8) ? 8 : h_effector_tool_mount, center = true)
					equilateral(5);

	}
}
