module gui.grid;

import doml.vector_3d;
import Camera = camera.camera;
import Shader = shader.shader;
import Texture = texture.texture;
import mesh.mesh;

// Grid acts like a static class just to render the 3d plane like in blender

Mesh gridMesh;


//50 on X, 50 on Z
private immutable int lines = 50;
private immutable double lineLength = 20;

void initialize() {

    double[] vertices;
    int[] indices;
    double[] textureCoords;

    foreach (i; 0..lines) {

        double pos = cast(double)i - cast(double) lines / 2.0;
        vertices ~= [
            -lineLength, 0, pos,
             lineLength, 0, pos,
             pos,        0,-lineLength,
             pos,        0, lineLength
        ];

        const int currentIndex = i * 4;
        
        indices ~= [
            currentIndex, currentIndex + 1,
            currentIndex + 2, currentIndex + 3
        ];

        textureCoords ~= [
            0,0,
            1.0/3.0,0,
            0,0,
            1.0/3.0,0,
        ];
    }
    

    gridMesh = new Mesh()
    .addVertices3d(vertices)
    .addIndices(indices)
    .addTextureCoordinates(textureCoords)
    .setTexture(Texture.getTexture("textures/xyz_compass.png"))
    .setLineMode(true)
    .finalize();


}


void render() {
    Camera.clearDepthBuffer();

    Shader.startProgram("regular");

    Shader.setUniformMatrix4("regular", "cameraMatrix", Camera.updateCameraMatrix());

    Shader.setUniformMatrix4("regular", "objectMatrix",
        Camera.setObjectMatrix(
            Vector3d(0,0,0), // Translation
            Vector3d(0,0,0), // Rotation
            Vector3d(1), // Scale
        )
    );

    gridMesh.render("regular");
    
}


void cleanUp() {

    gridMesh.cleanUp();

}