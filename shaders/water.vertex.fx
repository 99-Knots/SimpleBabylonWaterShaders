// following this writeup: https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models
precision highp float;

// Attributes
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

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
bool circularWaves = true;


void main(void) {
    float l = 10.0;     // wavelength
    float f = 2./l;     // frequency
    float a = 0.7;      // amplitude
    float s = 1.;       // speed
    float phi = s * f;  // phase constant of speed
    float y_offset = 0.0;
    float k = 3.;


    vec3 bitangent = vec3(1., 0., 0.);
    vec3 tangent = vec3(0., 0., 1.);
    for(int i=0; i<numberOfWaves; i++) {
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.9));    // very interesting effect if uv.y as second texture coord parameter
        vec2 dir;
        float inner;
        if (circularWaves) {
            vec2 diff = position.xz - vec2(rand.rg*100. - 50.); // adjust to fit on plane
            dir = -normalize(diff);
            inner = dot(dir, diff) * f + time *phi;     // map to wave centric system
        }
        else {
            dir = normalize(rand.rg*2. - 1.);
            inner = dot(dir, position.xz) * f + time * phi;
        }
        y_offset += 2. * a * pow((sin(inner)+1.)/2., k);

        float deriv = f * a * cos(inner) * k * pow((sin(inner)+1.)/2., k-1.);
        bitangent.y += dir.x * deriv;
        tangent.y += dir.y * deriv;

        a *= 0.72;
        f *= 1.15;
        phi = s * f;
    }


    vec3 pos = vec3(position.x, position.y + y_offset, position.z);
    lightDir = normalize(pos - lightPos);
    camDir = normalize(pos - camPos);
    vPosition = position;
    vNormal = normalize(cross(bitangent, tangent));
    gl_Position = worldViewProjection * vec4(pos, 1.0);
}