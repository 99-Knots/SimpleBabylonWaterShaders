window.addEventListener('DOMContentLoaded', function () {
    var canvas = document.getElementById('renderCanvas');
    var engine = new BABYLON.Engine(canvas, true);

    var createScene = function () {
        var scene = new BABYLON.Scene(engine);

        var camera = new BABYLON.ArcRotateCamera("Camera", 0, 1.3, 100, new BABYLON.Vector3(0, 1, 0), scene);
        //camera.maxZ = 100;
        camera.attachControl(canvas, true);
        const depthRenderer = scene.enableDepthRenderer();

        const sunPosition = new BABYLON.Vector3(-500, 100, 0);

        const skyMaterial = new BABYLON.SkyMaterial('skyMat', scene);
        skyMaterial.backFaceCulling = false;
        skyMaterial.useSunPosition = true;
        skyMaterial.sunPosition = sunPosition;

        const skybox = BABYLON.MeshBuilder.CreateBox('skyBox', { size: 1000.0 }, scene);
        skybox.material = skyMaterial;

        // full-screen render pass
        // demo for broken texture in PostProcess: https://playground.babylonjs.com/#AUOKD6
        var postProcess = new BABYLON.PostProcess("post1", "./shaders/defaultPost", [], ["depthSampler"], 1.0, camera);
        postProcess.onApply = function (effect) {
            effect.setTexture("depthSampler", depthRenderer.getDepthMap());
        };

        // water shader
        const waterMaterial = new BABYLON.ShaderMaterial("shader", scene, "./shaders/water", {
            attributes: ["position", "uv", "normal"], // Vertex shader inputs
            uniforms: ["worldViewProjection", "lightPos", "cameraPos", "time", "noise"], // Fragment shader uniforms
        });
        waterMaterial.backFaceCulling = false;
        waterMaterial.setVector3("lightPos", sunPosition);
        waterMaterial.setVector3("cameraPos", camera.position);
        waterMaterial.setTexture("noise", new BABYLON.Texture("./textures/noise_rgba_32x32.png", scene));

        const waterSurface = BABYLON.MeshBuilder.CreateGround("ground", {width: 100, height: 100, subdivisions: 1000}, scene);
        waterSurface.material = waterMaterial;

        let time = 0;
        scene.registerBeforeRender(function () {
            time += 0.1;
            waterMaterial.setFloat('time', time);
        });

        return scene;
    };


    var scene = createScene();

    engine.runRenderLoop(function () {
        scene.render();
    });
    window.addEventListener('resize', function () {
        engine.resize();
    });
});
