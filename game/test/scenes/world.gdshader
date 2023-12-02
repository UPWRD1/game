shader_type spatial;
render_mode unshaded;



void fragment() {
	
	ALBEDO = vec3(POINT_COORD.xy, 1);
}
