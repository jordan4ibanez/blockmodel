import std.stdio;
import bindbc.opengl;
import camera.camera;
import mesh.mesh;
import shader.shader;
import texture.texture;
import window.window;
import vector_3d;
import blockmodel.blockmodel;
import math;

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
    // shader.createUniform("bonePosition");
    // shader.createUniform("boneRotation");
    // shader.createUniform("boneScale");

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



    float rotation = -90.0;

    while (!window.shouldClose()) {

        // rotation += 1;
        // if (rotation > 360.0) {
        //     rotation = rotation - 360.0;
        // }


        window.pollEvents();

        glUseProgram(shader.getShaderProgram);

        window.clear(1);
        camera.clearDepthBuffer();
        camera.setRotation(Vector3d(0,0,0));
        camera.updateCameraMatrix();
        

        debugMesh.render(
            Vector3d(0,0,-4), // Translation
            Vector3d(0,rotation,0), // Rotation
            Vector3d(0.25), // Scale
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
