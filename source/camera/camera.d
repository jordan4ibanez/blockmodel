module camera.camera;

import bindbc.opengl;
import window.window;
import vector_3d;
import matrix_4d;
import math;

/// Works as a singleton. Handles all math for rendering.
class Camera {

    // The only instance of Camera.
    private static Camera instance;

    private double FOV = math.toRadians(60.0);

    // Never set this to 0 :P
    // ALSO never set this too low!! You get float errors!
    private immutable double Z_NEAR = 0.1;
    // Never set this too high or less than Z_NEAR!!!
    private immutable double Z_FAR = 600.0;

    private Matrix4d cameraMatrix = Matrix4d();
    private Matrix4d objectMatrix = Matrix4d();

    // Set at x:0, y:0 z:0 so I can see the "center of the 4d world"
    private Vector3d position = Vector3d(0,0,0);
    private Vector3d rotation = Vector3d(0,0,0); 

    private this() {}

    /// Initialize the instance of the Camera class.
    static void initialize() {
        if (instance is null){
            instance = new Camera();
        }
    }

    static Matrix4d getCameraMatrix() {
        return instance.cameraMatrix;
    }

    static Matrix4d getObjectMatrix() {
        return instance.objectMatrix;
    }

    /**
    This is where the object get's it's render point
    it does 3 things:
    1. Calculates it's position in 4d space
    2. Uploads the matrix to glsl
    3. glsl will multiply this matrix by the camera's matrix, giving a usable position
    */
    static float[16] setObjectMatrix(Vector3d offset, Vector3d rotation, Vector3d scale) {

        // The primary usecase for this is mobs. So Y X Z to do moblike animations.
        instance.objectMatrix
            .identity()
            .translate(-instance.position.x + offset.x, -instance.position.y + offset.y, -instance.position.z + offset.z)
            .rotateY(math.toRadians(-rotation.y))
            .rotateX(math.toRadians(-rotation.x))
            .rotateZ(math.toRadians(-rotation.z))
            .scale(scale);
        return instance.objectMatrix.getFloatArray();
    }

    /**
    This is where the camera gets it's viewpoint for the frame
    it does 3 things:
    1. Calculates and sets it's aspect ratio from the window
    2. Calculates it's position in 4d space, and locks it in place
    3. It updates GLSL so it can work with it
    */
    static float[16] updateCameraMatrix() {
        double aspectRatio = Window.getAspectRatio();
        
        instance.cameraMatrix.identity()
            .perspective(instance.FOV, aspectRatio, instance.Z_NEAR, instance.Z_FAR)
            .rotateX(math.toRadians(instance.rotation.x))
            .rotateY(math.toRadians(instance.rotation.y));
        return instance.cameraMatrix.getFloatArray();
    }

    // It is extremely important to clear the buffer bit!
    static void clearDepthBuffer() {
        glClear(GL_DEPTH_BUFFER_BIT);
    }

    static void setFOV(double newFOV) {
        instance.FOV = newFOV;
    }

    static double getFOV() {
        return instance.FOV;
    }

    static Vector3d getPosition() {
        return instance.position;
    }

    static void movePosition(Vector3d positionModification) {
        if ( positionModification.z != 0 ) {
            instance.position.x += -math.sin(math.toRadians(instance.rotation.y)) * positionModification.z;
            instance.position.z += math.cos(math.toRadians(instance.rotation.y)) * positionModification.z;
        }
        if ( positionModification.x != 0) {
            instance.position.x += -math.sin(math.toRadians(instance.rotation.y - 90)) * positionModification.x;
            instance.position.z += math.cos(math.toRadians(instance.rotation.y - 90)) * positionModification.x;
        }
        instance.position.y += positionModification.y;
    }

    static void setPosition(Vector3d newCameraPosition){
        instance.position = newCameraPosition;
    }


    static void rotationLimiter() {    
        
        // Pitch limiter
        if (instance.rotation.x > 90) {
            instance.rotation.x = 90;
        } else if (instance.rotation.x < -90) {
            instance.rotation.x = -90;
        }
        // Yaw overflower
        if (instance.rotation.y > 180) {
            instance.rotation.y -= 360.0;
        } else if (instance.rotation.y < -180) {
            instance.rotation.y += 360.0;
        }
    }

    static void moveRotation(Vector3d rotationModification) {
        instance.rotation.x += rotationModification.x;
        instance.rotation.y += rotationModification.y;
        instance.rotation.z += rotationModification.z;
        rotationLimiter();
    }

    // Sets rotation in degrees
    static void setRotation(Vector3d newRotation) {
        instance.rotation = newRotation;
        rotationLimiter();
    }

    // Gets rotation in degrees
    static Vector3d getRotation() {
        return instance.rotation;
    }
}