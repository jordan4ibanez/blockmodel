import std.stdio;
import std.conv;
import bindbc.opengl;
import Camera = camera.camera;
import Texture = texture.texture;
import Window = window.window;
import mesh.mesh;
import shader.shader;
import vector_3d;
import matrix_4d;
import blockmodel.blockmodel;
import math;
import delta_time;

void main()
{

    // Window controls OpenGL and GLFW
    Window.initialize();
	Window.setTitle("BlockModel Editor");

    GLuint xyzTexture = Texture.addTexture("textures/xyz_compass.png");
    
    // Controls blockmodel rendering
    Shader modelShader = new Shader("model", "shaders/model_vertex.vs", "shaders/model_fragment.fs");
    modelShader.createUniform("cameraMatrix");
    modelShader.createUniform("objectMatrix");
    modelShader.createUniform("textureSampler");
    modelShader.createUniform("boneTRS");


    // BlockModel model = new BlockModel("models/minetest_sam.json");

    // Mesh debugMesh = new Mesh(
    //     model.getVertexPositions,
    //     model.getIndices,
    //     model.getTextureCoordinates,
    //     model.getBones,
    //     "textures/debug_character.png"
    // );
    

    // Controls regular rendering
    Shader regularShader = new Shader("regular", "shaders/regular_vertex.vs", "shaders/regular_fragment.fs");
    regularShader.createUniform("cameraMatrix");
    regularShader.createUniform("objectMatrix");
    regularShader.createUniform("textureSampler");

    Mesh xyzCompass = new Mesh()
        .addVertices([
            0,0,0,
            1,0,0,

            0,0,0,
            0,1,0,

            0,0,0,
            0,0,-1
        ])
        .addIndices([
            0,1,
            2,3,
            4,5
        ])
        .addTextureCoordinates([
            0,0,
            1.0/3.0,0,

            1.0/3.0,0,
            2.0/3.0,0,

            2.0/3.0,0,
            1,0
        ])
        .setTexture(Texture.getTexture("textures/xyz_compass.png"))
        .setLineMode(true)
        .finalize();
    

    float fancyRotation = 0;

    while (!Window.shouldClose()) {
        // Calculating the delta goes first, we want this to be as accurate as possible.
        calculateDelta();
        // Poll events is hugging the entry point to the scope
        // because it needs to take all GLFW input before anything
        // is calculated. This increases responsiveness.
        Window.pollEvents();

        fancyRotation += 1.0;
        if (fancyRotation >= 360.0) {
            fancyRotation -= 360.0;
        }

        Window.setTitle(Window.getTitle ~ " " ~ to!string(fancyRotation), false);

        Window.clear(1);

        Camera.clearDepthBuffer();
        Camera.setRotation(Vector3d(0,0,0));

        regularShader.startProgram();


        // modelShader.startProgram();

        // modelShader.setUniformMatrix4f("boneTRS", model.playAnimation(1), model.total_blocks);
        // modelShader.setUniformMatrix4f("cameraMatrix", camera.updateCameraMatrix(window));

        // modelShader.setUniformMatrix4f("objectMatrix",
        //     camera.setObjectMatrix(
        //         Vector3d(0,-3,-10), // Translation
        //         Vector3d(0,fancyRotation,0), // Rotation
        //         Vector3d(1), // Scale
        //     )
        // );

        // debugMesh.render(modelShader);

        regularShader.setUniformMatrix4f("cameraMatrix", Camera.updateCameraMatrix());

        regularShader.setUniformMatrix4f("objectMatrix",
            Camera.setObjectMatrix(
                Vector3d(0,-1,-4), // Translation
                Vector3d(0,fancyRotation,0), // Rotation
                Vector3d(1), // Scale
            )
        );

        xyzCompass.render(regularShader);
        

        Window.swapBuffers();
    }

    regularShader.deleteShader();
    // debugMesh.cleanUp(true);

    // modelShader.deleteShader();

    xyzCompass.cleanUp();

    Texture.cleanUp();

    Window.destroy();
}
