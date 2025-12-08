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

int numberOfWaves = 32;
bool circularWaves = false;
float Q = 0.9;

struct Wave {
    vec3 position;
    vec3 normal;
};

Wave sumOfSines() {
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
    Wave wave;
    wave.position = vec3(position.x, position.y + y_offset, position.z);
    wave.normal = normalize(cross(tangent, bitangent));
    return wave;
}

Wave GerstnerWaves() {
    float medianWavelength = 7.;
    float l = 10.0;     // wavelength
    //float f = 2./l;     // frequency
    float f = sqrt(0.0981*6.283185/l);
    float a = 1.;      // amplitude
    float s = 1.;       // speed
    float phi = s * f;  // phase constant of speed
    float k = 3.;

    float x_offset = 0.;
    float y_offset = 0.;
    float z_offset = 0.;

    vec3 normal = vec3(0., 1., 0.);

    for (int i=0; i<numberOfWaves; i++) {
        float Qi = Q/(f*a*float(numberOfWaves));
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.9));
        l = medianWavelength * (rand.b * 1.5 + 0.5);
        f = sqrt(0.0981*6.283185/l);
        a = 0.05*l;
        vec2 dir = normalize(rand.rg*2. - 1.);
        float inner = f * dot(dir, position.xz) + time * phi;
        float sinInner = sin(inner);
        float cosInner = cos(inner);
        
        x_offset += Qi * a * dir.x * cosInner;
        y_offset += a * sinInner;
        z_offset += Qi * a * dir.y * cosInner;

        normal.x -= dir.x * f * a * cosInner;
        normal.z -= dir.y * f * a * cosInner;
        normal.y -= Qi * f * a * sinInner;
        
        //a *= 0.72;
        //f *= 1.13;
        phi = s * f;
    }

    Wave wave;
    wave.position = vec3(position.x + x_offset, y_offset, position.z + z_offset);
    wave.normal = -normal;  // why negative?
    return wave;
}

Wave Gerstner(vec3 vertexPos) {
    float l = 15.;
    float w;
    float a;
    float speed = 1.0;
    float phi;
    float medianWavelength = 15.;


    vec3 offset = vec3(0.);
    vec3 normal = vec3(0.);
    
    for (int i = 0; i < numberOfWaves; i++)
    {
        vec4 rand = texture2D(noise, vec2(float(i)/float(numberOfWaves), 0.9));
        //l = medianWavelength * pow(1.3, -float(i));
        //l = mix(0.05, 8.0, rand.g);
        l *= 0.84;
        w = sqrt(0.0981 * 6.283185/l);
        a = 0.05 * l;
        phi = speed * w;
        float Qi = Q / (w*a*float(numberOfWaves));
        float angle = rand.r * 6.283185;
        vec2 dir = vec2(cos(angle), sin(angle));
        float inner = w * dot(dir, position.xz) + time * phi;
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
    wave.position = vertexPos.xyz + offset;
    wave.normal = vec3(0., 1.0, 0.) - normal;
    return wave;

}


void main(void) {
    
    Wave wave;
    //wave = sumOfSines();
    //wave = GerstnerWaves();
    wave = Gerstner(position.xyz);

    vec3 pos = wave.position;
    lightDir = normalize(lightPos - pos);
    camDir = normalize(camPos - pos);
    vPosition = position;
    vNormal = wave.normal;
    gl_Position = worldViewProjection * vec4(pos, 1.0);
}