shader_type sky;

uniform sampler2D hdri_background : filter_linear, source_color, hint_default_black;
uniform sampler2D sky_background : filter_linear, source_color, hint_default_black;
uniform sampler2D clouds : filter_linear, source_color, hint_default_black;
uniform sampler2D cloud_color : source_color;
uniform sampler2D cloud_mask : filter_linear, source_color, hint_default_white;
uniform float cloud_speed = 0.01;
uniform float exposure : hint_range(0, 128) = 1.0;

void sky() {
	vec2 SKY_COORDS2 = vec2(SKY_COORDS.x + TIME * cloud_speed, SKY_COORDS.y );
	vec2 CLOUD_MASK_COORDS = vec2(SKY_COORDS.x + TIME * cloud_speed * -0.1, SKY_COORDS.y);
	if(AT_CUBEMAP_PASS){
		COLOR = texture(hdri_background, SKY_COORDS).rgb * exposure;
	}
	else{
		COLOR = mix(texture(sky_background, SKY_COORDS).rgb, texture(cloud_color, SKY_COORDS).rgb, texture(clouds, SKY_COORDS2).r * texture(cloud_mask, CLOUD_MASK_COORDS).r);
	}
}
