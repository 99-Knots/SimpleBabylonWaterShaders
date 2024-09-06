precision highp float;

        varying vec3 vPosition;
        varying vec3 vNormal;
        varying vec3 lightDir;
        varying vec3 camDir;

        void main(void) {
            vec3 Color_amb = vec3(0.03, 0.15, 0.20);
            vec3 Color_dif = vec3(0.0, 0.6, 0.8);
            vec3 Color_spec = vec3(1.0, 0.9, 0.7);
            
            float I_dif = max(dot(vNormal, lightDir), 0.0);
            vec3 r = normalize(dot(vNormal, lightDir) * vNormal * 2.0 - lightDir);
            float I_spec = pow(max(dot(r, camDir), 0.0), 100.0);

            gl_FragColor = vec4(Color_amb * 1.8 + I_dif*Color_dif + I_spec*Color_spec, 1.0);
        }