#version 410 core

// Frag is for tri texture mapping.

in vec2 outputTextureCoordinate;

out vec4 fragColor;

uniform sampler2D textureSampler;

void main() {
    fragColor = texture(textureSampler, outputTextureCoordinate);// * vec4(animationProgress,animationProgress,animationProgress, 1.0);
}