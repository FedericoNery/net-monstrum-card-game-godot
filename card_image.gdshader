shader_type canvas_item;

uniform float radius = 1; // Ajusta el tamaño de las esquinas

void fragment() {
    vec2 size = vec2(1.0, 1.0); // Tamaño normalizado de la imagen
    vec2 pixel_pos = UV * size; // Posición normalizada

    if (pixel_pos.x < radius && pixel_pos.y < radius) {
        if (distance(pixel_pos, vec2(radius, radius)) > radius) discard;
    }
    if (pixel_pos.x > (1.0 - radius) && pixel_pos.y < radius) {
        if (distance(pixel_pos, vec2(1.0 - radius, radius)) > radius) discard;
    }
    if (pixel_pos.x < radius && pixel_pos.y > (1.0 - radius)) {
       if (distance(pixel_pos, vec2(radius, 1.0 - radius)) > radius) discard;
    }
    if (pixel_pos.x > (1.0 - radius) && pixel_pos.y > (1.0 - radius)) {
        if (distance(pixel_pos, vec2(1.0 - radius, 1.0 - radius)) > radius) discard;
    }
}
