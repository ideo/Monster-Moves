attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#endif

void main()
{
    gl_Position = CC_MVPMatrix * a_position;
    mediump vec4 normal = a_color;
    float a = a_color.a;
    if (a_texCoord.x > 100.0)
        a = 0.0;

    v_fragmentColor = vec4(a_color.xyz, a);
    v_texCoord = a_texCoord;
}