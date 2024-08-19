shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D gradient : filter_nearest;

void fragment() {

    vec4 color = textureLod(gradient, vec2(1, 0), 0);

    ALBEDO = color.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
