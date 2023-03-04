import std.stdio;
import bindbc.opengl;
import camera.camera;
import mesh.mesh;
import shader.shader;
import texture.texture;
import window.window;
import vector_3d;
import matrix_4d;
import blockmodel.blockmodel;
import math;
import delta_time;

void main()
{

    // Window controls OpenGL and GLFW
	Window window = new Window("BlockModel Editor").initialize;

    //* Allow direct message passing through reference pointers. Reduces verbosity.
    Mesh.createWindowContext(window);
    Camera.createWindowContext(window);
    Texture.createWindowContext(window);
    Shader.createWindowContext(window);

    // Camera controls view point and mathematical OpenGL calculations
    Camera camera = new Camera();

    //* Allow direct message passing through reference pointers. Reduces verbosity.
    Mesh.createCameraContext(camera);
    
    // Shader controls GLSL
    Shader modelShader = new Shader("base", "shaders/model_vertex.vs", "shaders/model_fragment.fs");
    modelShader.createUniform("cameraMatrix");
    modelShader.createUniform("objectMatrix");
    modelShader.createUniform("textureSampler");
    modelShader.createUniform("boneTRS");

    Camera.createModelShaderContext(modelShader);
    Mesh.createModelShaderContext(modelShader);


    BlockModel model = new BlockModel("models/minetest_sam.json");

    // Mesh debugMesh = new Mesh(
    //     model.getVertexPositions,
    //     model.getIndices,
    //     model.getTextureCoordinates,
    //     model.getBones,
    //     "textures/debug_character.png"
    // );
    

    float fancyRotation = 0;

    while (!window.shouldClose()) {

        fancyRotation += 1.0;
        if (fancyRotation >= 360.0) {
            fancyRotation -= 360.0;
        }
        
        window.pollEvents();

        calculateDelta();

        glUseProgram(modelShader.getShaderProgram);

        window.clear(1);
        camera.clearDepthBuffer();
        camera.setRotation(Vector3d(0,0,0));
        camera.updateCameraMatrix();

        //! Begin first iteration of animation prototyping, this is doing the ENTIRE animation
        //! In future implementation: Containerization will allow LERP portions of the animation

        // modelShader.setUniformMatrix4f("boneTRS", model.playAnimation(10), model.total_blocks);

        //! End first iteration of animation prototyping
        

        // debugMesh.render(
        //     Vector3d(0,-3,-10), // Translation
        //     Vector3d(0,fancyRotation,0), // Rotation
        //     Vector3d(1), // Scale
        // 1);

        window.swapBuffers();
    }

    Mesh.destroyModelShaderContext();
    Camera.destroyModelShaderContext();

    modelShader.deleteShader();

    //* Clean up all reference pointers.
    Mesh.destroyCameraContext();

    Shader.destroyWindowContext();
    Texture.destroyWindowContext();
    Mesh.destroyWindowContext();
    Camera.destroyWindowContext();

    window.destroy();
}
