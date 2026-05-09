shader_type canvas_item;

const float TOP_BOUND = 43.0 / 256.0;
const float BOTTOM_BOUND = 246.0 / 256.0;
const float EMPTY_THRESHOLD = 0.02;

uniform float progress: hint_range(0.0, 1.0, 0.1);
uniform sampler2D fill_texture;
uniform vec4 glow_color: source_color;
uniform float glow_amount : hint_range(0.1, 0.9, 0.01);


void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
    vec4 fill_color = texture(fill_texture, UV);

    float fill_line = mix(BOTTOM_BOUND, TOP_BOUND, progress);
    float fill_amount = step(fill_line, UV.y);
    //fill_amount *= step(TOP_BOUND, UV.y);
    //fill_amount *= step(TOP_BOUND, UV.y) * step(UV.y, BOTTOM_BOUND);

    fill_color *= glow_color;
    fill_color.a *= glow_amount;

    vec4 final_color = base_color + fill_color * fill_amount * fill_color.a;

    if (progress > EMPTY_THRESHOLD) {
        COLOR = final_color;
        }



}
