# Simple Babylon Water Shaders
->[view live render](https://99-knots.github.io/SimpleBabylonWaterShaders/)

This is a quick surface level project to toy around with shaders and rendering them using Babylon.js.

Following the write-up on [water simulation in GPU Gems](https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models) I wanted to get my feet wet with some ocean waves myself and also gather some more experience with vertex shaders.
Every frame the vertices of a high resolution plane mesh get displaced based on either a sum of sines or of Gerstner waves and the derivative is used for calculating the normals for some simple Phong shading.
