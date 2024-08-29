window.addEventListener('DOMContentLoaded', function () {
    var canvas = document.getElementById('renderCanvas');
    var engine = new BABYLON.Engine(canvas, true);

    var createScene = function () {
        var scene = new BABYLON.Scene(engine);

        var camera = new BABYLON.ArcRotateCamera("Camera", 0, Math.PI / 2, 10, BABYLON.Vector3.Zero(), scene);
        camera.maxZ = 100;
        camera.attachControl(canvas, true);
        const depthRenderer = scene.enableDepthRenderer();

        // object based renderpass
        const shaderMaterial = new BABYLON.ShaderMaterial("shader", scene, "./shaders/default", {
            attributes: ["position", "uv", "normal"], // Vertex shader inputs
            uniforms: ["worldViewProjection", "textureSampler", "lightPos"], // Fragment shader uniforms
        });
        shaderMaterial.setVector3("lightPos", new BABYLON.Vector3(20, 20, 0));
        shaderMaterial.setFloat("scaling", 1);
        shaderMaterial.setTexture("textureSampler", new BABYLON.Texture("./textures/tile.png", scene));

        // full-screen render pass
        // demo for broken texture in PostProcess: https://playground.babylonjs.com/#AUOKD6
        var postProcess = new BABYLON.PostProcess("post1", "./shaders/defaultPost", [], ["depthSampler"], 1.0, camera);
        postProcess.onApply = function (effect) {
            effect.setTexture("depthSampler", depthRenderer.getDepthMap());
        };


        //document.getElementById("scale-slider").addEventListener("input", (e) => {shaderMaterial.setFloat("scaling", e.target.value); console.log("scale", e.target.value)});

        // objects in scene
        const torus = BABYLON.CreateTorusKnot("sphere", {radius: 1.5, radialSegments: 128});
        torus.material = shaderMaterial;
        var sphere = BABYLON.MeshBuilder.CreateSphere("sphere", { diameter: 2, segments: 32 }, scene);
        sphere.material = shaderMaterial;

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
