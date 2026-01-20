shader_type spatial;

uniform sampler2D noiseTexture;
uniform vec2 speed;
uniform vec2 scale = vec2(1,1);
uniform vec3 color: source_color;
uniform float offset = 0;

void fragment() {
	ALBEDO = color;
	vec2 uv2 = vec2((UV.x + (TIME* speed.x)) * scale.x, (UV.y + (TIME* speed.y))* scale.y);
	EMISSION = color;
	ALPHA = pow(texture(noiseTexture, uv2).r, 4) * UV.y * UV.y * 2.;
}