precision highp float;

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform sampler2D depthSampler;


void main() 
{
    vec4 col = texture(textureSampler, vUV);
    vec4 depth = texture(depthSampler, vUV);
    gl_FragColor = vec4(col.rgb, 1.0);
}