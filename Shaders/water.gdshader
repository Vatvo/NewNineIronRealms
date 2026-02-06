// this code working on godot 4.3
shader_type spatial;
render_mode cull_disabled; // specular_schlick_ggx

group_uniforms Color;
uniform vec4 color : source_color;

group_uniforms Substance;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float metallic : hint_range(0.0, 1.0) = 0;

//Water Speed

group_uniforms Depth_Fade;
uniform float beer_law_factor = 2.0;
uniform float _distance = 50.0;

//Water foam 
uniform vec4 edge_color: source_color;
uniform float edge_scale = 0.1;
uniform float far = 100.0;

//Water Wave 
group_uniforms Waves;
uniform sampler2D wave;
uniform float speed: hint_range(-1, 1) = 0.02;
uniform vec2 wave_direction = vec2(2.0,0.0); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(0.0,1.0); // Direction of wave 2
uniform float height_scale = 0.15;
uniform float noise_scale = 10.0;

group_uniforms Normals;

uniform sampler2D normalmap: hint_normal;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Varying variables
varying float height;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	height = texture(wave, world_pos.xz / noise_scale + TIME * speed).r;
	
	VERTEX.y += height * height_scale;
}

void fragment() {
	float time = TIME * speed;
	
	vec2 uv_movement = UV * 4.0;
	uv_movement += TIME * speed * 4.0;
	
	vec4 alpha = texture(SCREEN_TEXTURE, SCREEN_UV);
	ALBEDO = mix(alpha.rgb, color.rgb, color.a);
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	if (VERTEX.z < pixel_position.z + 0.05 + edge_scale) {
  		ALBEDO = vec3(edge_color.rgb);
	}
	
	NORMAL_MAP = texture(normalmap, uv_movement).rgb;
	
	METALLIC = metallic;

	ROUGHNESS = roughness;
}