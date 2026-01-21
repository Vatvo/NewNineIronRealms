shader_type sky;

uniform sampler2D hdri_background : filter_linear, source_color, hint_default_black;
uniform sampler2D sky_background : filter_linear, source_color, hint_default_black;
uniform sampler2D clouds : filter_linear, source_color, hint_default_black;
uniform sampler2D cloud_color : source_color;
uniform float exposure : hint_range(0, 128) = 1.0;

void sky() {
	vec2 SKY_COORDS2 = vec2(SKY_COORDS.x + TIME * 0.02, SKY_COORDS.y );
	if(AT_CUBEMAP_PASS){
		COLOR = texture(hdri_background, SKY_COORDS).rgb * exposure;
	}
	else{
		COLOR = mix(texture(sky_background, SKY_COORDS).rgb, texture(cloud_color, SKY_COORDS).rgb, texture(clouds, SKY_COORDS2).r);
	}
}
