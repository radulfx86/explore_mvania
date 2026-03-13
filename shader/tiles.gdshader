shader_type canvas_item;

uniform vec4 reality_color: source_color;

void fragment() {
	COLOR = COLOR * reality_color;
}
