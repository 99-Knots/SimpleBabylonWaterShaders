precision highp float;

        varying vec3 vPosition;
        varying vec3 vNormal;
        varying vec3 lightDir;
        varying vec3 camDir;

        void main(void) {
            float h = clamp(vPosition.y * 0.5, -0.2, 0.2);
            vec3 Color_ocean = vec3(0.0, 0.13, 0.22);

            vec3 Color_amb = Color_ocean + h;
            vec3 Color_dif = vec3(0.0, 0.6, 0.8);
            vec3 Color_spec = vec3(1.0, 0.9, 0.7);
            float shininess = 60.;
            
            float I_dif = max(dot(vNormal, lightDir), 0.0);
            vec3 r = normalize(dot(vNormal, lightDir) * vNormal * 2.0 - lightDir);
            float I_spec = pow(max(dot(r, camDir), 0.0), shininess);

            gl_FragColor = vec4(Color_amb * 1.8 + I_dif*Color_dif + I_spec*Color_spec, 1.0);
        }