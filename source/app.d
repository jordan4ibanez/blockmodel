import std.stdio;
import std.conv;
import bindbc.opengl;
import Camera = camera.camera;
import Shader = shader.shader;
import Texture = texture.texture;
import Window = window.window;
import mesh.mesh;
import vector_2d;
import vector_3d;
import matrix_4d;
import blockmodel.blockmodel;
import math;
import delta_time;

//! Development import REMOVE LATER
import gui.ttf;

void main()
{

    // Window controls OpenGL and GLFW
    Window.initialize();

    TTFont testFont = new TTFont("fonts/mc.ttf");

    bool blah = true;
    if (blah) {
        Window.destroy();
        return;
    }


	Window.setTitle("BlockModel Editor");

    Texture.addTexture("textures/xyz_compass.png");
    Texture.addTexture("textures/debug_character.png");
    Texture.addTexture("textures/debug.png");
    
    // Controls blockmodel rendering
    Shader.create("model", "shaders/model_vertex.vs", "shaders/model_fragment.fs");
    Shader.createUniform("model", "cameraMatrix");
    Shader.createUniform("model", "objectMatrix");
    Shader.createUniform("model", "textureSampler");
    Shader.createUniform("model", "boneTRS");


    BlockModel model = new BlockModel("models/minetest_sam.json");

    Mesh debugMesh = new Mesh()
        .addVertices3d(model.getVertexPositions)
        .addIndices(model.getIndices)
        .addTextureCoordinates(model.getTextureCoordinates)
        .addBones(model.getBones)
        .setTexture(Texture.getTexture("textures/debug_character.png"))
        .finalize();
    

    // Controls regular rendering
    Shader.create("regular", "shaders/regular_vertex.vs", "shaders/regular_fragment.fs");
    Shader.createUniform("regular", "cameraMatrix");
    Shader.createUniform("regular", "objectMatrix");
    Shader.createUniform("regular", "textureSampler");

    Mesh xyzCompass = new Mesh()
        .addVertices3d([
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
    
    Shader.create("2d", "shaders/2d_vertex.vs", "shaders/2d_fragment.fs");
    Shader.createUniform("2d", "cameraMatrix");
    Shader.createUniform("2d", "objectMatrix");
    Shader.createUniform("2d", "textureSampler");

    // Debug scale thing
    float d = 100.0;
    Mesh debug2d = new Mesh()
        .addVertices2d([
            0,0,
            0,d,
            d,d,
            d,0
        ])
        .addIndices([
            0,1,2, 2,3,0
        ])
        .addTextureCoordinates([
            0,0,
            0,1,
            1,1,
            1,0
        ])
        .setTexture(Texture.getTexture("textures/debug.png"))
        .finalize();

    float fancyRotation = 0;

    Window.setVsync(0);



    while (Window.shouldClose()) {
        // Calculating the delta goes first, we want this to be as accurate as possible.
        calculateDelta();
        // Poll events is hugging the entry point to the scope
        // because it needs to take all GLFW input before anything
        // is calculated. This increases responsiveness.
        Window.pollEvents();

        fancyRotation += getDelta * 100.0;
        if (fancyRotation >= 360.0) {
            fancyRotation -= 360.0;
        }

        Window.setTitle(Window.getTitle ~ " | FPS: " ~ to!string(Window.getFPS) ~ " | Rotation: " ~ to!string(fancyRotation), false);

        Window.clear(1);

        if (false) {
            Camera.clearDepthBuffer();
            Camera.setRotation(Vector3d(0,0,0));

            // Render sam first

            Shader.startProgram("model");

            Shader.setUniformMatrix4f("model", "boneTRS", model.playAnimation(1), model.total_blocks);
            Shader.setUniformMatrix4f("model", "cameraMatrix", Camera.updateCameraMatrix());

            Shader.setUniformMatrix4f("model", "objectMatrix",
                Camera.setObjectMatrix(
                    Vector3d(0,-3,-10), // Translation
                    Vector3d(0,fancyRotation,0), // Rotation
                    Vector3d(1), // Scale
                )
            );

            debugMesh.render("model");

            // Render the xyz compass on top
            Camera.clearDepthBuffer();

            Shader.startProgram("regular");

            Shader.setUniformMatrix4f("regular", "cameraMatrix", Camera.updateCameraMatrix());

            Shader.setUniformMatrix4f("regular", "objectMatrix",
                Camera.setObjectMatrix(
                    Vector3d(0,-1,-4), // Translation
                    Vector3d(0,fancyRotation,0), // Rotation
                    Vector3d(1), // Scale
                )
            );

            xyzCompass.render("regular");


            // Now render this debug thing on top of that
            Camera.clearDepthBuffer();

            Shader.startProgram("2d");

            Shader.setUniformMatrix4f("2d", "cameraMatrix", Camera.updateGuiMatrix());

            Shader.setUniformMatrix4f("2d", "objectMatrix",
                Camera.setGuiObjectMatrix(
                    Vector2d(
                        (Window.getWidth / 2.0) - debug2d.getWidth,
                        (Window.getHeight / 2.0) - debug2d.getHeight
                    )
                )
            );

            debug2d.render("2d");

        }

        Window.swapBuffers();
    }

    Shader.deleteShader("regular");
    Shader.deleteShader("model");
    Shader.deleteShader("2d");

    
    debugMesh.cleanUp();
    xyzCompass.cleanUp();
    debug2d.cleanUp();

    Texture.cleanUp();

    Window.destroy();
}
