#version 410 core

// Frag is for tri texture mapping.
// This is a razor focused font rendering shader

in vec2 outputTextureCoordinate;

out vec4 fragColor;

uniform sampler2D textureSampler;

void main() {
    fragColor = texture(textureSampler, outputTextureCoordinate);
}