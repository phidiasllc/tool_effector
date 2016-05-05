/************************************************************************************

simple_delta_tool_effector_renderer.scad - render tool effectors and parts
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

include<simple_delta_tool_effector.scad>
layer_height = 0.33;

render_part(part_to_render = 1);

module render_part(part_to_render) {
	// stage effector is for mounting a stage or platen to
	if (part_to_render == 0) stage_effector();

	// small_tool_effector
	if (part_to_render == 1) tool_effector(large=true);

	// circular tool holder is for tools with a circular cross section
	// tools with diameter larger than 25mm will need to be fit on the large tool effector
	if (part_to_render == 2) 	circular_tool_holder(
			h_effector_tool_mount = 7,
			bearing_cage = true,
			d1_circular_tool = 14,
			clamping_screw = 1,
			nut_pocket = true,
			d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount
		);

	if (part_to_render == 3)
	sprung_tool_holder(
		bearing_cage = true,
		render_tool_mount = true,
		render_holder = false,
		d_max_tool = 14.5,
		d_springs = 5,
		h_springs = 7);
		
	if (part_to_render == 5) 96well_plate_holder();

	if (part_to_render == 6) microscope_holder();

	if (part_to_render == 7)
		Jandel_4pt_probe_holder(
			render_base = true,
			render_bottom_ring = true,
			render_top_ring = true
			);

	if (part_to_render == 8)
		hotend_tool(
			quickrelease = true,
			dalekify = false,
			vented = false,
			headless = true
		);

	if (part_to_render == 99) sandbox();
}

// a place to play
module sandbox() {
bearing_relief(d_effector_tool_magnet_mount = d_small_effector_tool_magnet_mount);
}
