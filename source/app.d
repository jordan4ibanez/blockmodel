import std.stdio;
import std.conv;
import bindbc.opengl;
import Camera = camera.camera;
import Shader = shader.shader;
import Texture = texture.texture;
import Window = window.window;
import mesh.mesh;
import doml.vector_2d;
import doml.vector_3d;
import doml.matrix_4d;
import blockmodel.blockmodel;
import Math = doml.math;
import delta_time;
import std.typecons;

import gui.gui;

//! Development import REMOVE LATER
import Font = razor_font;

void main()
{
    
    // Window controls OpenGL and GLFW
    Window.initialize();
    Window.setTitle("BlockModel Editor");

    Texture.addTexture("textures/xyz_compass.png");
    Texture.addTexture("textures/debug_character.png");
    Texture.addTexture("textures/debug.png");
    Texture.addTexture("textures/button.png");


    Font.setRenderTargetAPICallString(
        (string input){
            Texture.addTexture(input);
        }
    );
    

    Font.setRenderFunc(
        (Font.RazorFontData fontData) {

            if (fontData.vertexPositions.length == 0) {
                return;
            }

            string fileLocation = Font.getCurrentFontTextureFileLocation();

            Mesh tempObject = new Mesh()
                .addVertices2d(fontData.vertexPositions)
                .addIndices(fontData.indices)
                .addTextureCoordinates(fontData.textureCoordinates)
                .setTexture(Texture.getTexture(fileLocation))
                .finalize();

            tempObject.render("2d");
            tempObject.cleanUp();
        }
    );
    
    Font.createFont("fonts/totally_original", "mc", true);
    
    
    
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
    double d = 100.0;
    Mesh debug2d = new Mesh()
        .addVertices2d([
            0,0,
            0,d,
            d,d,
            d,0
        ])
        .addIndices([
            0,1,2,2,3,0
        ])
        .addTextureCoordinates([
            0,0,
            0,1,
            1,1,
            1,0
        ])
        .setTexture(Texture.getTexture("textures/debug.png"))
        .finalize();

    double fancyRotation = 0;

    Window.setVsync(0);


    //! GUI TESTING


    GUI gui = new GUI();

    Font.selectFont("mc");

    gui.addText("cool",
        new Text("cool").setPosition(Vector2d(0,0)).setSize(24).setWindowPosition(TOP_LEFT)
    );
    
    gui.addButton("pushit", new Button(
            new Text("this is a bunch of text!").setSize(24)
        ).setWindowPosition(CENTER_CENTER)
    );

    gui.addButton("pushit2", new Button(
            new Text("THIS BUTTON IS HUGE!!").setSize(48)
        ).setWindowPosition(TOP_CENTER)
    );

    gui.addButton("pushit3", new Button(
            new Text("push me, I dare you").setSize(24)
        ).setWindowPosition(TOP_RIGHT)
    );


    //! END GUI TESTING


    while (!Window.shouldClose()) {
        // Poll events is hugging the entry point to the scope
        // because it needs to take all GLFW input before anything
        // is calculated. This increases responsiveness.
        Window.pollEvents();


        fancyRotation += getDelta * 100.0;
        if (fancyRotation >= 360.0) {
            fancyRotation -= 360.0;
        }

        Window.setTitle(Window.getTitle ~ " | FPS: " ~ to!string(Window.getFPS) ~ " | Rotation: " ~ to!string(fancyRotation), false);

        Window.clear(0.8);

        Camera.clearDepthBuffer();
        Camera.setRotation(Vector3d(0,0,0));

        Shader.startProgram("2d");

        Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());
        Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(Vector2d(0,0)) );

        Font.setCanvasSize(Window.getWidth(), Window.getHeight());

        gui.render();
        
        Window.swapBuffers();
    }

    gui.destroy();

    Shader.deleteShader("regular");
    Shader.deleteShader("model");
    Shader.deleteShader("2d");
    
    debugMesh.cleanUp();
    xyzCompass.cleanUp();
    debug2d.cleanUp();

    Texture.cleanUp();

    Window.destroy();
}
