uniform int uFrameIndex;
uniform sampler2D tex;

void main()
{
    if ((uFrameIndex & 1) != 0)
        discard;

    FragColor = texture(tex, vTexCoord);
}
