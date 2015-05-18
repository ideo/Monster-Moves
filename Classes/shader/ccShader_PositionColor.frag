#ifdef GL_ES
precision lowp float;
#endif

uniform mediump float width;
uniform mediump float height;
uniform mediump float radius;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    gl_FragColor = v_fragmentColor;
}
