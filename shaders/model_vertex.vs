#version 410 core

// Frag is for tri positions.
// View this as a reference shader for blockmodel.

// Bone limit is 64.
const int MAX_BONES = 64;

// Joint is synced with position.
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 textureCoordinate;
layout (location = 2) in int bone;

out vec2 outputTextureCoordinate;

uniform mat4 cameraMatrix;
uniform mat4 objectMatrix;

uniform mat4 boneTRS[MAX_BONES];

void main() {

    // Position in world without camera matrix application
    vec4 objectPosition = boneTRS[bone] * vec4(position,1.0);

    // Position in world relative to camera
    vec4 cameraPosition = objectMatrix * objectPosition;

    // Output real coordinates into gpu
    gl_Position = cameraMatrix * cameraPosition;

    outputTextureCoordinate = textureCoordinate;
}
