shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec2 uv = UV;

    vec2 p = uv;

    float alpha = 1.0;

    // Esquinas redondeadas
    if (p.x < corner_radius && p.y < corner_radius) {
        float dist = distance(p, vec2(corner_radius, corner_radius));
        alpha *= smoothstep(corner_radius, corner_radius - 0.01, dist);
    }
    else if (p.x > 1.0 - corner_radius && p.y < corner_radius) {
        float dist = distance(p, vec2(1.0 - corner_radius, corner_radius));
        alpha *= smoothstep(corner_radius, corner_radius - 0.01, dist);
    }
    else if (p.x < corner_radius && p.y > 1.0 - corner_radius) {
        float dist = distance(p, vec2(corner_radius, 1.0 - corner_radius));
        alpha *= smoothstep(corner_radius, corner_radius - 0.01, dist);
    }
    else if (p.x > 1.0 - corner_radius && p.y > 1.0 - corner_radius) {
        float dist = distance(p, vec2(1.0 - corner_radius, 1.0 - corner_radius));
        alpha *= smoothstep(corner_radius, corner_radius - 0.01, dist);
    }

    vec4 tex = texture(TEXTURE, uv);
    tex.a *= alpha;
    COLOR = tex;
}
