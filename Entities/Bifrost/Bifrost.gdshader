shader_type spatial;

uniform sampler2D base_texture: source_color;

group_uniforms Normals;
uniform sampler2D normal_map: source_color;
uniform float normal_depth;

group_uniforms Warping;
uniform sampler2D uv_warp_1;
uniform vec2 uv_warp_1_speed;

uniform sampler2D uv_warp_2;
uniform vec2 uv_warp_2_speed;

uniform float warp_strength: hint_range(0.0, 1.0, 0.01);
uniform float screen_warp_strength : hint_range(0.0, 1.0, 0.01);

group_uniforms Material;
uniform float metallic: hint_range(0.0, 1.0, 0.01);
uniform float roughness: hint_range(0.0, 1.0, 0.01);
uniform float specular: hint_range(0.0, 1.0, 0.01);
uniform float fresnel_opacity : hint_range(0.0, 1.0, 0.01);

group_uniforms Refraction;
uniform float refraction_strength : hint_range(0.0, 8.0, 0.001) = 0.5;
uniform bool is_depth_based = false;

group_uniforms Glitter;
uniform sampler2D glitter_texture: source_color;
uniform sampler2D glitter_mask: source_color;
uniform vec3 glitter_color: source_color;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

group_uniforms Vertex;
uniform vec2 vertex_distortion_speed;
uniform vec2 vertex_distortion_amount;

vec2 refract_uv(vec2 uv, float strength, vec3 normal){
	float strength1 = strength * (is_depth_based ? pow(uv.y, 4.0) * 5.0 : 1.0);
	uv += strength1 * length(normal) - strength1 * 1.2;
	return uv;
}

vec2 calculate_uv_warp(vec3 warp1, vec3 warp2, vec2 uv, float strength) {
	vec2 full_warp = ((warp1.xy + warp2.xy) - vec2(1.));
	full_warp = full_warp * sin(PI * uv.x)/2.;
	return uv + full_warp * strength;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	vec3 worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 displacement = vec3(0.);
	displacement.x = vertex_distortion_amount.x * sin(TIME * vertex_distortion_speed.x * (worldPos.x + worldPos.z));
	displacement.z = vertex_distortion_amount.y * sin(TIME * vertex_distortion_speed.y * (worldPos.x + worldPos.z));
	VERTEX = VERTEX + displacement;
}

void fragment() {
	
	vec3 warp_tex_1 = texture(uv_warp_1, UV + (uv_warp_1_speed * TIME)).rgb;
	vec3 warp_tex_2 = texture(uv_warp_2, UV + (uv_warp_2_speed * TIME)).rgb;
	vec2 uv2 = calculate_uv_warp(warp_tex_1, warp_tex_2, UV, warp_strength);
	vec2 screen_uv2 = calculate_uv_warp(warp_tex_1, warp_tex_2, SCREEN_UV, screen_warp_strength);
	NORMAL = normalize(NORMAL + texture(normal_map, uv2).rgb * normal_depth);
	
	float alpha = fresnel(fresnel_opacity, NORMAL, VIEW);
	
	vec3 albedo = texture(base_texture, uv2).rgb;
	ALBEDO = mix(albedo, texture(screen_texture, refract_uv(screen_uv2, refraction_strength, NORMAL)).rgb, 1.0 - alpha);
	EMISSION = glitter_color * texture(glitter_texture, uv2).rgb * texture(glitter_texture, uv2).r;
	
	//ALBEDO = vec3(uv2.x, uv2.y, 0.);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
