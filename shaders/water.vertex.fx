precision highp float;

// Attributes
attribute vec3 position;
attribute vec3 normal;

// Uniforms
uniform mat4 worldViewProjection;
uniform vec3 lightPos;
uniform vec3 camPos;
uniform float time;

// Varying
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 lightDir;
varying vec3 camDir;

void main(void) {
    float y_offset = 0.0;
    vec3 pos = vec3(position.x, position.y + y_offset, position.z);
    lightDir = normalize(pos - lightPos);
    camDir = normalize(pos - camPos);
    vPosition = position;
    vNormal = normalize(normal);
    gl_Position = worldViewProjection * vec4(pos, 1.0);
}