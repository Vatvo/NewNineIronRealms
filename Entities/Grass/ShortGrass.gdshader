shader_type spatial;

render_mode cull_disabled;
uniform sampler2D mask : filter_linear, hint_default_black;
uniform sampler2D color;
uniform sampler2D color_variation_mask;

uniform vec4 variation_color : source_color;
uniform float color_variation_strength;
uniform vec2 color_varitation_speed;
uniform vec2 variation_mask_size;

uniform sampler2D wind : filter_linear;
uniform float wind_speed = 1.;
uniform float wind_stength = 0.1;
uniform float wind_rot_strength = 0.5;

varying vec3 worldPos;

mat3 rotateY(float theta)
{
	
	float cosa = cos(theta);
	float sina = sin(theta);

 
    //Y rotation	
	mat3 rotate_y  = mat3(
	   vec3(cosa, 0.0, sina),
	   vec3(0.0, 1.0, 0.0),
	   vec3(-sina, 0.0, cosa)
	);
	
	return rotate_y;
}


void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 wind_tex = texture(wind, worldPos.xz + VERTEX.xz + TIME * wind_speed).rgb;
	
	NORMAL = vec3(0., 1., 0);
	mat3 rotation_matrix = rotateY(wind_tex.r * wind_rot_strength);
	
	VERTEX.xz += texture(wind, worldPos.xz + VERTEX.xz + TIME * wind_speed).rb * wind_stength;// * (1. - UV.y);
	vec3 rotated_vertex =  rotation_matrix * VERTEX;
	VERTEX =  rotated_vertex;
}

void fragment() {
	vec3 blade_color = texture(color, UV).rgb;
	float variation_mask = texture(color_variation_mask, worldPos.xz * variation_mask_size + TIME * color_varitation_speed).r;
	vec3 variated_color = mix(blade_color, variation_color.rgb, vec3(variation_mask) * color_variation_strength);
	
	ALBEDO = variated_color;
	ALPHA = texture(mask, UV).r;
}
