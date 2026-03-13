shader_type canvas_item;
uniform sampler2D frameTex;
uniform vec2 texSize;
uniform vec2 frameSize;
uniform vec2 frameOffset;
uniform vec4 reality_color: source_color;

void fragment() {
	vec2 uv_frame =  UV * frameSize / texSize + frameOffset / texSize;
	// Called for every pixel the material is visible on.
	vec2 d = UV - vec2(0.5,0.5);
	float dist = 2.0 * length(d);
	COLOR = COLOR * dist * reality_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
