#version 410 core

// Frag is for tri positions.

// Bone limit is 256.
const int MAX_BONES = 256;

// Joint is synced with position.
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 textureCoordinate;
layout (location = 2) in int joint;

out vec2 outputTextureCoordinate;

uniform mat4 cameraMatrix;
uniform mat4 objectMatrix;

uniform vec3 bonePosition[MAX_BONES];
uniform vec3 boneRotation[MAX_BONES];
uniform vec3 boneScale[MAX_BONES];

void main() {

    // Position in world without camera matrix application
    vec4 objectPosition = vec4(bonePosition[0], 1) * vec4(position,1.0);

    // Position in world relative to camera
    vec4 cameraPosition = objectMatrix * objectPosition;

    // Output real coordinates into gpu
    gl_Position = cameraMatrix * cameraPosition;

    outputTextureCoordinate = textureCoordinate;
}
