#version 330 core

# This will convert a Frame Sequential 3D to SBS at 48 FPS

uniform sampler2D texLeft;   // even frames
uniform sampler2D texRight;  // odd frames

in vec2 vTexCoord;
out vec4 FragColor;

void main()
{
    vec2 uv = vTexCoord;

    // Convert uv to pixel space parity
    float xParity = mod(floor(uv.x * textureSize(texLeft, 0).x), 2.0);
    float yParity = mod(floor(uv.y * textureSize(texLeft, 0).y), 2.0);

    bool evenX = (xParity == 0.0);
    bool evenY = (yParity == 0.0);

    vec4 A; // StackHorizontal(left1, right1)
    vec4 B; // StackHorizontal(left2, right2)

    // ----- A: left1 | right1 -----
    if (uv.x < 0.5) {
        // left1 → even columns from left
        vec2 srcUV = vec2(uv.x * 2.0, uv.y);
        if (evenX)
            A = texture(texLeft, srcUV);
        else
            discard;
    } else {
        // right1 → odd columns from right
        vec2 srcUV = vec2((uv.x - 0.5) * 2.0, uv.y);
        if (!evenX)
            A = texture(texRight, srcUV);
        else
            discard;
    }

    // ----- B: left2 | right2 -----
    if (uv.x < 0.5) {
        // left2 → odd columns from left
        vec2 srcUV = vec2(uv.x * 2.0, uv.y);
        if (!evenX)
            B = texture(texLeft, srcUV);
        else
            discard;
    } else {
        // right2 → even columns from right
        vec2 srcUV = vec2((uv.x - 0.5) * 2.0, uv.y);
        if (evenX)
            B = texture(texRight, srcUV);
        else
            discard;
    }

    // ----- interleave(A, B) -----
    FragColor = evenY ? A : B;
}
