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
uniform int useGerstner;

// Varying
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 lightDir;
varying vec3 camDir;

const int numberOfWaves = 32;
bool circularWaves = false;
float Q = 3.;

struct Wave {
    vec3 position;
    vec3 normal;
};

Wave sumOfSines() {
    float l = 50.0;     // wavelength
    float f = 2./l;     // frequency
    float a = 3.;      // amplitude
    float s = 3.;       // speed
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

        a *= 0.79;
        f *= 1.15;
        phi = s * f;
    }
    Wave wave;
    wave.position = vec3(position.x, position.y + y_offset, position.z);
    wave.normal = normalize(cross(tangent, bitangent));
    return wave;
}

Wave GerstnerWaves() {
    float l = 150.0;     // wavelength
    float s = 4.5;      // speed
    float a;            // amplitude
    float phi;          // phase constant of speed
    float w;
    float k;

    vec3 offset = vec3(0.);
    vec3 normal = vec3(0., 1., 0.);

    for (int i=0; i<numberOfWaves; i++) {
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.9));
        l *= 0.84;

        k = 6.283185/l;
        a = 0.018 * l;
        w = sqrt(0.0981 * k);
        phi = s * w;
        vec2 dir = normalize(rand.rg*2. - 1.);

        float inner = k * dot(dir, position.xz) + time * phi;
        float sinInner = sin(inner);
        float cosInner = cos(inner);
        
        float Qi = Q/(k*a*float(numberOfWaves));
        offset.x += Qi * a * dir.x * cosInner;
        offset.y += a * sinInner;
        offset.z += Qi * a * dir.y * cosInner;

        normal.x -= dir.x * w * a * cosInner;
        normal.z -= dir.y * w * a * cosInner;
        normal.y -= Qi * w * a * sinInner;
        
    }

    Wave wave;
    wave.position = position.xyz + offset;
    wave.normal = normalize(normal);
    
    return wave;
}

Wave Gerstner() {
    float l = 50.;
    float w;
    float a;
    float speed = 1.5;
    float phi;
    float medianWavelength = 15.;
    float k = 6.283185 / l;


    vec3 offset = vec3(0.);
    vec3 normal = vec3(0.);
    
    for (int i = 0; i < numberOfWaves; i++)
    {
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.9));
        //l = medianWavelength * pow(1.3, -float(i));
        //l = mix(0.05, 8.0, rand.g);
        l *= 0.84;
        k = 6.283185 / l;
        w = sqrt(0.0981 * 6.283185/l);
        a = 0.015 * l;
        phi = speed * w;
        float Qi = Q / (w*a*float(numberOfWaves));
        float angle = rand.r * 6.283185;
        vec2 dir = vec2(cos(angle), sin(angle));
        float inner = k * dot(dir, position.xz) + time * phi;
        float sinInner = sin(inner);
        float cosInner = cos(inner);
        offset.x += Qi * a * dir.x * cosInner;
        offset.y += a * sinInner;
        offset.z += Qi * a * dir.y * cosInner;

        normal.x += dir.x * w * a * cosInner;
        normal.y += Qi * w * a * sinInner;
        normal.z += dir.y * w * a * cosInner;
    }

    Wave wave;
    wave.position = position.xyz + offset;
    wave.normal = normalize(vec3(0., 1.0, 0.) - normal);
    return wave;

}


void main(void) {
    
    Wave wave;
    if(useGerstner == 1) {
        wave = GerstnerWaves();
    }
    else {
        wave = sumOfSines();
    }

    vec3 pos = wave.position;
    lightDir = normalize(lightPos - pos);
    camDir = normalize(camPos - pos);
    vPosition = wave.position;
    vNormal = wave.normal;
    gl_Position = worldViewProjection * vec4(pos, 1.0);
}