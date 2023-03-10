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

//! Development import REMOVE LATER
import Font = gui.razor_font;

void main()
{
    
    // Window controls OpenGL and GLFW
    Window.initialize();
    Window.setTitle("BlockModel Editor");

    Texture.addTexture("textures/xyz_compass.png");
    Texture.addTexture("textures/debug_character.png");
    Texture.addTexture("textures/debug.png");

    //! Start Razor Font testing


    Font.setRenderTargetAPICallString(
        (string input){
            Texture.addTexture(input);
        }
    );
    

    Font.setRenderFunc(
        (Font.RazorFontData fontData) {

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

    Font.createFont("fonts/test_font", "cool", true);
    Font.createFont("fonts/totally_original", "mc", true);


    //* End Razor Font testing

    // bool blah = true;
    // if (blah) {
    //     Window.destroy();
    //     return;
    // }
    
    
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

    while (!Window.shouldClose()) {
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

        Window.clear(0.9);

        if (false) {
            Camera.clearDepthBuffer();
            Camera.setRotation(Vector3d(0,0,0));

            // Render sam first

            Shader.startProgram("model");

            Shader.setUniformMatrix4("model", "boneTRS", model.playAnimation(1), model.total_blocks);
            Shader.setUniformMatrix4("model", "cameraMatrix", Camera.updateCameraMatrix());

            Shader.setUniformMatrix4("model", "objectMatrix",
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

            Shader.setUniformMatrix4("regular", "cameraMatrix", Camera.updateCameraMatrix());

            Shader.setUniformMatrix4("regular", "objectMatrix",
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

            Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());

            Shader.setUniformMatrix4("2d", "objectMatrix",
                Camera.setGuiObjectMatrix(
                    Vector2d(
                        (Window.getWidth / 2.0) - debug2d.getWidth,
                        (Window.getHeight / 2.0) - debug2d.getHeight
                    )
                )
            );

            debug2d.render("2d");
        }

        if (true) {
            // Now render this font
            
            Camera.clearDepthBuffer();

            Shader.startProgram("2d");

            Font.setCanvasSize(Window.getWidth, Window.getHeight);

            Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());
            Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix(Vector2d(0,0)) );

            Font.selectFont("mc");

            // Scoped to show individual calls into api
            {
                Font.renderToCanvas(0,0, 32, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
            }
            {
                int fontSize = 70;
                string textString = "I'm on the bottom right!";

                Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);
                // Now we're going to move this to the bottom right of the "canvas"
                double posX = Window.getWidth - textSize.width;
                double posY = Window.getHeight - textSize.height;

                Font.renderToCanvas(posX, posY, fontSize, textString);
            }
            {
                int fontSize = 32;
                string textString = "The text below is rendered at the window center-point!";

                Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);
                // Now we're going to move this to the bottom right of the "canvas"

                double posX = (Window.getWidth / 2.0) - (textSize.width / 2.0);
                double posY = (Window.getHeight / 2.0) - (textSize.height / 2.0) - 50;

                Font.renderToCanvas(posX, posY, fontSize, textString);

                Font.render();
            }


            if (true) {
                Font.selectFont("cool");

                Font.renderToCanvas(Window.getWidth / 2, Window.getHeight / 2, 54, "my test font is awful");

                Font.renderToCanvas(0, Window.getHeight - 54, 54, "test");

                Font.RazorFontData data2 = Font.flush();

                Mesh myCoolText2 = new Mesh()
                    .addVertices2d(data2.vertexPositions)
                    .addIndices(data2.indices)
                    .addTextureCoordinates(data2.textureCoordinates)
                    .setTexture(Texture.getTexture("fonts/test_font.png"))
                    .finalize();

                myCoolText2.render("2d");

                myCoolText2.cleanUp();
                
            }
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
