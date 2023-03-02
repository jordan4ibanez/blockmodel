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

    Vector3d[] t = [
        Vector3d(0,0,0),
        Vector3d(1,0,0),
        Vector3d(2,0,0),
        Vector3d(3,0,0),
    ];
    Vector3d[] r = [
        Vector3d(0,0,0),
        Vector3d(0,0,0),
        Vector3d(0,0,0),
        Vector3d(0,0,0),
    ];
    Vector3d[] s = [
        Vector3d(1,1,1),
        Vector3d(1,1,1),
        Vector3d(1,1,1),
        Vector3d(1,1,1),
    ];

    const int maxFrame = 4;
    const double FPS = 4;
    // Framerate is constant LINEAR interpolation
    const double frameTick = 1/FPS;
    double frameTime = 0.0;
    int currentFrame = 0;

    while (!window.shouldClose()) {
        
        window.pollEvents();

        calculateDelta();

        glUseProgram(shader.getShaderProgram);

        window.clear(1);
        camera.clearDepthBuffer();
        camera.setRotation(Vector3d(0,0,0));
        camera.updateCameraMatrix();

        //! Begin first iteration of animation prototyping

        frameTime += getDelta();

        if (frameTime >= frameTick) {
            frameTime -= frameTick;
            currentFrame++;

            if (currentFrame >= maxFrame) {
                currentFrame = 0;
            }
        }

        writeln(currentFrame);


        Vector3d translation;



        //! End first iteration of animation prototyping



        Matrix4d testMatrix = Matrix4d()
            .identity()
            .setTranslation(0,0,0)
            .setRotationXYZ(0,(1 / 360.0) * PI2,0)
            .scaleLocal(1,1,1);

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
