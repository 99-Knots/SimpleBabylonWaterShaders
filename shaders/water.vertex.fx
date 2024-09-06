// following this writeup: https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models
precision highp float;

// Attributes
attribute vec3 position;
attribute vec3 normal;

// Uniforms
uniform mat4 worldViewProjection;
uniform vec3 lightPos;
uniform vec3 camPos;
uniform float time;
uniform sampler2D noise;

// Varying
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 lightDir;
varying vec3 camDir;

int numberOfWaves = 8;


void main(void) {
    float l = 10.0;      // wavelength
    float f = 2./l;     // frequency
    float a = 0.6;       // amplitude
    float s = 2.;       // speed
    float phi = s * f;  // phase constant of speed
    vec2 d = vec2(1., 1.);  //wave direction
    float y_offset = 0.0;

    vec3 bitangent = vec3(1., 0., 0.);
    vec3 tangent = vec3(0., 0., 1.);
    for(int i=0; i<numberOfWaves; i++) {
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.7));
        vec2 dir = normalize(rand.rg*2. - 1.);
        float inner = dot(dir, position.xz) * f + time * phi;
        y_offset += a * sin(inner);

        bitangent.y += f * dir.x * a * cos(inner);
        tangent.y += f * dir.y * a * cos(inner);
        a *= 0.8;
        f *= 1.1;
        phi = s * f;
    }


    vec3 pos = vec3(position.x, position.y + y_offset, position.z);
    lightDir = normalize(pos - lightPos);
    camDir = normalize(pos - camPos);
    vPosition = position;
    vNormal = normalize(cross(bitangent, tangent));
    gl_Position = worldViewProjection * vec4(pos, 1.0);
}