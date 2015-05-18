#ifdef GL_ES
precision highp float;
#endif

uniform highp float hueAdjust;
uniform highp float saturateAdjust;

//varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

vec3 HSL2RGB(vec3 hsl)
{
    vec3 color;
    
    float			temp1, temp2;
    float			temp[3];
    int				i;
    
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if(hsl.y == 0.0) {
        color.r = hsl.z;
        color.g = hsl.z;
        color.b = hsl.z;
        return color;
    }
    
    // Test for luminance and compute temporary values based on luminance and saturation
    if(hsl.z < 0.5)
        temp2 = hsl.z * (1.0 + hsl.y);
    else
        temp2 = hsl.z + hsl.y - hsl.z * hsl.y;
    temp1 = 2.0 * hsl.z - temp2;
    
    // Compute intermediate values based on hue
    temp[0] = hsl.x + 1.0 / 3.0;
    temp[1] = hsl.x;
    temp[2] = hsl.x - 1.0 / 3.0;
    
    for(i = 0; i < 3; ++i) {
        
        // Adjust the range
        if(temp[i] < 0.0)
            temp[i] += 1.0;
        if(temp[i] > 1.0)
            temp[i] -= 1.0;
        
        
        if(6.0 * temp[i] < 1.0)
            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
        else {
            if(2.0 * temp[i] < 1.0)
                temp[i] = temp2;
            else {
                if(3.0 * temp[i] < 2.0)
                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
                else
                    temp[i] = temp1;
            }
        }
    }
    
    // Assign temporary values to R, G, B
    color.r = temp[0];
    color.g = temp[1];
    color.b = temp[2];
    
    return color;
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    //    mediump vec4 normalColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    mediump vec4 normalColor = texture2D(u_texture, v_texCoord);
    vec3 baseHSL = rgb2hsv(normalColor.rgb);
    
    float h = hueAdjust;
    if (h < 0.0) {
        h = 0.0;
    }
    
    if (h > 1.0) {
        h -= floor(hueAdjust);
    }
    
    baseHSL.x += hueAdjust;
    if (baseHSL.x > 1.0) {
        baseHSL.x -= 1.0;
    }
    
    baseHSL.y += saturateAdjust;
    if (baseHSL.y < 0.0) {
        baseHSL.y = 0.0;
    }
    
    if (baseHSL.y > 1.0) {
        baseHSL.y = 1.0;
    }
    
//    baseHSL.z += lightAdjust;
//    if (baseHSL.z < 0.0) {
//        baseHSL.z = 0.0;
//    }
//    
//    if (baseHSL.z > 1.0) {
//        baseHSL.z = 1.0;
//    }
    
    vec3 blendedColor = hsv2rgb(vec3(baseHSL.x, baseHSL.y, baseHSL.z));
    gl_FragColor = vec4(blendedColor, normalColor.a);
    
}
