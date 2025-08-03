shader_type spatial;
render_mode unshaded, cull_front;

void fragment() {
    ALBEDO = vec3(0.0); // black outline
}

void vertex() {
    // Push vertices outward along normals
    NORMAL = normalize(NORMAL);
    VERTEX += NORMAL * 0.0; // tweak thickness
}
