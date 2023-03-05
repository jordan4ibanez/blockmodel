module camera.camera;

import bindbc.opengl;
import window.window;
import vector_3d;
import matrix_4d;
import math;

class Camera {

    
    private static Camera instance;
    

    private double FOV = math.toRadians(60.0);

    // Never set this to 0 :P
    // ALSO never set this too low!! You get float errors!
    private immutable double Z_NEAR = 0.1;
    // Never set this too high or less than Z_NEAR!!!
    private immutable double Z_FAR = 600.0;

    private Matrix4d cameraMatrix = Matrix4d();
    private Matrix4d objectMatrix = Matrix4d();

    // Set at x:0, y:0 z:1 so I can see the "center of the 4d world"
    private Vector3d position = Vector3d(0,0,0);
    private Vector3d rotation = Vector3d(0,0,0); 

    private this() {}

    Matrix4d getCameraMatrix() {
        return cameraMatrix;
    }

    Matrix4d getObjectMatrix() {
        return objectMatrix;
    }

    /**
    This is where the object get's it's render point
    it does 3 things:
    1. Calculates it's position in 4d space
    2. Uploads the matrix to glsl
    3. glsl will multiply this matrix by the camera's matrix, giving a usable position
    */
    float[16] setObjectMatrix(Vector3d offset, Vector3d rotation, Vector3d scale) {

        // The primary usecase for this is mobs. So Y X Z to do moblike animations.
        objectMatrix
            .identity()
            .translate(-position.x + offset.x, -position.y + offset.y, -position.z + offset.z)
            .rotateY(math.toRadians(-rotation.y))
            .rotateX(math.toRadians(-rotation.x))
            .rotateZ(math.toRadians(-rotation.z))
            .scale(scale);
        return objectMatrix.getFloatArray();
    }

    /**
    This is where the camera gets it's viewpoint for the frame
    it does 3 things:
    1. Calculates and sets it's aspect ratio from the window
    2. Calculates it's position in 4d space, and locks it in place
    3. It updates GLSL so it can work with it
    */
    float[16] updateCameraMatrix() {
        double aspectRatio = Window.getAspectRatio();
        
        cameraMatrix.identity()
            .perspective(FOV, aspectRatio, Z_NEAR, Z_FAR)
            .rotateX(math.toRadians(rotation.x))
            .rotateY(math.toRadians(rotation.y));
        return cameraMatrix.getFloatArray();
    }

    // It is extremely important to clear the buffer bit!
    void clearDepthBuffer() {
        glClear(GL_DEPTH_BUFFER_BIT);
    }

    void setFOV(double newFOV) {
        FOV = newFOV;
    }

    double getFOV() {
        return FOV;
    }

    Vector3d getPosition() {
        return position;
    }

    void movePosition(Vector3d positionModification) {
        if ( positionModification.z != 0 ) {
            position.x += -math.sin(math.toRadians(rotation.y)) * positionModification.z;
            position.z += math.cos(math.toRadians(rotation.y)) * positionModification.z;
        }
        if ( positionModification.x != 0) {
            position.x += -math.sin(math.toRadians(rotation.y - 90)) * positionModification.x;
            position.z += math.cos(math.toRadians(rotation.y - 90)) * positionModification.x;
        }
        position.y += positionModification.y;
    }

    void setPosition(Vector3d newCameraPosition){
        position = newCameraPosition;
    }


    void rotationLimiter() {    
        
        // Pitch limiter
        if (rotation.x > 90) {
            rotation.x = 90;
        } else if (rotation.x < -90) {
            rotation.x = -90;
        }
        // Yaw overflower
        if (rotation.y > 180) {
            rotation.y -= 360.0;
        } else if (rotation.y < -180) {
            rotation.y += 360.0;
        }
    }

    void moveRotation(Vector3d rotationModification) {
        rotation.x += rotationModification.x;
        rotation.y += rotationModification.y;
        rotation.z += rotationModification.z;
        rotationLimiter();
    }

    // Sets rotation in degrees
    void setRotation(Vector3d newRotation) {
        rotation = newRotation;
        rotationLimiter();
    }

    // Gets rotation in degrees
    Vector3d getRotation() {
        return rotation;
    }
}