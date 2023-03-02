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

    vec4 worldPosition;

    if (found) {
        worldPosition = skinMat * testMatrix * ibm * vec4(position,1.0);
    } else {
        worldPosition = vec4(position,1.0);
    }

    vec4 cameraPosition = objectMatrix * worldPosition;

    gl_Position = cameraMatrix * cameraPosition;

    outputTextureCoordinate = textureCoordinate;
}
