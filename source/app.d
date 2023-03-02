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
	Window window = new Window("easygltf prototyping").initialize;

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
    Shader shader = new Shader("base", "shaders/vertex.vs", "shaders/fragment.fs");
    shader.createUniform("cameraMatrix");
    shader.createUniform("objectMatrix");
    shader.createUniform("textureSampler");
    shader.createUniform("boneTRS");

    Camera.createShaderContext(shader);
    Mesh.createShaderContext(shader);


    BlockModel model = new BlockModel(1,1,1);

    Mesh debugMesh = new Mesh(
        model.getVertexPositions,
        model.getIndices,
        model.getTextureCoordinates,
        model.getBones,
        "textures/debug.png"
    );

    // Initialize shader program early to dump in uniforms
    glUseProgram(shader.getShaderProgram);


    // const int maxFrame = 1;
    // const double FPS = 1;
    // // Framerate is constant LINEAR interpolation
    // const double frameTick = 1/FPS;
    // double frameTime = 0.0;
    // int currentFrame = 0;

    while (!window.shouldClose()) {
        
        window.pollEvents();

        calculateDelta();

        glUseProgram(shader.getShaderProgram);

        window.clear(1);
        camera.clearDepthBuffer();
        camera.setRotation(Vector3d(0,0,0));
        camera.updateCameraMatrix();

        //! Begin first iteration of animation prototyping, this is doing the ENTIRE animation
        //! In future implementation: Containerization will allow LERP portions of the animation

        // frameTime += getDelta();

        // // Tick up integral frame
        // if (frameTime >= frameTick) {
        //     frameTime -= frameTick;
        //     currentFrame++;
        //     // Loop integral frame - Remember: 0 count
        //     if (currentFrame >= maxFrame) {
        //         currentFrame = 0;
        //     }
        // }

        // const double frameProgress = frameTime / frameTick;
        
        // int startFrame;
        // int endFrame;
        // // LERP back to frame 0 - Remember 0 count
        // if (currentFrame == maxFrame - 1) {
        //     startFrame = currentFrame;
        //     endFrame   = 0;
        // } 
        // // LERP to next frame
        // else {
        //     startFrame = currentFrame;
        //     endFrame   = currentFrame + 1;
        // }

        // Vector3d translation = Vector3d(t[startFrame]).lerp(t[endFrame], frameProgress);
        // Vector3d rotation    = Vector3d(r[startFrame]).lerp(r[endFrame], frameProgress);
        // Vector3d scale       = Vector3d(s[startFrame]).lerp(s[endFrame], frameProgress);

        
        // writeln(currentFrame);



        //! End first iteration of animation prototyping



        Matrix4d testMatrix = Matrix4d()
            .identity();
            // .setTranslation(translation)
            // .setRotationXYZ(rotation.x, rotation.y, rotation.z)
            // .scaleLocal(scale.x,scale.y,scale.z);

        shader.setUniformMatrix4f("boneTRS", testMatrix.getFloatArray);
        

        debugMesh.render(
            Vector3d(0,0,-8), // Translation
            Vector3d(0,0,0), // Rotation
            Vector3d(1), // Scale
        1);

        window.swapBuffers();
    }

    Mesh.destroyShaderContext();
    Camera.destroyShaderContext();

    shader.deleteShader();

    //* Clean up all reference pointers.
    Mesh.destroyCameraContext();

    Shader.destroyWindowContext();
    Texture.destroyWindowContext();
    Mesh.destroyWindowContext();
    Camera.destroyWindowContext();

    window.destroy();
}
