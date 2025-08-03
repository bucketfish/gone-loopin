shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 color : source_color = vec4(1.0);



void fragment() {
    ALBEDO = vec3(color.r, color.g, color.b); // black outline
	ALPHA = color.a;
}

void vertex() {
    // Push vertices outward along normals
    NORMAL = normalize(NORMAL);
    VERTEX += NORMAL * 0.0; // tweak thickness
}
