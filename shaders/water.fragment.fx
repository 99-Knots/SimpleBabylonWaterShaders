precision highp float;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 lightDir;
varying vec3 camDir;

void main(void) {

    vec3 Color_ocean = vec3(0.0, 0.13, 0.22);
    vec3 Color_amb = Color_ocean;
    vec3 Color_dif = vec3(0.0, 0.6, 0.8);
    vec3 Color_spec = vec3(1.0, 0.9, 0.7);

    // stormy water
    Color_ocean = vec3(0.13, 0.16, 0.19);
    Color_amb = Color_ocean;
    Color_dif = vec3(0.32, 0.38, 0.43);
    Color_spec = vec3(0.80, 0.83, 0.85);
    
    float shininess = 900.;

    vec3 N = normalize(vNormal);
    vec3 L = normalize(lightDir);
    vec3 V = normalize(camDir);
    
    
    float I_dif = max(dot(N, L), 0.0);
    vec3 r = normalize(dot(N, L) * N * 2.0 - L);
    float I_spec = pow(max(dot(r, V), 0.0), shininess);

    gl_FragColor = vec4(Color_amb + I_dif*Color_dif + I_spec*Color_spec, 1.0);
}